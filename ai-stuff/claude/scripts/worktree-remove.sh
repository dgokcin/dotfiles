#!/bin/bash
set -e

# Read JSON from stdin
INPUT=$(cat)

WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path')

git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
rm -rf "$WORKTREE_PATH"
