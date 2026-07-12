#!/usr/bin/env bash
# Remove a single git worktree and its local branch.
#
# Usage: worktree-cleanup-remove.sh <repo> <worktree> [branch]
#   repo     = main worktree / repo root that owns the worktree
#   worktree = absolute path of the worktree to remove
#   branch   = local branch to delete (optional; skipped for main/master)
#
# Uses --force so dirty/locked worktrees are still removed — the SKILL is
# responsible for warning the user about uncommitted work BEFORE calling this.
set -uo pipefail

REPO="${1:?repo required}"
WT="${2:?worktree path required}"
BRANCH="${3:-}"

git -C "$REPO" worktree remove --force "$WT" 2>/dev/null || rm -rf "$WT"
git -C "$REPO" worktree prune 2>/dev/null || true

if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  git -C "$REPO" branch -D "$BRANCH" 2>/dev/null || true
fi

echo "removed: $WT (branch: ${BRANCH:-none})"
