#!/bin/bash
# Custom statusline script for Claude Code
# Reads JSON input from stdin and outputs a formatted status line

# Read JSON input from stdin
input=$(cat)

# Basic info
cwd=$(echo "$input" | jq -r ".workspace.current_dir")
model=$(echo "$input" | jq -r ".model.display_name")
time=$(date +%H:%M:%S)

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

# Reasoning effort from settings
effort_level=""
settings_path="$HOME/.claude/settings.json"
if [ -f "$settings_path" ]; then
  effort_level=$(jq -r '.effortLevel // empty' "$settings_path" 2>/dev/null)
fi
if [ -z "$effort_level" ]; then
  effort_level="default"
fi

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

# API usage data (cached)
CACHE_FILE="/tmp/claude-statusline-usage-cache.json"
CACHE_MAX_AGE=60

get_oauth_token() {
  # macOS: credentials stored in Keychain
  if [ "$(uname)" = "Darwin" ]; then
    local keychain_data
    keychain_data=$(security find-generic-password -s "claude-code-credentials" -w 2>/dev/null ||
      security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    if [ -n "$keychain_data" ]; then
      echo "$keychain_data" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null
      return
    fi
  fi
  # Linux/Windows: credentials in file
  local creds_path="$HOME/.claude/.credentials.json"
  if [ -f "$creds_path" ]; then
    jq -r '.claudeAiOauth.accessToken // empty' "$creds_path" 2>/dev/null
  fi
}

fetch_usage_data() {
  local token
  token=$(get_oauth_token)
  if [ -z "$token" ]; then return 1; fi
  local tmp_file="${CACHE_FILE}.tmp"
  if curl -s --max-time 5 \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code/2.1.34" \
    "https://api.anthropic.com/api/oauth/usage" >"$tmp_file" 2>/dev/null; then
    # Only update cache if we got valid JSON with utilization data
    if jq -e '.five_hour.utilization' "$tmp_file" >/dev/null 2>&1; then
      mv "$tmp_file" "$CACHE_FILE"
    else
      rm -f "$tmp_file"
    fi
  else
    rm -f "$tmp_file"
  fi
}

needs_refresh=true
if [ -f "$CACHE_FILE" ]; then
  if [ "$(uname)" = "Darwin" ]; then
    cache_mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null)
  else
    cache_mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null)
  fi
  now=$(date +%s)
  if [ -n "$cache_mtime" ] && [ $((now - cache_mtime)) -lt $CACHE_MAX_AGE ]; then
    needs_refresh=false
  fi
fi

if $needs_refresh; then
  fetch_usage_data
fi

usage_data=""
if [ -f "$CACHE_FILE" ]; then
  usage_data=$(cat "$CACHE_FILE" 2>/dev/null)
fi

# Parse usage data
five_hour_pct=0
five_hour_reset=""
seven_day_pct=0
seven_day_reset=""

format_reset_time() {
  local iso=$1 style=$2
  if [ -z "$iso" ]; then return; fi
  # Strip fractional seconds and Z suffix to get bare datetime
  local bare="${iso%%.*}"
  bare="${bare%%Z}"
  if [ "$(uname)" = "Darwin" ]; then
    # Parse as UTC to get epoch, then format as local time
    local epoch
    epoch=$(TZ=UTC date -jf "%Y-%m-%dT%H:%M:%S" "$bare" "+%s" 2>/dev/null)
    if [ -z "$epoch" ]; then return; fi
    if [ "$style" = "time" ]; then
      date -r "$epoch" "+%-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    else
      date -r "$epoch" "+%b %-d, %-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    fi
  else
    # Linux: date -d handles ISO with Z natively
    if [ "$style" = "time" ]; then
      date -d "$iso" "+%-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    else
      date -d "$iso" "+%b %-d, %-l:%M%p" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    fi
  fi
}

if [ -n "$usage_data" ]; then
  five_hour_pct=$(echo "$usage_data" | jq -r '(.five_hour.utilization // 0) | round' 2>/dev/null)
  [ -z "$five_hour_pct" ] && five_hour_pct=0
  five_hour_reset_iso=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
  five_hour_reset=$(format_reset_time "$five_hour_reset_iso" "time")

  seven_day_pct=$(echo "$usage_data" | jq -r '(.seven_day.utilization // 0) | round' 2>/dev/null)
  [ -z "$seven_day_pct" ] && seven_day_pct=0
  seven_day_reset_iso=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
  seven_day_reset=$(format_reset_time "$seven_day_reset_iso" "datetime")
fi

SEP=" ${C_DIM}|${C_RESET} "

# ===== OUTPUT =====

# Directory: git repo root name, or full path if not a repo
if [ -n "$git_branch" ]; then
  dir_name=$(basename "$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)")
else
  dir_name="$cwd"
fi

# Line 0: dir on git:branch [time] [vim]
printf "\033[1;33m%s\033[0m" "$dir_name"

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
printf "%b%s / %s%b %b(%s%%)%b" "$C_ORANGE" "$used_fmt" "$total_fmt" "$C_RESET" "$C_GREEN" "$pct_used" "$C_RESET"
printf "%b" "$SEP"
printf "effort: %b%s%b" "$effort_color" "$effort_level" "$C_RESET"

# Line 2: Current (5h) bar | Weekly (7d) bar
if [ -n "$usage_data" ]; then
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
  printf "%bresets %s%b" "$C_WHITE" "$five_hour_reset" "$C_RESET"
  printf "%b" "$SEP"
  printf "%bresets %s%b" "$C_WHITE" "$seven_day_reset" "$C_RESET"
fi
