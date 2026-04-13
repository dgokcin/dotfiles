#!/bin/bash
# Custom statusline script for Claude Code
# Reads JSON input from stdin and outputs a formatted status line

# Read JSON input from stdin
input=$(cat)

# Basic info
cwd=$(echo "$input" | jq -r ".workspace.current_dir")
model=$(echo "$input" | jq -r ".model.display_name")
time=$(date +%H:%M:%S)
cost_usd=$(echo "$input" | jq -r ".cost_usd // empty")

# Git info
git_branch=""
git_status=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null ||
    git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$git_branch" ]; then
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      git_status="x"
    else
      git_status="o"
    fi
  fi
fi

# Vim mode (bracket indicator removed; Claude Code renders -- INSERT --/-- NORMAL -- natively)
vim_mode=""

# Reasoning effort: Claude Code does not pass effort_level in the statusline JSON.
# Read effortLevel from settings.json, but only show it for models that support
# extended thinking (Sonnet/Opus). Haiku and other non-thinking models → "n/a".
model_id=$(echo "$input" | jq -r '.model.id // empty')
effort_level=""
case "$model_id" in
*haiku*) effort_level="n/a" ;;
*)
  settings_path="$HOME/.claude/settings.json"
  if [ -f "$settings_path" ]; then
    effort_level=$(jq -r '.effortLevel // empty' "$settings_path" 2>/dev/null)
  fi
  [ -z "$effort_level" ] && effort_level="n/a"
  ;;
esac

# Token calculations
context_size=$(echo "$input" | jq -r ".context_window.context_window_size // 200000")
input_tokens=$(echo "$input" | jq -r ".context_window.current_usage.input_tokens // 0")
cache_create=$(echo "$input" | jq -r ".context_window.current_usage.cache_creation_input_tokens // 0")
cache_read=$(echo "$input" | jq -r ".context_window.current_usage.cache_read_input_tokens // 0")
current_tokens=$((input_tokens + cache_create + cache_read))

format_tokens() {
  local num=$1
  if [ "$num" -ge 1000000 ]; then
    echo "$(echo "scale=1; $num / 1000000" | bc)m"
  elif [ "$num" -ge 1000 ]; then
    echo "$((num / 1000))k"
  else
    echo "$num"
  fi
}

used_fmt=$(format_tokens "$current_tokens")
total_fmt=$(format_tokens "$context_size")
if [ "$context_size" -gt 0 ]; then
  pct_used=$((current_tokens * 100 / context_size))
else
  pct_used=0
fi

# Auto-compact: remaining tokens until trigger
# Read from settings.json env block (Claude Code doesn't export these to statusline process)
ac_window="${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-}"
ac_pct="${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:-}"
if [ -z "$ac_window" ] || [ -z "$ac_pct" ]; then
  if [ -f "$settings_path" ]; then
    [ -z "$ac_window" ] && ac_window=$(jq -r '.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW // empty' "$settings_path" 2>/dev/null)
    [ -z "$ac_pct" ] && ac_pct=$(jq -r '.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE // empty' "$settings_path" 2>/dev/null)
  fi
fi
# Fallbacks
[ -z "$ac_window" ] && ac_window="$context_size"
[ -z "$ac_pct" ] && ac_pct=95

# Cap window to actual context if larger
[ "$ac_window" -gt "$context_size" ] && ac_window="$context_size"

ac_trigger=$((ac_window * ac_pct / 100))
ac_remaining=$((ac_trigger - current_tokens))
ac_remaining_fmt=""
if [ "$ac_remaining" -gt 0 ]; then
  ac_remaining_fmt=$(format_tokens "$ac_remaining")
fi

# Colors
C_BLUE="\033[38;2;0;153;255m"
C_ORANGE="\033[38;2;255;176;85m"
C_GREEN="\033[38;2;0;160;0m"
C_CYAN="\033[38;2;46;149;153m"
C_RED="\033[38;2;255;85;85m"
C_YELLOW="\033[38;2;230;200;0m"
C_WHITE="\033[38;2;220;220;220m"
C_DIM="\033[2m"
C_RESET="\033[0m"

# Build progress bar
build_bar() {
  local pct=$1 width=$2
  [ "$pct" -lt 0 ] 2>/dev/null && pct=0
  [ "$pct" -gt 100 ] 2>/dev/null && pct=100
  local filled=$((pct * width / 100))
  local empty=$((width - filled))

  local bar_color="$C_GREEN"
  if [ "$pct" -ge 90 ]; then
    bar_color="$C_RED"
  elif [ "$pct" -ge 70 ]; then
    bar_color="$C_YELLOW"
  elif [ "$pct" -ge 50 ]; then
    bar_color="$C_ORANGE"
  fi

  local filled_str="" empty_str=""
  for ((i = 0; i < filled; i++)); do filled_str+="●"; done
  for ((i = 0; i < empty; i++)); do empty_str+="○"; done

  printf "%b%s%b%s%b" "$bar_color" "$filled_str" "$C_DIM" "$empty_str" "$C_RESET"
}

# Rate limit data — available from stdin as of Claude Code v2.1.80+
# resets_at is a Unix timestamp
five_hour_pct=0
five_hour_reset=""
seven_day_pct=0
seven_day_reset=""

format_reset_time_epoch() {
  local epoch=$1 style=$2
  if [ -z "$epoch" ]; then return; fi
  if [ "$(uname)" = "Darwin" ]; then
    if [ "$style" = "time" ]; then
      date -r "$epoch" "+%-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    else
      date -r "$epoch" "+%b %-d, %-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    fi
  else
    if [ "$style" = "time" ]; then
      date -d "@$epoch" "+%-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    else
      date -d "@$epoch" "+%b %-d, %-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    fi
  fi
}

five_hour_pct_raw=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
if [ -n "$five_hour_pct_raw" ]; then
  five_hour_pct=$(echo "$five_hour_pct_raw" | awk '{printf "%d", int($1 + 0.5)}')
  five_hour_reset_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
  five_hour_reset=$(format_reset_time_epoch "$five_hour_reset_epoch" "time")

  seven_day_pct_raw=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
  seven_day_pct=$(echo "$seven_day_pct_raw" | awk '{printf "%d", int($1 + 0.5)}')
  seven_day_reset_epoch=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)
  seven_day_reset=$(format_reset_time_epoch "$seven_day_reset_epoch" "datetime")
fi

# Format cost as $X.XXXX (4 decimal places), dropping trailing zeros after 2
format_cost() {
  local raw=$1
  if [ -z "$raw" ]; then return; fi
  # Use awk to format: show 4 sig decimals but drop trailing zeros beyond 2
  echo "$raw" | awk '{
    val = $1 + 0
    printf "$%.4f", val
  }' | sed 's/\(\.[0-9][0-9]\)0\+$/\1/'
}

cost_fmt=$(format_cost "$cost_usd")

SEP=" ${C_DIM}|${C_RESET} "

# ===== OUTPUT =====

# Worktree context
worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')

# Directory: git repo root name, or full path if not a repo
if [ -n "$git_branch" ]; then
  dir_name=$(basename "$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)")
else
  dir_name="$cwd"
fi

# Line 0: dir on git:branch [time] [vim]
if [ -n "$worktree_name" ]; then
  # In a worktree: show "repo / worktree-name on git:branch"
  repo_name=$(echo "$input" | jq -r '.worktree.original_cwd // empty' | xargs basename 2>/dev/null)
  [ -z "$repo_name" ] && repo_name="$dir_name"
  printf "\033[1;33m%s\033[0m" "$repo_name"
  printf " ${C_DIM}/${C_RESET} "
  printf "\033[1;33m%s\033[0m" "$worktree_name"
else
  printf "\033[1;33m%s\033[0m" "$dir_name"
fi

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

if [ -n "$vim_mode" ]; then
  printf "\033[33m%s\033[0m" "$vim_mode"
fi

# Line 1: Model | tokens used/total (%) | effort
effort_color="$C_DIM"
case "$effort_level" in
high | max) effort_color="$C_RED" ;;
medium) effort_color="$C_ORANGE" ;;
low) effort_color="$C_GREEN" ;;
esac

printf "\n"
printf "%b%s%b" "$C_BLUE" "$model" "$C_RESET"
printf "%b" "$SEP"
printf "ctx: %b%s / %s%b %b(%s%%)%b" "$C_ORANGE" "$used_fmt" "$total_fmt" "$C_RESET" "$C_GREEN" "$pct_used" "$C_RESET"
if [ -n "$ac_remaining_fmt" ]; then
  printf " %bacp:%b%s" "$C_DIM" "$C_RESET" "$ac_remaining_fmt"
fi
if [ -n "$cost_fmt" ]; then
  printf "%b" "$SEP"
  printf "cost: %b%s%b" "$C_CYAN" "$cost_fmt" "$C_RESET"
fi
printf "%b" "$SEP"
printf "effort: %b%s%b" "$effort_color" "$effort_level" "$C_RESET"

# Line 2: Current (5h) bar | Weekly (7d) bar
if [ -n "$five_hour_pct_raw" ]; then
  printf "\n"
  printf "%bcurrent:%b " "$C_WHITE" "$C_RESET"
  build_bar "$five_hour_pct" 10
  printf " %b%s%%%b" "$C_CYAN" "$five_hour_pct" "$C_RESET"
  printf "%b" "$SEP"
  printf "%bweekly:%b " "$C_WHITE" "$C_RESET"
  build_bar "$seven_day_pct" 10
  printf " %b%s%%%b" "$C_CYAN" "$seven_day_pct" "$C_RESET"

  # Line 3: Reset times
  printf "\n"
  printf "%bresets:%b 5h @ %s" "$C_WHITE" "$C_RESET" "$five_hour_reset"
  printf "%b" "$SEP"
  printf "7d @ %s" "$seven_day_reset"
fi
