#!/usr/bin/env bash
# Point every skill the `skills` CLI installed from REPO back at REPO.
#
# `skills add` copies each skill into ~/.agents/skills (read by Codex and
# Cursor) and links ~/.claude/skills/<name> to that copy. Swapping the copy for
# a symlink into REPO makes edits apply live in every agent.
#
# Repo links without a lock entry are removed. That covers skills dropped with
# `skills remove` and links left by the old link-skills.sh.
set -euo pipefail

REPO="$(cd "${1:?usage: skills-link.sh <skills-repo>}" && pwd)"
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"
LOCK="$HOME/.agents/.skill-lock.json"

installed=()
if [[ -f "$LOCK" ]]; then
  while IFS= read -r name; do installed+=("$name"); done < <(
    jq -r --arg repo "$REPO" \
      '.skills // {} | to_entries[] | select(.value.sourceType == "local" and .value.source == $repo) | .key' \
      "$LOCK"
  )
fi

is_installed() {
  local name
  for name in ${installed[@]+"${installed[@]}"}; do
    [[ "$name" == "$1" ]] && return 0
  done
  return 1
}

skill_dir() {
  local md
  for md in "$REPO"/skills/*/"$1"/SKILL.md; do
    [[ -f "$md" && "$md" != "$REPO/skills/archived/"* ]] || continue
    dirname "$md"
    return 0
  done
  return 1
}

linked=0
for name in ${installed[@]+"${installed[@]}"}; do
  if ! src="$(skill_dir "$name")"; then
    echo "skills-link: no folder for '$name' in $REPO/skills, skipped" >&2
    continue
  fi
  dest="$AGENTS_DIR/$name"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    linked=$((linked + 1))
    continue
  fi

  # dest is the CLI's copy or a stale link, never the repo itself.
  rm -rf "$dest"
  ln -s "$src" "$dest"
  linked=$((linked + 1))
done

pruned=0
for dir in "$AGENTS_DIR" "$CLAUDE_DIR"; do
  [[ -d "$dir" ]] || continue
  for link in "$dir"/*; do
    [[ -L "$link" ]] || continue
    case "$(readlink "$link")" in
      "$REPO"/*) ;;
      *) continue ;;
    esac
    is_installed "$(basename "$link")" && continue
    rm "$link"
    echo "skills-link: pruned $link"
    pruned=$((pruned + 1))
  done
done

echo "skills-link: $linked skills live from $REPO, $pruned stale links pruned"
