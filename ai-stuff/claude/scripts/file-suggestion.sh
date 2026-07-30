#!/bin/bash
# Custom file suggestion script for Claude Code
# Uses rg + fzf for fuzzy matching and symlink support

# Parse JSON input to get query (avoid jq/printf overhead)
QUERY=$(sed -n 's/.*"query" *: *"\([^"]*\)".*/\1/p')

# @-mentions can't contain spaces, so treat "_" as a word separator.
# fzf ANDs space-separated terms, so "daily_note" matches "Daily Note.md"
# as well as "daily_note.md" and "daily-note.md".
QUERY="${QUERY//_/ }"

# Use project dir from env, fallback to pwd
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# cd into project dir so rg outputs relative paths
cd "$PROJECT_DIR" || exit 1

# Bypass gitignore for Obsidian vaults or projects with marker file
if [ -d ".obsidian" ] || [ -f ".claude-suggest-all" ]; then
  rg --files --follow --hidden --no-ignore-vcs -g '!.git/' . 2>/dev/null
else
  rg --files --follow --hidden -g '!.git/' . 2>/dev/null
fi | fzf --filter "$QUERY" --scheme=path --tiebreak=chunk,length | head -15
