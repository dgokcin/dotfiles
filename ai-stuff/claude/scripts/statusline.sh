#!/bin/bash
# Custom statusline script for Claude Code
# Reads JSON input from stdin and outputs a formatted status line

# Read JSON input from stdin
input=$(cat)

# Basic info
user=$(whoami)
machine=$(hostname -s)
cwd=$(echo "$input" | jq -r ".workspace.current_dir")
model=$(echo "$input" | jq -r ".model.display_name")
time=$(date +%H:%M:%S)

# Git info
git_branch=""
git_status=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null || \
               git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$git_branch" ]; then
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      git_status="x"
    else
      git_status="o"
    fi
  fi
fi

# Vim mode
vim_mode=""
vim_mode_json=$(echo "$input" | jq -r ".vim.mode // empty")
if [ -n "$vim_mode_json" ]; then
  if [ "$vim_mode_json" = "NORMAL" ]; then
    vim_mode=" [N]"
  else
    vim_mode=" [I]"
  fi
fi

# Context window remaining
context_remaining=$(echo "$input" | jq -r ".context_window.remaining_percentage // empty")
context_info=""
context_color="32"
if [ -n "$context_remaining" ]; then
  remaining_int=$(printf "%.0f" "$context_remaining")
  if [ "$remaining_int" -lt 20 ]; then
    context_color="31"
  elif [ "$remaining_int" -lt 50 ]; then
    context_color="33"
  fi
  context_info=" ctx:${remaining_int}%"
fi

# Extended thinking mode
thinking=$(echo "$input" | jq -r ".extended_thinking // .model.extended_thinking // .thinking.enabled // .model.thinking // false")
thinking_info=""
if [ "$thinking" = "true" ]; then
  thinking_info=" \033[1;95m[Think]\033[0m"
fi

# Output the status line
printf "\033[1;34m#\033[0m "
printf "\033[36m%s\033[0m " "$user"
printf "@ "
printf "\033[32m%s\033[0m " "$machine"
printf "in "
printf "\033[1;33m%s\033[0m" "$cwd"

if [ -n "$git_branch" ]; then
  printf " on "
  printf "\033[34mgit\033[0m:"
  printf "\033[36m%s\033[0m" "$git_branch"
  if [ "$git_status" = "x" ]; then
    printf " \033[31mx\033[0m"
  else
    printf " \033[32mo\033[0m"
  fi
fi

printf " [%s]" "$time"
printf " [\033[35m%s\033[0m]" "$model"

if [ -n "$context_info" ]; then
  printf "\033[${context_color}m%s\033[0m" "$context_info"
fi

if [ -n "$vim_mode" ]; then
  printf "\033[33m%s\033[0m" "$vim_mode"
fi

if [ -n "$thinking_info" ]; then
  printf "%s" "$thinking_info"
fi
