#!/bin/bash
set -e

# Read JSON from stdin
INPUT=$(cat)

# Parse fields from Claude Code hook input
BASE_PATH=$(echo "$INPUT" | jq -r '.cwd')
WORKTREE_NAME=$(echo "$INPUT" | jq -r '.name')

# Worktree lives under .git/worktrees/<name>
WORKTREE_PATH="$BASE_PATH/.git/worktrees/$WORKTREE_NAME"

cd "$BASE_PATH"

# Create worktree — branch name matches worktree name (no prefix)
git worktree add "$WORKTREE_PATH" -b "$WORKTREE_NAME" origin/HEAD

# Push branch to remote with tracking
git -C "$WORKTREE_PATH" push -u origin "$WORKTREE_NAME"

# Required: print the worktree path to stdout
echo "$WORKTREE_PATH"
exit 0
