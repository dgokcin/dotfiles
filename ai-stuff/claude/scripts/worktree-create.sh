#!/bin/bash
set -e

# Read JSON from stdin
INPUT=$(cat)

NAME=$(echo "$INPUT" | jq -r '.name')
DIR="$CLAUDE_PROJECT_DIR/.claude/worktrees/$NAME"

mkdir -p "$CLAUDE_PROJECT_DIR/.claude/worktrees"

# Idempotent: return path if worktree already exists
if git worktree list --porcelain | grep -q "^worktree $DIR$"; then
  echo "$DIR"
  exit 0
fi

# Fetch latest remote state (--prune drops refs for branches deleted upstream)
git fetch --prune origin >&2 2>/dev/null || true

# Detect default branch (main or master)
if git show-ref --verify --quiet refs/remotes/origin/main; then
  BASE="origin/main"
elif git show-ref --verify --quiet refs/remotes/origin/master; then
  BASE="origin/master"
else
  BASE="HEAD"
fi

# Try creating with new branch from remote base, then existing branch, then after pruning
(git worktree add -b "$NAME" "$DIR" "$BASE" 2>/dev/null ||
  git worktree add "$DIR" "$NAME" 2>/dev/null ||
  (git worktree prune && git worktree add "$DIR" "$NAME")) >&2

# Set up remote tracking only if origin/$NAME actually exists, else clear
# any stale upstream so `git status` doesn't report a gone upstream
if git show-ref --verify --quiet "refs/remotes/origin/$NAME"; then
  git -C "$DIR" config "branch.$NAME.remote" origin >&2
  git -C "$DIR" config "branch.$NAME.merge" "refs/heads/$NAME" >&2
else
  git -C "$DIR" config --unset "branch.$NAME.remote" >&2 2>/dev/null || true
  git -C "$DIR" config --unset "branch.$NAME.merge" >&2 2>/dev/null || true
fi

echo "$DIR"
