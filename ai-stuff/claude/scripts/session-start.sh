#!/bin/bash
set -e

# SessionStart hook: auto-name sessions started inside a git worktree.
#
# Why: when a worktree session has no name, Claude removes the worktree
# automatically at exit with no prompt (and the WorktreeRemove hook never
# fires) -> zombie worktrees. A named session triggers the keep/remove
# prompt instead. See worktrees docs: "If the session has a name, Claude
# prompts instead so you can keep the worktree for later."

INPUT=$(cat)

SOURCE=$(echo "$INPUT" | jq -r '.source // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
EXISTING_TITLE=$(echo "$INPUT" | jq -r '.session_title // empty')

# sessionTitle is only honored on startup/resume; bail on clear/compact.
case "$SOURCE" in
  startup | resume) ;;
  *) exit 0 ;;
esac

# Don't clobber an explicit name (e.g. `claude -n <name>`).
[ -n "$EXISTING_TITLE" ] && exit 0

# Need a real cwd inside a git repo.
[ -z "$CWD" ] && exit 0
GIT_DIR=$(git -C "$CWD" rev-parse --git-dir 2>/dev/null) || exit 0
COMMON_DIR=$(git -C "$CWD" rev-parse --git-common-dir 2>/dev/null) || exit 0

# In a linked worktree, --git-dir and --git-common-dir differ. In the main
# worktree they match -> nothing to do.
[ "$GIT_DIR" = "$COMMON_DIR" ] && exit 0

# Name = the worktree's checked-out branch, falling back to the dir name.
NAME=$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null || true)
[ -z "$NAME" ] && NAME=$(basename "$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)")
[ -z "$NAME" ] && exit 0

jq -n --arg t "$NAME" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", sessionTitle: $t}}'
