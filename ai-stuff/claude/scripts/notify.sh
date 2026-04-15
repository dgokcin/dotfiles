#!/usr/bin/env bash
# Claude Code notification hook — click to focus iTerm2 window by CWD

input=$(cat)
MESSAGE=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','Claude needs attention'))")
TITLE=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title','Claude Code'))")
CWD=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))")

SCRIPT="$HOME/.claude/scripts/focus-iterm.applescript"

terminal-notifier \
  -title "$TITLE" \
  -message "$MESSAGE" \
  -activate com.googlecode.iterm2 \
  -execute "osascript '$SCRIPT' '$CWD'"
