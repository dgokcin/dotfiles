#!/usr/bin/env bash
# Cursor sessionStart hook — inject git worktree context.
#
# Mirrors the Claude Code SessionStart worktree echo, adapted to Cursor's JSON
# output protocol: sessionStart consumes {"additional_context": "..."} rather
# than raw stdout text. cd into the workspace root (Cursor passes it on stdin)
# so git reports the project the session actually opened.

input=$(cat 2>/dev/null || true)
root=$(printf '%s' "$input" | jq -r '.workspace_roots[0] // empty' 2>/dev/null)
[ -n "$root" ] && cd "$root" 2>/dev/null

ctx=$(printf 'Working directory: %s\nMain git dir: %s\nIs worktree: %s\nMain worktree: %s' \
  "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" \
  "$(git rev-parse --git-common-dir 2>/dev/null)" \
  "$(git rev-parse --is-inside-work-tree 2>/dev/null)" \
  "$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/worktree //')")

jq -cn --arg ctx "$ctx" '{additional_context: $ctx}'
