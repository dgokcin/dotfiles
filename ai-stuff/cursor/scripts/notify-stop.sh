#!/usr/bin/env bash
# Cursor stop hook — desktop notification, click to focus the iTerm2 window by
# workspace root. Mirrors codex/notify-stop.sh; Cursor's stop payload carries
# workspace_roots (Claude/Codex use cwd), so read that first.
#
# terminal-notifier output is discarded to keep stdout clean, then {} is
# emitted: a stop hook may return {"followup_message": "..."} to keep the agent
# looping, and {} means "no followup — stop normally".

input=$(cat 2>/dev/null || true)
CWD=$(printf '%s' "$input" | jq -r '.workspace_roots[0] // .cwd // empty' 2>/dev/null)

SCRIPT="$HOME/.cursor/scripts/focus-iterm.applescript"

terminal-notifier \
  -title "Cursor" \
  -message "Agent finished — needs your attention" \
  -activate com.googlecode.iterm2 \
  -execute "osascript '$SCRIPT' '$CWD'" >/dev/null 2>&1

echo '{}'
