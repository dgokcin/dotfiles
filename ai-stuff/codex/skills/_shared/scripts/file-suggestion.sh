#!/bin/bash
# Custom file suggestion script for Claude Code
# Uses rg + fzf for fuzzy matching and symlink support

# Parse JSON input to get query (avoid jq overhead)
read -r INPUT
QUERY=$(printf '%s' "$INPUT" | sed -n 's/.*"query" *: *"\([^"]*\)".*/\1/p')

# Use project dir from env, fallback to pwd
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# cd into project dir so rg outputs relative paths
cd "$PROJECT_DIR" || exit 1

{
  # Main search - respects .gitignore, includes hidden files, follows symlinks
  rg --files --follow --hidden -g '!.git/' . 2>/dev/null

  # Additional paths - include even if gitignored (uncomment and customize)
  # [ -e .notes ] && rg --files --follow --hidden --no-ignore-vcs .notes 2>/dev/null
} | fzf --filter "$QUERY" | head -15
