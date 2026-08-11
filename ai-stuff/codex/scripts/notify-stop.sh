#!/usr/bin/env bash
# Codex Stop hook — desktop notification, click to focus iTerm2 window by CWD.

input=$(cat 2>/dev/null || true)
CWD=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)

SCRIPT="$HOME/.codex/scripts/focus-iterm.applescript"

terminal-notifier \
  -title "Codex" \
  -message "Turn finished — needs your attention" \
  -activate com.googlecode.iterm2 \
  -execute "osascript '$SCRIPT' '$CWD'"
