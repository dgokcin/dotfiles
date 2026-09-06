#!/bin/bash
# Custom statusline script for Claude Code
# Reads JSON input from stdin and outputs a formatted status line

# Read JSON input from stdin
input=$(cat)

# Basic info
cwd=$(echo "$input" | jq -r ".workspace.current_dir")
model=$(echo "$input" | jq -r ".model.display_name")
time=$(date +%H:%M:%S)
cost_usd=$(echo "$input" | jq -r ".cost.total_cost_usd // empty")

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

# Reasoning effort: Claude Code passes the live session value as effort.level on
# stdin (reflects mid-session /effort changes). Values: low|medium|high|xhigh|max|
# ultra. Absent when the model lacks the reasoning effort parameter (e.g. Haiku)
# → "n/a". (settings_path also reused by the auto-compact block below.)
settings_path="$HOME/.claude/settings.json"
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
[ -z "$effort_level" ] && effort_level="n/a"

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

# Codex-backed models — Claude Code as the interface, the ChatGPT/Codex backend
# behind it via the clodex proxy. The limits Claude Code puts on stdin describe
# the Anthropic account, i.e. the wrong quota, so for these models query the
# ChatGPT backend's own usage endpoint (the same one the codex CLI polls).
#
# Detection is registry-driven, not name-driven: a routed model arrives either
# as clodex:<provider>:<model> (endpoint mode) or as a bare alias like "sol"
# (patched binary — the alias IS the model id). Resolve the alias through
# ~/.clodex/config.json, then only treat it as ChatGPT-quota if the provider is
# an OAuth provider pointed at OpenAI. New models/aliases need no script edits.
model_id=$(echo "$input" | jq -r '.model.id // empty')
clodex_home="${CLODEX_HOME:-$HOME/.clodex}"
is_codex_model=0
clodex_provider=""
case "$model_id" in
clodex:*:*)
  clodex_provider=$(printf '%s' "$model_id" | cut -d: -f2)
  ;;
?*)
  if [ -f "$clodex_home/config.json" ]; then
    clodex_provider=$(jq -r --arg a "$model_id" \
      '[.modelAliases[]? | select(.name == $a) | .providerId] | first // empty' \
      "$clodex_home/config.json" 2>/dev/null)
  fi
  ;;
esac
if [ -n "$clodex_provider" ] && [ -f "$clodex_home/providers.json" ]; then
  if jq -e --arg p "$clodex_provider" \
    '[.providers[]? | select(.id == $p and .authType == "oauth")
      | (.api.url // "") | test("openai")] | first == true' \
    "$clodex_home/providers.json" >/dev/null 2>&1; then
    is_codex_model=1
  fi
fi

file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

# Codex reports each limit as a rolling window in minutes; name the two we know
# to match the labels used for Anthropic limits, derive the rest.
codex_window_label() {
  local mins=$1
  case "$mins" in
  10080) echo "weekly" ;;
  300) echo "5h" ;;
  '' | *[!0-9]*) echo "limit" ;;
  *)
    if [ "$mins" -ge 1440 ] && [ $((mins % 1440)) -eq 0 ]; then
      echo "$((mins / 1440))d"
    elif [ "$mins" -ge 60 ]; then
      echo "$((mins / 60))h"
    else
      echo "${mins}m"
    fi
    ;;
  esac
}

format_age() {
  local secs=$1
  [ "$secs" -lt 0 ] 2>/dev/null && secs=0
  if [ "$secs" -lt 60 ]; then
    echo "${secs}s ago"
  elif [ "$secs" -lt 3600 ]; then
    echo "$((secs / 60))m ago"
  elif [ "$secs" -lt 86400 ]; then
    echo "$((secs / 3600))h ago"
  else
    echo "$((secs / 86400))d ago"
  fi
}

codex_pct_primary=""
codex_label_primary=""
codex_reset_primary=""
codex_pct_secondary=""
codex_label_secondary=""
codex_reset_secondary=""
codex_as_of=""

# "$1=used_percent $2=window_minutes $3=resets_at" -> "pct<TAB>label<TAB>reset".
# Absent fields arrive as "-" (see the @tsv projection below).
codex_window_fields() {
  local pct=$1 win=$2 reset=$3 style="time" reset_fmt=""
  [ "$pct" = "-" ] && return 1
  pct=$(printf '%s' "$pct" | awk '{printf "%d", int($1 + 0.5)}')
  [ "$win" = "-" ] && win=""
  # Windows of a day or more reset far enough out that the date matters.
  if [ -n "$win" ] && [ "$win" -ge 1440 ] 2>/dev/null; then style="datetime"; fi
  [ "$reset" != "-" ] && reset_fmt=$(format_reset_time_epoch "$reset" "$style")
  printf '%s\t%s\t%s' "$pct" "$(codex_window_label "$win")" "$reset_fmt"
}

if [ "$is_codex_model" = 1 ]; then
  codex_auth="${CODEX_HOME:-$HOME/.codex}/auth.json"
  codex_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
  codex_cache="$codex_cache_dir/codex-rate-limits"

  # Live quota from the ChatGPT backend, reusing the codex CLI's token. The
  # codex CLI itself polls this endpoint once a minute, so mirror that cadence:
  # memoise for 60s. Cache holds two lines: the fetch epoch, then the tsv
  # projection. On fetch failure the last good reading survives and the "as of"
  # stamp below surfaces its age.
  codex_cache_age=99999
  if [ -f "$codex_cache" ]; then
    codex_cache_mtime=$(file_mtime "$codex_cache")
    [ -n "$codex_cache_mtime" ] && codex_cache_age=$(($(date +%s) - codex_cache_mtime))
  fi

  if [ "$codex_cache_age" -ge 60 ] && [ -f "$codex_auth" ]; then
    codex_token=$(jq -r '.tokens.access_token // empty' "$codex_auth" 2>/dev/null)
    codex_acct=$(jq -r '.tokens.account_id // empty' "$codex_auth" 2>/dev/null)
    codex_payload=""
    if [ -n "$codex_token" ] && [ -n "$codex_acct" ]; then
      # Windows come back in seconds; project to minutes so codex_window_label
      # and the cache format stay unchanged. secondary_window may be null
      # (team plans expose only the weekly window).
      codex_payload=$(curl -s --max-time 2 \
        -H "Authorization: Bearer $codex_token" \
        -H "chatgpt-account-id: $codex_acct" \
        "https://chatgpt.com/backend-api/wham/usage" 2>/dev/null | jq -r '
        .rate_limit
        | select(.primary_window.used_percent != null)
        | [.primary_window, .secondary_window]
        | map(.used_percent,
              (.limit_window_seconds | if . == null then null else . / 60 | floor end),
              .reset_at)
        | map(if . == null then "-" else tostring end) | @tsv' 2>/dev/null)
    fi
    if [ -n "$codex_payload" ] && mkdir -p "$codex_cache_dir" 2>/dev/null; then
      printf '%s\n%s\n' "$(date +%s)" "$codex_payload" >"$codex_cache" 2>/dev/null
    fi
  fi

  if [ -f "$codex_cache" ]; then
    codex_as_of=$(sed -n 1p "$codex_cache" 2>/dev/null)
    # Live polling keeps readings ≤60s old; only stamp the age once fetches
    # have been failing long enough to matter (stale token, offline).
    if [ -n "$codex_as_of" ]; then
      codex_data_age=$(($(date +%s) - codex_as_of))
      [ "$codex_data_age" -lt 300 ] 2>/dev/null && codex_as_of=""
    fi
    IFS=$'\t' read -r cx_p_pct cx_p_win cx_p_reset cx_s_pct cx_s_win cx_s_reset \
      < <(sed -n 2p "$codex_cache" 2>/dev/null)

    if codex_fields=$(codex_window_fields "${cx_p_pct:--}" "${cx_p_win:--}" "${cx_p_reset:--}"); then
      IFS=$'\t' read -r codex_pct_primary codex_label_primary codex_reset_primary <<<"$codex_fields"
    fi
    if codex_fields=$(codex_window_fields "${cx_s_pct:--}" "${cx_s_win:--}" "${cx_s_reset:--}"); then
      IFS=$'\t' read -r codex_pct_secondary codex_label_secondary codex_reset_secondary <<<"$codex_fields"
    fi
  fi

  # API-equivalent cost. Claude Code's total_cost_usd prices routed models off
  # its own Anthropic table — fiction for a ChatGPT-plan backend. Recompute
  # from the transcript's real per-message token counts at OpenAI's published
  # API rates (clodex's models.dev pricing cache). The plan itself is
  # flat-rate, so this is "what the session would cost via API key".
  transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
  session_id=$(echo "$input" | jq -r '.session_id // "nosession"')
  codex_cost=""
  codex_cost_cache="$codex_cache_dir/codex-cost-$session_id"
  codex_cost_age=99999
  if [ -f "$codex_cost_cache" ]; then
    codex_cost_mtime=$(file_mtime "$codex_cost_cache")
    [ -n "$codex_cost_mtime" ] && codex_cost_age=$(($(date +%s) - codex_cost_mtime))
  fi
  if [ "$codex_cost_age" -gt 15 ] && [ -f "$transcript_path" ]; then
    # Resolve the routed alias to the upstream model id the pricing data knows.
    case "$model_id" in
    clodex:*:*) codex_upstream=${model_id#clodex:*:} ;;
    *) codex_upstream=$(jq -r --arg a "$model_id" \
      '[.modelAliases[]? | select(.name == $a) | .modelId] | first // empty' \
      "$clodex_home/config.json" 2>/dev/null) ;;
    esac
    codex_prices=""
    if [ -n "$codex_upstream" ] && [ -f "$clodex_home/pricing-cache.json" ]; then
      codex_prices=$(jq -r --arg m "$codex_upstream" '
        [.models[] | select(.model_id == $m)] | first
        | [.pricing[]? | select(.platform == "openai" and .tier == "standard"
            and ((.notes // "") | test("long") | not))] | first
        | select(.input_per_1m_tokens != null)
        | [.input_per_1m_tokens, .cached_input_per_1m_tokens // 0, .output_per_1m_tokens // 0]
        | @tsv' "$clodex_home/pricing-cache.json" 2>/dev/null)
    fi
    if [ -n "$codex_prices" ]; then
      IFS=$'\t' read -r cx_price_in cx_price_cached cx_price_out <<<"$codex_prices"
      # fromjson? tolerates the half-written last line of a live transcript.
      # Claude Code writes one line per content block, so a single response
      # (text + tool call) repeats its usage on several lines sharing one
      # message.id — count each id once or the total nearly doubles.
      # Cache writes are billed at the plain input rate (OpenAI has no
      # separate write price); cache reads at the cached-input rate.
      codex_cost_val=$(jq -R -n --arg m "$model_id" \
        --arg pin "$cx_price_in" --arg pcached "$cx_price_cached" --arg pout "$cx_price_out" '
        [inputs | fromjson? | .message? | select(.model == $m and .usage != null)] as $all
        | ((($all | map(select(.id != null)) | unique_by(.id))
            + ($all | map(select(.id == null)))) | map(.usage)) as $u
        | ( (($u | map(.input_tokens // 0) | add // 0)
             + ($u | map(.cache_creation_input_tokens // 0) | add // 0)) * ($pin | tonumber)
          + ($u | map(.cache_read_input_tokens // 0) | add // 0) * ($pcached | tonumber)
          + ($u | map(.output_tokens // 0) | add // 0) * ($pout | tonumber) ) / 1e6' \
        <"$transcript_path" 2>/dev/null)
      if [ -n "$codex_cost_val" ] && mkdir -p "$codex_cache_dir" 2>/dev/null; then
        printf '%s\n' "$codex_cost_val" >"$codex_cost_cache" 2>/dev/null
      fi
    fi
  fi
  [ -f "$codex_cost_cache" ] && codex_cost=$(head -1 "$codex_cost_cache" 2>/dev/null)
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

# For codex-backed models replace Claude Code's Anthropic-priced figure with
# the API-equivalent estimate; if that couldn't be computed, show nothing
# rather than a made-up number.
if [ "$is_codex_model" = 1 ]; then
  if [ -n "$codex_cost" ]; then
    cost_fmt="~$(format_cost "$codex_cost") api"
  else
    cost_fmt=""
  fi
fi

SEP=" ${C_DIM}|${C_RESET} "

# ===== OUTPUT =====

# Terminal width for truncation (fallback 80)
term_cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"

# Truncate string to max length, appending … if cut
truncate_str() {
  local str=$1 max=$2
  if [ "${#str}" -gt "$max" ]; then
    echo "${str:0:$((max - 1))}…"
  else
    echo "$str"
  fi
}

# Worktree context
worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')

# Repo name: extract from git remote, fallback to directory name
if [ -n "$git_branch" ]; then
  # Try to get repo name from remote.origin.url
  remote_url=$(git -C "$cwd" --no-optional-locks config --get remote.origin.url 2>/dev/null)
  if [ -n "$remote_url" ]; then
    # Extract repo name: handle https://host/user/repo.git and git@host:user/repo.git formats
    dir_name=$(basename "$remote_url" .git | awk -F'[:/@]' '{print $NF}')
  else
    dir_name=$(basename "$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)")
  fi
else
  dir_name="$cwd"
fi

# Line 0: dir on git:branch [time] [vim]
# Fixed overhead: " on git: x [HH:MM:SS]" = ~23 chars
# Worktree mode adds " / " = 3 more
# Budget names to fit within terminal width
time_field=" [${time}]"                        # 11 chars
fixed_overhead=$((${#time_field} + 4 + 4 + 2)) # " on " + "git:" + " x"
if [ -n "$worktree_name" ]; then
  # repo / worktree on git:branch — split remaining budget 40/60
  name_budget=$((term_cols - fixed_overhead - 3)) # 3 for " / "
  repo_budget=$((name_budget * 2 / 5))
  [ "$repo_budget" -lt 8 ] && repo_budget=8
  wt_budget=$((name_budget * 2 / 5))
  [ "$wt_budget" -lt 8 ] && wt_budget=8
  branch_budget=$((name_budget - repo_budget - wt_budget))
  [ "$branch_budget" -lt 8 ] && branch_budget=8

  repo_name=$(echo "$input" | jq -r '.worktree.original_cwd // empty' | xargs basename 2>/dev/null)
  [ -z "$repo_name" ] && repo_name="$dir_name"
  repo_name=$(truncate_str "$repo_name" "$repo_budget")
  worktree_disp=$(truncate_str "$worktree_name" "$wt_budget")
  branch_disp=$(truncate_str "$git_branch" "$branch_budget")

  printf "\033[1;33m%s\033[0m" "$repo_name"
  printf " ${C_DIM}/${C_RESET} "
  printf "\033[1;33m%s\033[0m" "$worktree_disp"
else
  name_budget=$((term_cols - fixed_overhead))
  dir_budget=$((name_budget / 2))
  [ "$dir_budget" -lt 8 ] && dir_budget=8
  branch_budget=$((name_budget - dir_budget))
  [ "$branch_budget" -lt 8 ] && branch_budget=8

  dir_disp=$(truncate_str "$dir_name" "$dir_budget")
  branch_disp=$(truncate_str "$git_branch" "$branch_budget")
  printf "\033[1;33m%s\033[0m" "$dir_disp"
fi

if [ -n "$git_branch" ]; then
  printf " on "
  printf "\033[34mgit\033[0m:"
  printf "\033[36m%s\033[0m" "$branch_disp"
  if [ "$git_status" = "x" ]; then
    printf " \033[31mx\033[0m"
  else
    printf " \033[32mo\033[0m"
  fi
fi

printf "%s" "$time_field"

if [ -n "$vim_mode" ]; then
  printf "\033[33m%s\033[0m" "$vim_mode"
fi

# Line 1: Model | tokens used/total (%) | effort
# Display label differs from stored value: /effort ultracode is stored as
# "ultra" on stdin; show the friendlier "ultracode" label.
effort_disp="$effort_level"
[ "$effort_level" = "ultra" ] && effort_disp="ultracode"

effort_color="$C_DIM"
case "$effort_level" in
high | xhigh | max | ultra) effort_color="$C_RED" ;;
medium) effort_color="$C_ORANGE" ;;
low) effort_color="$C_GREEN" ;;
auto) effort_color="$C_CYAN" ;;
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
printf "effort: %b%s%b" "$effort_color" "$effort_disp" "$C_RESET"

# Line 2: usage bars | Line 3: reset times.
# Codex-backed models poll the ChatGPT usage endpoint (see above); everything
# else uses the rate limits Claude Code puts on stdin.
if [ "$is_codex_model" = 1 ]; then
  if [ -n "$codex_pct_primary" ] || [ -n "$codex_pct_secondary" ]; then
    printf "\n"
    printf "%bcodex%b" "$C_ORANGE" "$C_RESET"
    if [ -n "$codex_pct_primary" ]; then
      printf " %b%s:%b " "$C_WHITE" "$codex_label_primary" "$C_RESET"
      build_bar "$codex_pct_primary" 10
      printf " %b%s%%%b" "$C_CYAN" "$codex_pct_primary" "$C_RESET"
    fi
    if [ -n "$codex_pct_secondary" ]; then
      printf "%b" "$SEP"
      printf "%b%s:%b " "$C_WHITE" "$codex_label_secondary" "$C_RESET"
      build_bar "$codex_pct_secondary" 10
      printf " %b%s%%%b" "$C_CYAN" "$codex_pct_secondary" "$C_RESET"
    fi

    if [ -n "$codex_reset_primary" ] || [ -n "$codex_reset_secondary" ] || [ -n "$codex_as_of" ]; then
      printf "\n"
      printf "%bresets:%b" "$C_WHITE" "$C_RESET"
      reset_sep=" "
      if [ -n "$codex_reset_primary" ]; then
        printf " %s @ %s" "$codex_label_primary" "$codex_reset_primary"
        reset_sep="$SEP"
      fi
      if [ -n "$codex_reset_secondary" ]; then
        printf "%b%s @ %s" "$reset_sep" "$codex_label_secondary" "$codex_reset_secondary"
      fi
      if [ -n "$codex_as_of" ]; then
        # Only set when fetches have been failing >5m (stale token, offline).
        codex_age=$(($(date +%s) - codex_as_of))
        age_color="$C_DIM"
        [ "$codex_age" -ge 7200 ] && age_color="$C_YELLOW"
        printf "%b" "$SEP"
        printf "%bas of %s%b" "$age_color" "$(format_age "$codex_age")" "$C_RESET"
      fi
    fi
  else
    printf "\n"
    printf "%bcodex:%b %bno limit data — check %s%b" \
      "$C_ORANGE" "$C_RESET" "$C_DIM" "${CODEX_HOME:-~/.codex}/auth.json" "$C_RESET"
  fi
elif [ -n "$five_hour_pct_raw" ]; then
  printf "\n"
  printf "%bcurrent:%b " "$C_WHITE" "$C_RESET"
  build_bar "$five_hour_pct" 10
  printf " %b%s%%%b" "$C_CYAN" "$five_hour_pct" "$C_RESET"
  printf "%b" "$SEP"
  printf "%bweekly:%b " "$C_WHITE" "$C_RESET"
  build_bar "$seven_day_pct" 10
  printf " %b%s%%%b" "$C_CYAN" "$seven_day_pct" "$C_RESET"

  printf "\n"
  printf "%bresets:%b 5h @ %s" "$C_WHITE" "$C_RESET" "$five_hour_reset"
  printf "%b" "$SEP"
  printf "7d @ %s" "$seven_day_reset"
fi

# Line 4: active mode plugins (caveman / ponytail / adhd)
# Each plugin records its state as a flag file in the config dir. Contents are
# the level (e.g. full/ultra); an empty file just means on (adhd's always-on
# flag). Symlinks are skipped so a dangling/hostile link can't be read.
# The flag file survives disabling the plugin, so also honour enabledPlugins in
# settings.json: explicitly false hides the mode, absent means enabled.
config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
disabled_plugins=""
if [ -f "$settings_path" ]; then
  disabled_plugins=$(jq -r '.enabledPlugins // {} | to_entries[] | select(.value == false) | .key | split("@")[0]' "$settings_path" 2>/dev/null | tr '\n' ' ')
fi

mode_line=""
for entry in "caveman:.caveman-active:caveman" "ponytail:.ponytail-active:ponytail" "adhd:.i-have-adhd-always:i-have-adhd"; do
  IFS=: read -r mode_label mode_file mode_plugin <<<"$entry"
  case " $disabled_plugins " in *" $mode_plugin "*) continue ;; esac

  mode_flag="$config_dir/$mode_file"
  [ -L "$mode_flag" ] && continue
  [ -f "$mode_flag" ] || continue

  mode_val=$(head -c 64 "$mode_flag" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
  mode_val=$(printf '%s' "$mode_val" | tr -cd 'a-z0-9-')
  [ -z "$mode_val" ] && mode_val="on"
  [ "$mode_val" = "off" ] && continue

  mode_line="${mode_line:+$mode_line$SEP}${C_WHITE}${mode_label}${C_RESET}: ${C_ORANGE}${mode_val}${C_RESET}"
done
if [ -n "$mode_line" ]; then
  printf "\n%b" "$mode_line"
fi
