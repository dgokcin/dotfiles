#!/usr/bin/env bash
# Cursor auto-approve adapter.
#
# Cursor splits permission across tool-specific events (beforeShellExecution,
# beforeReadFile) and speaks a different protocol from Claude Code:
#   in:  {"hook_event_name": ..., "command"|"file_path": ..., ...}
#   out: {"permission": "allow"|"deny"|"ask"}
#
# The shared allowlist (~/.cursor/scripts/auto-approve-tools.sh, symlinked from
# ai-stuff/_shared/scripts) reads a Claude-shaped payload and answers in
# Claude's schema. This adapter translates in both directions so the SAME
# allowlist governs Claude Code, Codex, and Cursor. It only ever emits an
# explicit "allow"; anything the allowlist does not match returns {} (no
# opinion), letting Cursor fall through to its normal permission handling.

SHARED="$HOME/.cursor/scripts/auto-approve-tools.sh"

input=$(cat 2>/dev/null || true)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)

case "$event" in
  beforeShellExecution)
    payload=$(printf '%s' "$input" | jq -c '{tool_name:"Bash",tool_input:{command:(.command // "")}}' 2>/dev/null)
    ;;
  beforeReadFile)
    payload=$(printf '%s' "$input" | jq -c '{tool_name:"Read",tool_input:{file_path:(.file_path // "")}}' 2>/dev/null)
    ;;
  *)
    echo '{}'
    exit 0
    ;;
esac

if [ -z "$payload" ] || [ ! -x "$SHARED" ]; then
  echo '{}'
  exit 0
fi

decision=$(printf '%s' "$payload" | "$SHARED" pre-tool 2>/dev/null)
verdict=$(printf '%s' "$decision" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)

if [ "$verdict" = "allow" ]; then
  echo '{"permission":"allow"}'
else
  echo '{}'
fi
