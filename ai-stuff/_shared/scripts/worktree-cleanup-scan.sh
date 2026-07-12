#!/usr/bin/env bash
# Scan git worktrees and classify each as merged / unmerged / unknown.
#
# Usage: worktree-cleanup-scan.sh [path]
#   path = a single git repo (default: $PWD), OR a directory containing
#          multiple repos (e.g. ~/codes/work). Immediate child dirs that
#          are git repos are each scanned.
#
# Output: a JSON array on stdout, one object per non-main worktree:
#   { repo, repo_name, worktree, branch, status, reason, dirty, ahead, warnings[] }
#
# Merge detection is layered because PRs/MRs are usually SQUASH-merged, which
# means the branch's individual commits never land in main verbatim:
#   1. local: branch is an ancestor of origin/<default>      -> merged (regular merge)
#   2. cherry: every commit has an equivalent in <default>   -> merged (rebase/cherry-pick)
#   3. remote-gone: branch had an upstream that no longer
#      exists on origin (forges auto-delete on merge)        -> merged (squash, most common)
#   4. forge: gh/glab reports a merged PR/MR for the branch  -> merged (confirmation)
# Anything else -> unmerged. Detached/odd states -> unknown.
set -uo pipefail

TARGET="${1:-$PWD}"
TARGET="${TARGET/#\~/$HOME}"

FETCH="${WORKTREE_CLEANUP_FETCH:-1}"   # set 0 to skip network fetch (faster, less accurate)
FORGE="${WORKTREE_CLEANUP_FORGE:-1}"   # set 0 to skip gh/glab queries

is_git_repo() { git -C "$1" rev-parse --git-dir >/dev/null 2>&1; }

# Resolve the MAIN worktree path for a repo (first entry of worktree list).
main_worktree() {
  git -C "$1" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}'
}

# Build the list of repos (main worktrees) to scan, de-duplicated.
declare -a REPOS=()
add_repo() {
  local r="$1" x
  for x in "${REPOS[@]:-}"; do [ "$x" = "$r" ] && return; done
  REPOS+=("$r")
}

if is_git_repo "$TARGET"; then
  add_repo "$(main_worktree "$TARGET")"
else
  while IFS= read -r d; do
    is_git_repo "$d" && add_repo "$(main_worktree "$d")"
  done < <(find "$TARGET" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
fi

if [ "${#REPOS[@]}" -eq 0 ]; then
  echo "[]"
  exit 0
fi

default_branch() {
  local r="$1" d
  d=$(git -C "$r" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  if [ -z "$d" ]; then
    if   git -C "$r" show-ref --verify --quiet refs/remotes/origin/main;   then d=main
    elif git -C "$r" show-ref --verify --quiet refs/remotes/origin/master; then d=master
    elif git -C "$r" show-ref --verify --quiet refs/heads/main;            then d=main
    elif git -C "$r" show-ref --verify --quiet refs/heads/master;          then d=master
    else d=$(git -C "$r" rev-parse --abbrev-ref HEAD 2>/dev/null); fi
  fi
  echo "$d"
}

# Pick forge CLI based on origin URL. Echoes "gh", "glab", or "".
forge_cli() {
  local url; url=$(git -C "$1" remote get-url origin 2>/dev/null)
  case "$url" in
    *gitlab*|*git.treatwell.net*) command -v glab >/dev/null 2>&1 && echo glab ;;
    *github*)                     command -v gh   >/dev/null 2>&1 && echo gh   ;;
    *)                            command -v gh   >/dev/null 2>&1 && echo gh   ;;
  esac
}

# Returns 0 if forge reports a merged PR/MR for the branch.
forge_merged() {
  local repo="$1" branch="$2" cli="$3"
  case "$cli" in
    gh)
      timeout 12 gh pr list --repo "$(git -C "$repo" remote get-url origin)" \
        --head "$branch" --state merged --json number -L 1 2>/dev/null \
        | grep -q '"number"'
      ;;
    glab)
      timeout 12 glab mr list --source-branch "$branch" --merged 2>/dev/null \
        | grep -qE '![0-9]+'
      ;;
    *) return 1 ;;
  esac
}

OBJS=()

for repo in "${REPOS[@]}"; do
  [ -z "$repo" ] && continue
  repo_name=$(basename "$repo")

  [ "$FETCH" = "1" ] && timeout 20 git -C "$repo" fetch --prune origin >/dev/null 2>&1 || true

  DEF=$(default_branch "$repo")
  CLI=""
  [ "$FORGE" = "1" ] && CLI=$(forge_cli "$repo")

  # Walk worktrees. First entry is the main worktree -> skip it.
  cur_wt=""; cur_branch=""; cur_detached=0; first=1
  flush() {
    [ -z "$cur_wt" ] && return
    if [ "$first" = "1" ]; then first=0; cur_wt=""; return; fi   # main worktree
    local wt="$cur_wt" branch="$cur_branch"
    cur_wt=""

    # Skip worktrees parked on the default branch.
    if [ "$branch" = "$DEF" ]; then return; fi

    local status="unmerged" reason="" warnings=() dirty="false" ahead=0

    if [ "$cur_detached" = "1" ] || [ -z "$branch" ]; then
      status="unknown"; reason="detached HEAD"; warnings+=("detached — no branch to evaluate")
    else
      # Dirty working tree?
      if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
        dirty="true"; warnings+=("uncommitted changes")
      fi
      # Unpushed commits relative to default.
      ahead=$(git -C "$repo" rev-list --count "origin/$DEF..$branch" 2>/dev/null || echo 0)

      # 1. ancestor of origin/<default> (regular merge)
      if git -C "$repo" merge-base --is-ancestor "$branch" "origin/$DEF" 2>/dev/null; then
        status="merged"; reason="ancestor of origin/$DEF"
      # 2. every commit equivalent already in <default> (rebase / cherry-pick)
      elif [ -n "$(git -C "$repo" cherry "origin/$DEF" "$branch" 2>/dev/null)" ] \
           && ! git -C "$repo" cherry "origin/$DEF" "$branch" 2>/dev/null | grep -q '^+'; then
        status="merged"; reason="all commits present in $DEF (rebased)"
      # 3. had an upstream that is now gone on origin (squash-merge + auto-delete)
      elif [ -n "$(git -C "$repo" config "branch.$branch.merge" 2>/dev/null)" ] \
           && ! git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        status="merged"; reason="remote branch deleted (squash-merged)"
      fi

      # 4. forge confirmation (also rescues abandoned-but-deleted false positives)
      if [ -n "$CLI" ]; then
        if forge_merged "$repo" "$branch" "$CLI"; then
          status="merged"; reason="${reason:+$reason; }$CLI: merged PR/MR"
        elif [ "$reason" = "remote branch deleted (squash-merged)" ]; then
          # remote gone but forge shows no merged PR -> likely abandoned, not merged
          status="unmerged"; reason="remote branch deleted but no merged PR/MR ($CLI)"
          warnings+=("branch gone from origin with no merged PR — verify before deleting")
        fi
      fi

      [ "$status" = "unmerged" ] && [ -z "$reason" ] && reason="not merged into $DEF"
    fi

    local warn_json; warn_json=$(printf '%s\n' "${warnings[@]:-}" | grep -v '^$' | jq -R . | jq -s .)
    OBJS+=("$(jq -n \
      --arg repo "$repo" --arg repo_name "$repo_name" --arg wt "$wt" \
      --arg branch "$branch" --arg status "$status" --arg reason "$reason" \
      --argjson dirty "$dirty" --argjson ahead "${ahead:-0}" --argjson warnings "$warn_json" \
      '{repo:$repo, repo_name:$repo_name, worktree:$wt, branch:$branch, status:$status, reason:$reason, dirty:$dirty, ahead:$ahead, warnings:$warnings}')")
  }

  while IFS= read -r line; do
    case "$line" in
      "worktree "*) flush; cur_wt="${line#worktree }"; cur_branch=""; cur_detached=0 ;;
      "branch "*)   cur_branch=$(echo "${line#branch }" | sed 's@^refs/heads/@@') ;;
      "detached")   cur_detached=1 ;;
    esac
  done < <(git -C "$repo" worktree list --porcelain 2>/dev/null)
  flush
done

if [ "${#OBJS[@]}" -eq 0 ]; then echo "[]"; else printf '%s\n' "${OBJS[@]}" | jq -s '.'; fi
