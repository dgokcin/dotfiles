#!/bin/bash
# Custom statusline script for Claude Code.
#
# Claude Code is only the interface. The model behind a session may be
# Anthropic's own API, or a third-party backend routed through the clodex proxy
# (ChatGPT over OAuth, OpenCode Go over an API key, ...). Each backend has its
# own notion of "quota" and its own price list, so this script resolves the real
# upstream provider for the session and renders only what that provider can
# actually support. Showing nothing beats showing another account's numbers.
#
# The render path performs no network I/O and reads no logs: every expensive
# value lives in $cache_dir and is refreshed by a detached `--refresh`
# re-invocation of this same script.
#
# Usage:
#   statusline.sh                 render (reads the session JSON on stdin)
#   statusline.sh --refresh KIND  background cache refresh; prints nothing

settings_path="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
clodex_home="${CLODEX_HOME:-$HOME/.clodex}"
clodex_providers="$clodex_home/providers.json"
clodex_config="$clodex_home/config.json"
clodex_pricing="$clodex_home/pricing-cache.json"
clodex_sessions="$clodex_home/logs/sessions"

# ===== value sanitisers =====
# Everything that reaches arithmetic goes through these: jq can hand back "",
# "null" or a float, and bare $(( )) on any of those prints a bash error into
# the statusline.

to_int() {
  local v=$1 d=${2-0}
  case "$v" in
  '' | *[!0-9]*) printf '%s' "$d" ;;
  *) printf '%s' "$v" ;;
  esac
}

to_num() {
  local v=$1 d=${2-0}
  if [[ $v =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then printf '%s' "$v"; else printf '%s' "$d"; fi
}

file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

# Model-scoped windows report resets_at as an ISO string, unlike the epoch the
# five_hour/seven_day windows use. Seconds precision is enough; drop any
# fractional part and trailing zone, and read it as UTC.
iso_to_epoch() {
  local iso=$1 base
  case "$iso" in
  ????-??-??T??:??:??*) base=${iso:0:19} ;;
  *) return 0 ;;
  esac
  if [ "$(uname)" = "Darwin" ]; then
    date -j -u -f "%Y-%m-%dT%H:%M:%S" "$base" +%s 2>/dev/null
  else
    date -u -d "${base}Z" +%s 2>/dev/null
  fi
}

epoch_to_iso() {
  if [ "$(uname)" = "Darwin" ]; then
    date -u -r "$1" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null
  else
    date -u -d "@$1" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null
  fi
}

# ===== cache primitives =====
# Line 1 of every cache file is the write epoch, line 2 the value. Keeping the
# stamp inside the file (rather than trusting mtime alone) lets the renderer
# show how stale a reading is when refreshes have been failing.

cache_age() {
  local f=$1 m
  [ -f "$f" ] || {
    printf '99999999'
    return
  }
  m=$(file_mtime "$f")
  [ -n "$m" ] || {
    printf '99999999'
    return
  }
  printf '%s' "$(($(date +%s) - m))"
}

cache_value() { sed -n 2p "$1" 2>/dev/null; }
cache_stamp() { sed -n 1p "$1" 2>/dev/null; }

cache_write() {
  local f=$1 v=$2
  mkdir -p "$cache_dir" 2>/dev/null || return 1
  printf '%s\n%s\n' "$(date +%s)" "$v" >"$f" 2>/dev/null
}

# Run a refresh detached so the render never waits on it. The child's stdout
# MUST be redirected: Claude Code reads this script's stdout to EOF, and an
# inherited descriptor would hold that open until the refresh finished. The
# mkdir lock keeps concurrent renders from spawning a pile of refreshers; a lock
# older than two minutes is treated as abandoned.
spawn_refresh() {
  local key=$1
  shift
  local lock="$cache_dir/.lock-$key" lm
  mkdir -p "$cache_dir" 2>/dev/null || return 0
  if [ -d "$lock" ]; then
    lm=$(file_mtime "$lock")
    if [ -n "$lm" ] && [ "$(($(date +%s) - lm))" -lt 120 ]; then return 0; fi
    rmdir "$lock" 2>/dev/null
  fi
  mkdir "$lock" 2>/dev/null || return 0
  (
    trap '' HUP
    "$0" --refresh "$@"
    rmdir "$lock" 2>/dev/null
  ) >/dev/null 2>&1 &
  disown 2>/dev/null
  return 0
}

# ===== settings =====
# Claude Code does not export its settings env block to the statusline process,
# so read it back from settings.json. A real environment variable still wins.
settings_env() {
  local key=$1
  local val="${!key:-}"
  if [ -z "$val" ] && [ -f "$settings_path" ]; then
    val=$(jq -r --arg k "$key" '.env[$k] // empty' "$settings_path" 2>/dev/null)
  fi
  printf '%s' "$val"
}

# ===== provider resolution =====

# The model id Claude Code reports carries a context marker on 1M-context models
# ("clodex:opencode-go:minimax-m3[1m]"). Transcripts and the clodex registries
# record the bare id, so strip it before any lookup.
strip_ctx_marker() {
  local mid=$1
  printf '%s' "${mid%\[*\]}"
}

# The id a price list knows the model by: routed ids embed it, bare aliases have
# to be resolved through the alias table.
upstream_model_id() {
  local mid=$1 a=""
  case "$mid" in
  clodex:*:*) printf '%s' "${mid#clodex:*:}" ;;
  anthropic-*__*) printf '%s' "${mid##*__}" ;;
  *)
    [ -f "$clodex_config" ] && a=$(jq -r --arg a "$mid" \
      '[.modelAliases[]? | select(.name == $a) | .modelId] | first // empty' \
      "$clodex_config" 2>/dev/null)
    printf '%s' "${a:-$mid}"
    ;;
  esac
}

# "<provider>\t<route>\t<source>". Source records how confident we are, which
# decides cacheability: an id that spells out its provider, or a clodex session
# log entry, is ground truth; an alias lookup is a guess that can go stale.
#
# Order is cheapest-authoritative first. The session log is consulted only for
# bare aliases, because that is the one form the id cannot answer: aliases are
# optional (kimi-k3 has none) and ambiguous (gpt-5.6-luna exists under two
# providers, while the alias "luna" names only one of them).
resolve_provider() {
  local sid=$1 mid=$2 mraw=$3 p="" found="" alias_p="" guess="" memo="" memo_key="" f
  case "$mid" in
  claude-*)
    printf 'anthropic\tpassthrough\tid'
    return
    ;;
  clodex:*:*)
    p=${mid#clodex:}
    printf '%s\ttranslated\tid' "${p%%:*}"
    return
    ;;
  anthropic-*__*)
    p=${mid#anthropic-}
    printf '%s\ttranslated\tid' "${p%%__*}"
    return
    ;;
  esac

  # Memo key includes the model: a single session routes several of them (a
  # background Haiku call goes to Anthropic while the foreground model does not),
  # so a per-session answer would be wrong as soon as /model is used.
  memo_key="provider-$sid-$(printf '%s' "$mid" | tr -c 'A-Za-z0-9._-' '_')"

  # A cached answer sourced from the session log is ground truth and never
  # expires. A guess (alias table, or the anthropic default) is memoised only
  # briefly: the log entry for a fresh session may not have been written yet, so
  # the guess has to be allowed to heal.
  if [ -n "$sid" ] && [ -f "$cache_dir/$memo_key" ]; then
    memo=$(cache_value "$cache_dir/$memo_key")
    case "$memo" in
    *"	log")
      printf '%s' "$memo"
      return
      ;;
    ?*)
      if [ "$(cache_age "$cache_dir/$memo_key")" -lt 60 ]; then
        printf '%s' "$memo"
        return
      fi
      ;;
    esac
  fi

  if [ -n "$sid" ] && [ -d "$clodex_sessions" ]; then
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      # Cheap literal prefilter before paying for a jq pass over the file.
      grep -qF -- "$sid" "$f" 2>/dev/null || continue
      # Filter on the model too. Claude Code issues background requests (title
      # generation, etc.) on a different model inside the same session, and
      # those are logged as anthropic/passthrough — taking the last line for the
      # session alone lets one of them hijack the whole statusline.
      found=$(jq -R -r --arg s "$sid" --arg m "$mid" --arg mraw "$mraw" \
        'fromjson? | select(.claudeSessionId == $s
           and ((.modelId // "") | . == $m or . == $mraw))
         | [(.provider // "-"), (.route // "-")] | @tsv' "$f" 2>/dev/null | tail -1)
      [ -n "$found" ] && break
    done < <(ls -t "$clodex_sessions"/*.jsonl 2>/dev/null | head -20)
  fi
  if [ -n "$found" ]; then
    found=$(printf '%s\tlog' "$found")
    [ -n "$sid" ] && cache_write "$cache_dir/$memo_key" "$found"
    printf '%s' "$found"
    return
  fi

  [ -f "$clodex_config" ] && alias_p=$(jq -r --arg a "$mid" \
    '[.modelAliases[]? | select(.name == $a) | .providerId] | first // empty' \
    "$clodex_config" 2>/dev/null)
  if [ -n "$alias_p" ]; then
    guess=$(printf '%s\ttranslated\talias' "$alias_p")
  else
    guess=$(printf 'anthropic\tpassthrough\tdefault')
  fi
  [ -n "$sid" ] && cache_write "$cache_dir/$memo_key" "$guess"
  printf '%s' "$guess"
}

# Map a provider onto the behaviour family that decides its quota surface and
# price list. Driven by providers.json rather than by provider name, so adding a
# backend to clodex needs no edit here — and an unrecognised one lands in
# "routed", which renders no quota at all instead of somebody else's.
provider_family() {
  local pid=$1 route=$2 info ptype purl
  if [ -z "$pid" ] || [ "$pid" = "anthropic" ] || [ "$route" = "passthrough" ]; then
    printf 'anthropic'
    return
  fi
  [ -f "$clodex_providers" ] || {
    printf 'routed'
    return
  }
  info=$(jq -r --arg p "$pid" \
    '[.providers[]? | select(.id == $p) | [(.authType // ""), (.api.url // "")]]
     | first // ["", ""] | @tsv' "$clodex_providers" 2>/dev/null)
  IFS=$'\t' read -r ptype purl <<<"$info"
  case "$purl" in
  *opencode.ai*)
    printf 'opencode'
    return
    ;;
  *openai*)
    if [ "$ptype" = "oauth" ]; then
      printf 'chatgpt'
      return
    fi
    ;;
  esac
  printf 'routed'
}

# "<input>\t<cached>\t<output>" per 1M tokens, empty when unknown.
#
# The source has to differ per family. pricing-cache.json has no opencode
# platform at all (kimi-k3 has no rows; the deepseek rows are aggregator prices,
# not what opencode charges), so routed providers are priced from the registry
# clodex keeps for them. The reverse holds for openai-oauth, whose registry
# costs are credit-weighted rather than dollars — that one keeps using the
# published API rates, which is what "API-equivalent cost" means.
resolve_prices() {
  local family=$1 pid=$2 mid=$3 upstream
  upstream=$(upstream_model_id "$mid")
  [ -n "$upstream" ] || return 0
  case "$family" in
  chatgpt)
    [ -f "$clodex_pricing" ] || return 0
    jq -r --arg m "$upstream" '
      [.models[] | select(.model_id == $m)] | first
      | [.pricing[]? | select(.platform == "openai" and .tier == "standard"
          and ((.notes // "") | test("long") | not))] | first
      | select(.input_per_1m_tokens != null)
      | [.input_per_1m_tokens, .cached_input_per_1m_tokens // 0, .output_per_1m_tokens // 0]
      | @tsv' "$clodex_pricing" 2>/dev/null
    ;;
  opencode | routed)
    [ -f "$clodex_providers" ] || return 0
    jq -r --arg p "$pid" --arg m "$upstream" '
      [.providers[]? | select(.id == $p) | .modelsCache.models[]?
       | select(.id == $m or .upstreamModelId == $m) | .cost] | first
      | select(. != null and .input != null)
      | [.input, .cache_read // 0, .output // 0] | @tsv' "$clodex_providers" 2>/dev/null
    ;;
  esac
}

# CODEX_HOME is per-shell (the `cxp` helper points it at the personal account)
# and the statusline process never inherits it, so probe the known homes. We
# cannot tell which one the session actually used; labelling the reading when
# more than one exists at least makes the number attributable instead of
# silently claiming to be the active account.
codex_home="" codex_label=""
resolve_codex_home() {
  local h found=0
  if [ -n "${CODEX_HOME:-}" ]; then
    codex_home="$CODEX_HOME"
    return
  fi
  for h in "$HOME/.codex" "$HOME/.codex-personal"; do
    [ -f "$h/auth.json" ] || continue
    found=$((found + 1))
    [ -z "$codex_home" ] && codex_home="$h"
  done
  if [ "$found" -gt 1 ]; then
    case "$codex_home" in
    *".codex-"*) codex_label=${codex_home##*.codex-} ;;
    *) codex_label="default" ;;
    esac
  fi
}

# ===== background refresh workers =====
# These run detached, never write to stdout, and only ever replace a cache file
# on success — a failed fetch leaves the last good reading in place.

# Live ChatGPT quota, reusing the codex CLI's token. The codex CLI polls this
# endpoint once a minute; the 60s cache TTL mirrors that.
refresh_quota() {
  local home=$1 acct=$2 token payload
  local auth="$home/auth.json"
  [ -f "$auth" ] || return 0
  token=$(jq -r '.tokens.access_token // empty' "$auth" 2>/dev/null)
  [ -n "$token" ] && [ -n "$acct" ] || return 0
  # Windows come back in seconds; project to minutes so codex_window_label and
  # the cache format stay unchanged. secondary_window may be null (team plans
  # expose only the weekly window). Absent fields become "-".
  payload=$(curl -s --max-time 5 \
    -H "Authorization: Bearer $token" \
    -H "chatgpt-account-id: $acct" \
    "https://chatgpt.com/backend-api/wham/usage" 2>/dev/null | jq -r '
    .rate_limit
    | select(.primary_window.used_percent != null)
    | [.primary_window, .secondary_window]
    | map(.used_percent,
          (.limit_window_seconds | if . == null then null else . / 60 | floor end),
          .reset_at)
    | map(if . == null then "-" else tostring end) | @tsv' 2>/dev/null)
  [ -n "$payload" ] && cache_write "$cache_dir/quota-$acct" "$payload"
  return 0
}

# Rolling spend for a routed provider. OpenCode Go exposes no quota endpoint of
# any kind — its limits surface only inside 429 bodies — so the closest honest
# substitute is what the sessions actually cost, summed from clodex's own
# per-request usage log and priced from the provider registry.
#
# Each request logs its usage twice (usageStage message_start, then
# message_delta with the final output count), so group by requestId and keep the
# last line or the total roughly doubles.
refresh_spend() {
  local provider=$1 days=$2
  local out="$cache_dir/spend-$provider-${days}d"
  local now cutoff_epoch cutoff prices total f m
  local files=()
  [ -d "$clodex_sessions" ] || return 0
  now=$(date +%s)
  cutoff_epoch=$((now - days * 86400))
  cutoff=$(epoch_to_iso "$cutoff_epoch")
  [ -n "$cutoff" ] || return 0
  for f in "$clodex_sessions"/*.jsonl; do
    [ -f "$f" ] || continue
    m=$(file_mtime "$f")
    [ -n "$m" ] || continue
    [ "$m" -ge "$cutoff_epoch" ] && files+=("$f")
  done
  if [ "${#files[@]}" -eq 0 ]; then
    cache_write "$out" "0"
    return 0
  fi
  prices=$(jq -c --arg p "$provider" \
    '[.providers[]? | select(.id == $p) | .modelsCache.models[]?
      | {key: .id, value: (.cost // {})}] | from_entries' \
    "$clodex_providers" 2>/dev/null)
  [ -n "$prices" ] || prices='{}'
  # Cache writes bill at the plain input rate (these providers publish no
  # separate write price); cache reads at the cache_read rate.
  #
  # Emits "<total>\x1f<requests>\x1f<top model by spend>": on a cheap model the
  # dollar figure alone is close to meaningless, so the volume and what is
  # actually burning it carry the line.
  total=$(cat "${files[@]}" 2>/dev/null | jq -R -r -n \
    --arg p "$provider" --arg cut "$cutoff" --argjson prices "$prices" '
    [inputs | fromjson?
     | select(.event == "response_usage" and .provider == $p and .timestamp >= $cut)]
    | group_by(.requestId) | map(.[-1])
    | map(. + {cost: (($prices[.modelId] // {}) as $c
          | ((((.inputTokens // 0) + (.cacheCreationInputTokens // 0)) * ($c.input // 0))
             + ((.cacheReadInputTokens // 0) * ($c.cache_read // 0))
             + ((.outputTokens // 0) * ($c.output // 0))) / 1e6)})
    | (map(.cost) | add // 0) as $total
    | ((group_by(.modelId)
        | map({m: .[0].modelId, c: (map(.cost) | add // 0)})
        | sort_by(-.c) | first) // {m: "-", c: 0}) as $top
    | [($total | tostring),
       (length | tostring),
       ($top.m // "-"),
       (if $total > 0 then (($top.c / $total * 100) | floor | tostring) else "-" end)]
    | join("\u001f")' 2>/dev/null)
  [ -n "$total" ] && cache_write "$out" "$total"
  return 0
}

# Real server-side quota for an OpenCode-style provider. The inference base
# exposes /usage next to the chat endpoints, authenticated by the same API key
# (the console's own API is a separate, session-cookie system and is not usable
# here). The URL comes from the provider registry rather than a constant, so a
# rehosted or self-hosted base needs no edit.
#
# Windows: rolling (the 5-hour one), weekly, monthly. Emits nine US-separated
# fields, percent/resetsAt/status per window, with "-" for anything absent.
refresh_ocusage() {
  local provider=$1 url key payload
  local auth="${OPENCODE_AUTH_JSON:-$HOME/.local/share/opencode/auth.json}"
  [ -f "$auth" ] && [ -f "$clodex_providers" ] || return 0
  url=$(jq -r --arg p "$provider" \
    '[.providers[]? | select(.id == $p) | .api.url // ""] | first // empty' \
    "$clodex_providers" 2>/dev/null)
  [ -n "$url" ] || return 0
  # clodex keeps the key in the keychain; opencode's own auth file is the
  # plaintext copy. Fall back to the canonical id when the clodex provider has
  # been renamed locally.
  key=$(jq -r --arg p "$provider" '(.[$p].key // .["opencode-go"].key) // empty' \
    "$auth" 2>/dev/null)
  [ -n "$key" ] || return 0
  payload=$(curl -s --max-time 5 -H "Authorization: Bearer $key" \
    "${url%/}/usage" 2>/dev/null | jq -r '
    .usage | select(. != null)
    | [(.rolling, .weekly, .monthly)
       | [(.percent | if . == null then "-" else tostring end),
          (.resetsAt // "-"),
          (.status // "-")]]
    | flatten | join("\u001f")' 2>/dev/null)
  [ -n "$payload" ] && cache_write "$cache_dir/ocusage-$provider" "$payload"
  return 0
}

# API-equivalent session cost. Claude Code's own total_cost_usd prices every
# model off its Anthropic table, which is fiction for a routed backend, so
# recompute from the transcript's real per-message token counts at the rates
# resolve_prices found. The plan itself is flat-rate; this is "what this session
# would have cost through an API key".
#
# fromjson? tolerates the half-written last line of a live transcript. Claude
# Code writes one line per content block, so a single response (text + tool
# call) repeats its usage across several lines sharing one message.id — count
# each id once or the total nearly doubles.
refresh_cost() {
  local sid=$1 transcript=$2 mid=$3 mraw=$4 pin=$5 pcached=$6 pout=$7 val
  [ -n "$sid" ] && [ -f "$transcript" ] || return 0
  val=$(jq -R -n --arg m "$mid" --arg mraw "$mraw" \
    --arg pin "$pin" --arg pcached "$pcached" --arg pout "$pout" '
    [inputs | fromjson? | .message?
     | select(. != null and .usage != null and (.model == $m or .model == $mraw))] as $all
    | ((($all | map(select(.id != null)) | unique_by(.id))
        + ($all | map(select(.id == null)))) | map(.usage)) as $u
    | ((($u | map(.input_tokens // 0) | add // 0)
        + ($u | map(.cache_creation_input_tokens // 0) | add // 0)) * ($pin | tonumber)
       + ($u | map(.cache_read_input_tokens // 0) | add // 0) * ($pcached | tonumber)
       + ($u | map(.output_tokens // 0) | add // 0) * ($pout | tonumber)) / 1e6' \
    <"$transcript" 2>/dev/null)
  [ -n "$val" ] && cache_write "$cache_dir/cost-$sid" "$val"
  return 0
}

# Session-scoped caches land one file per session id, so the directory would
# otherwise grow forever. Pruning rides along on a refresh, which is already
# detached and off the render path.
prune_cache() {
  [ -d "$cache_dir" ] || return 0
  find "$cache_dir" -maxdepth 1 -type f -mtime +7 -delete 2>/dev/null
  find "$cache_dir" -maxdepth 1 -type d -name '.lock-*' -mtime +1 -exec rmdir {} + 2>/dev/null
  return 0
}

if [ "${1:-}" = "--refresh" ]; then
  case "${2:-}" in
  quota) refresh_quota "${3:-}" "${4:-}" ;;
  spend) refresh_spend "${3:-}" "$(to_int "${4:-}" 30)" ;;
  ocusage) refresh_ocusage "${3:-}" ;;
  cost) refresh_cost "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-0}" "${8:-0}" "${9:-0}" ;;
  esac
  prune_cache
  exit 0
fi

# ===== render =====

input=$(cat)

# One jq pass for the whole session blob. Previously this was ~20 separate forks
# re-parsing the same JSON, each able to fail independently.
#
# One field per LINE. Not @tsv + `read`: tab counts as IFS whitespace, so `read`
# collapses runs of tabs into a single delimiter and every null field (absent
# effort, absent cache_creation, a plan with no seven_day window) silently shifts
# all later values one slot left — reset epochs land in token counts and
# percentages. `IFS= read` per line keeps empty fields as empty fields.
# (Not mapfile: /bin/bash on macOS is 3.2, which does not have it.)
sl_fields=()
while IFS= read -r sl_line || [ -n "$sl_line" ]; do
  sl_fields+=("$sl_line")
done < <(printf '%s' "$input" | jq -r '
  def s: if . == null then "" else tostring | gsub("[\n\r\t]"; " ") end;
  (.workspace.current_dir | s),
  (.model.display_name | s),
  (.model.id | s),
  (.session_id | s),
  (.transcript_path | s),
  (.cost.total_cost_usd | s),
  (.effort.level | s),
  (.context_window.context_window_size | s),
  (.context_window.current_usage.input_tokens | s),
  (.context_window.current_usage.cache_creation_input_tokens | s),
  (.context_window.current_usage.cache_read_input_tokens | s),
  (.rate_limits.five_hour.used_percentage | s),
  (.rate_limits.five_hour.resets_at | s),
  (.rate_limits.seven_day.used_percentage | s),
  (.rate_limits.seven_day.resets_at | s),
  (.worktree.name | s),
  (.worktree.original_cwd | s),
  ([.rate_limits.model_scoped[]?
    | [(.display_name // "-"),
       (.utilization | if . == null then "-" else tostring end),
       (.resets_at | if . == null then "-" else tostring end)]
    | join("\u001f")] | join("\u001e"))' 2>/dev/null)

cwd=${sl_fields[0]-}
model_display=${sl_fields[1]-}
model_id_raw=${sl_fields[2]-}
session_id=${sl_fields[3]-}
transcript_path=${sl_fields[4]-}
cost_usd=${sl_fields[5]-}
effort_level=${sl_fields[6]-}
ctx_size=${sl_fields[7]-}
tok_in=${sl_fields[8]-}
tok_cc=${sl_fields[9]-}
tok_cr=${sl_fields[10]-}
rl5_pct=${sl_fields[11]-}
rl5_reset=${sl_fields[12]-}
rl7_pct=${sl_fields[13]-}
rl7_reset=${sl_fields[14]-}
worktree_name=${sl_fields[15]-}
worktree_orig=${sl_fields[16]-}
model_scoped_raw=${sl_fields[17]-}

model_id=$(strip_ctx_marker "$model_id_raw")
# Routed models do not always carry a display name; the id is better than a gap.
[ -n "$model_display" ] || model_display="$model_id"
time=$(date +%H:%M:%S)

# Reasoning effort: Claude Code passes the live session value as effort.level
# (reflects mid-session /effort changes). Values: low|medium|high|xhigh|max|
# ultra. Absent when the model lacks the reasoning effort parameter (e.g. Haiku).
[ -z "$effort_level" ] && effort_level="n/a"

# Git info
git_branch=""
git_status=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
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

# Token calculations
ctx_size=$(to_int "$ctx_size" 200000)
current_tokens=$(($(to_int "$tok_in") + $(to_int "$tok_cc") + $(to_int "$tok_cr")))

format_tokens() {
  local num
  num=$(to_int "$1")
  if [ "$num" -ge 1000000 ]; then
    echo "$(echo "scale=1; $num / 1000000" | bc)m"
  elif [ "$num" -ge 1000 ]; then
    echo "$((num / 1000))k"
  else
    echo "$num"
  fi
}

used_fmt=$(format_tokens "$current_tokens")
total_fmt=$(format_tokens "$ctx_size")
if [ "$ctx_size" -gt 0 ]; then
  pct_used=$((current_tokens * 100 / ctx_size))
else
  pct_used=0
fi

# Auto-compact: remaining tokens until trigger
ac_window=$(to_int "$(settings_env CLAUDE_CODE_AUTO_COMPACT_WINDOW)" "$ctx_size")
ac_pct=$(to_int "$(settings_env CLAUDE_AUTOCOMPACT_PCT_OVERRIDE)" 95)
[ "$ac_window" -le 0 ] && ac_window="$ctx_size"
# Cap window to actual context if larger
[ "$ac_window" -gt "$ctx_size" ] && ac_window="$ctx_size"

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
SEP=" ${C_DIM}|${C_RESET} "

# Build progress bar
# mode "cost" (default): filling up is bad, ramp green -> red. mode "value":
# filling up is good (you are getting what you pay for), so the ramp inverts and
# under-use is dim rather than alarming.
build_bar() {
  local pct width=$2 mode=${3:-cost}
  pct=$(to_int "$1")
  local true_pct=$pct
  [ "$pct" -gt 100 ] && pct=100
  local filled=$((pct * width / 100))
  local empty=$((width - filled))

  local bar_color="$C_GREEN"
  if [ "$mode" = "value" ]; then
    bar_color="$C_DIM"
    [ "$true_pct" -ge 50 ] && bar_color="$C_YELLOW"
    [ "$true_pct" -ge 100 ] && bar_color="$C_GREEN"
  elif [ "$pct" -ge 90 ]; then
    bar_color="$C_RED"
  elif [ "$pct" -ge 70 ]; then
    bar_color="$C_YELLOW"
  elif [ "$pct" -ge 50 ]; then
    bar_color="$C_ORANGE"
  fi

  local filled_str="" empty_str="" i
  for ((i = 0; i < filled; i++)); do filled_str+="●"; done
  for ((i = 0; i < empty; i++)); do empty_str+="○"; done

  printf "%b%s%b%s%b" "$bar_color" "$filled_str" "$C_DIM" "$empty_str" "$C_RESET"
}

format_reset_time_epoch() {
  local epoch=$1 style=$2
  [ -n "$epoch" ] || return 0
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

format_age() {
  local secs
  secs=$(to_int "$1")
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

# Whole-dollar amounts (budgets, window totals) — cents are enough here.
format_money() {
  local raw
  raw=$(to_num "$1" "")
  [ -n "$raw" ] || return 0
  echo "$raw" | awk '{printf "$%.2f", $1 + 0}' | sed 's/\.00$//'
}

# Format cost as $X.XXXX (4 decimal places), dropping trailing zeros after 2
format_cost() {
  local raw
  raw=$(to_num "$1" "")
  [ -n "$raw" ] || return 0
  echo "$raw" | awk '{printf "$%.4f", $1 + 0}' | sed 's/\(\.[0-9][0-9]\)0\+$/\1/'
}

# ===== provider-specific data =====

IFS=$'\t' read -r provider_id provider_route provider_src \
  <<<"$(resolve_provider "$session_id" "$model_id" "$model_id_raw")"
[ "$provider_id" = "-" ] && provider_id=""
[ "$provider_route" = "-" ] && provider_route=""
[ -n "$provider_id" ] || provider_id="anthropic"
family=$(provider_family "$provider_id" "$provider_route")

# Which backend a session resolved to is otherwise invisible, and a wrong answer
# shows up only as surprising numbers. STATUSLINE_DEBUG=1 makes the chain
# explicit; source is "id" or "log" when it is ground truth, "alias" or
# "default" when it is a guess.
if [ -n "${STATUSLINE_DEBUG:-}" ]; then
  printf 'provider=%s route=%s source=%s family=%s\n' \
    "$provider_id" "$provider_route" "$provider_src" "$family" >&2
fi

# --- chatgpt: live quota, cache-backed ---
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

# "$1=used_percent $2=window_minutes $3=resets_at" -> "pct<TAB>label<TAB>reset".
# Absent fields arrive as "-" (see the @tsv projection in refresh_quota).
codex_window_fields() {
  local pct=$1 win=$2 reset=$3 style="time" reset_fmt=""
  case "$pct" in '' | "-") return 1 ;; esac
  pct=$(echo "$pct" | awk '{printf "%d", int($1 + 0.5)}')
  [ "$win" = "-" ] && win=""
  # Windows of a day or more reset far enough out that the date matters.
  if [ -n "$win" ] && [ "$win" -ge 1440 ] 2>/dev/null; then style="datetime"; fi
  [ "$reset" != "-" ] && reset_fmt=$(format_reset_time_epoch "$reset" "$style")
  printf '%s\t%s\t%s' "$pct" "$(codex_window_label "$win")" "$reset_fmt"
}

codex_pct_primary="" codex_label_primary="" codex_reset_primary=""
codex_pct_secondary="" codex_label_secondary="" codex_reset_secondary=""
quota_as_of="" codex_acct=""

if [ "$family" = "chatgpt" ]; then
  resolve_codex_home
  [ -n "$codex_home" ] && codex_acct=$(jq -r '.tokens.account_id // empty' \
    "$codex_home/auth.json" 2>/dev/null)
  if [ -n "$codex_acct" ]; then
    # Cache is keyed by account, so switching accounts can never serve the
    # other one's numbers out of a stale file.
    quota_cache="$cache_dir/quota-$codex_acct"
    [ "$(cache_age "$quota_cache")" -ge 60 ] &&
      spawn_refresh "quota-$codex_acct" quota "$codex_home" "$codex_acct"

    if [ -f "$quota_cache" ]; then
      quota_as_of=$(cache_stamp "$quota_cache")
      # Refreshes keep readings <=60s old; only stamp the age once they have
      # been failing long enough to matter (stale token, offline).
      if [ -n "$quota_as_of" ]; then
        quota_age=$(($(date +%s) - $(to_int "$quota_as_of")))
        [ "$quota_age" -lt 300 ] && quota_as_of=""
      fi
      IFS=$'\t' read -r cx_p_pct cx_p_win cx_p_reset cx_s_pct cx_s_win cx_s_reset \
        <<<"$(cache_value "$quota_cache")"
      if codex_fields=$(codex_window_fields "${cx_p_pct:--}" "${cx_p_win:--}" "${cx_p_reset:--}"); then
        IFS=$'\t' read -r codex_pct_primary codex_label_primary codex_reset_primary <<<"$codex_fields"
      fi
      if codex_fields=$(codex_window_fields "${cx_s_pct:--}" "${cx_s_win:--}" "${cx_s_reset:--}"); then
        IFS=$'\t' read -r codex_pct_secondary codex_label_secondary codex_reset_secondary <<<"$codex_fields"
      fi
    fi
  fi
fi

# --- per-model weekly windows (Fable and friends) ---
# Anthropic meters some models on their own weekly window on top of the
# all-models one, and being at 100% there while "weekly" reads 67% is exactly
# the thing worth seeing. Claude Code 2.1.269 does not put these on stdin (its
# payload builder emits only five_hour/seven_day/spend_limit) but it does cache
# the full limits array it fetches, so read stdin first — newer builds document
# a rate_limits.model_scoped field — and fall back to that cache.
#
# Records are RS-separated, fields US-separated, with "-" for absent values so
# nothing can collapse. Returns "<label>\x1f<pct>\x1f<resets_at>" per bucket,
# plus the cache's fetch time on the last record when it came from the cache.
claude_config_json() {
  local f candidates
  # An explicit config dir is authoritative: falling back to $HOME behind the
  # user's back would report a different account's usage.
  if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
    candidates="$CLAUDE_CONFIG_DIR/.claude.json"
  else
    candidates="$HOME/.claude/.claude.json $HOME/.claude.json"
  fi
  for f in $candidates; do
    [ -f "$f" ] || continue
    if jq -e '.cachedUsageUtilization.utilization.limits' "$f" >/dev/null 2>&1; then
      printf '%s' "$f"
      return
    fi
  done
}

scoped_fetched_ms=""
model_scoped_records=""
if [ "$family" = "anthropic" ]; then
  model_scoped_records="$model_scoped_raw"
  if [ -z "$model_scoped_records" ]; then
    scoped_src=$(claude_config_json)
    if [ -n "$scoped_src" ]; then
      model_scoped_records=$(jq -r '
        [.cachedUsageUtilization.utilization.limits[]?
         | select(.kind == "weekly_scoped" and .scope.model.display_name != null)
         | [(.scope.model.display_name),
            (.percent | if . == null then "-" else tostring end),
            (.resets_at // "-" | tostring)]
         | join("\u001f")] | join("\u001e")' "$scoped_src" 2>/dev/null)
      scoped_fetched_ms=$(jq -r '.cachedUsageUtilization.fetchedAtMs // empty' "$scoped_src" 2>/dev/null)
    fi
  fi
fi

# --- opencode: real quota from the provider's own /usage endpoint ---
oc_ok=0
oc_as_of=""
oc_p1="" oc_r1="" oc_s1=""
oc_p2="" oc_r2="" oc_s2=""
oc_p3="" oc_r3="" oc_s3=""
if [ "$family" = "opencode" ]; then
  oc_cache="$cache_dir/ocusage-$provider_id"
  [ "$(cache_age "$oc_cache")" -ge 60 ] &&
    spawn_refresh "ocusage-$provider_id" ocusage "$provider_id"
  if [ -f "$oc_cache" ]; then
    IFS=$'\037' read -r oc_p1 oc_r1 oc_s1 oc_p2 oc_r2 oc_s2 oc_p3 oc_r3 oc_s3 \
      <<<"$(cache_value "$oc_cache")"
    [ -n "$oc_p1" ] && [ "$oc_p1" != "-" ] && oc_ok=1
    if [ "$oc_ok" = 1 ]; then
      oc_as_of=$(cache_stamp "$oc_cache")
      if [ -n "$oc_as_of" ]; then
        oc_age=$(($(date +%s) - $(to_int "$oc_as_of")))
        [ "$oc_age" -lt 300 ] && oc_as_of=""
      fi
    fi
  fi
fi

# --- opencode: rolling spend against a self-declared budget ---
# Not a quota: OpenCode Go publishes no usage endpoint, so there is no remaining
# allowance to read. This is what the window actually cost, against a budget set
# in settings.json. Without a budget it degrades to the bare figure.
spend_total="" spend_pct="" spend_budget="" spend_days=7
spend_reqs=0 spend_top="" spend_top_pct=""
if [ "$family" = "opencode" ]; then
  # Default to the monthly billing period: these plans are flat-rate per month,
  # so a 7-day slice cannot be compared to what you pay.
  spend_days=$(to_int "$(settings_env CLODEX_SPEND_WINDOW_DAYS)" 30)
  [ "$spend_days" -le 0 ] && spend_days=30
  spend_budget=$(to_num "$(settings_env CLODEX_PLAN_USD)" "")
  spend_cache="$cache_dir/spend-$provider_id-${spend_days}d"
  [ "$(cache_age "$spend_cache")" -ge 300 ] &&
    spawn_refresh "spend-$provider_id-$spend_days" spend "$provider_id" "$spend_days"
  # Older caches hold a bare total; the extra fields simply come back empty.
  IFS=$'\037' read -r spend_total spend_reqs spend_top spend_top_pct \
    <<<"$(cache_value "$spend_cache")"
  spend_total=$(to_num "$spend_total" "")
  spend_reqs=$(to_int "$spend_reqs" 0)
  if [ -n "$spend_total" ] && [ -n "$spend_budget" ]; then
    spend_pct=$(awk -v t="$spend_total" -v b="$spend_budget" \
      'BEGIN { if (b + 0 <= 0) exit; printf "%d", int(t / b * 100 + 0.5) }')
  fi
fi

# --- cost ---
# Anthropic sessions use the figure Claude Code already computed; everything
# else is recomputed at the upstream's own rates, and shows nothing at all when
# those rates are unknown rather than inventing a number.
cost_fmt=""
if [ "$family" = "anthropic" ]; then
  cost_fmt=$(format_cost "$cost_usd")
else
  prices=$(resolve_prices "$family" "$provider_id" "$model_id")
  if [ -n "$prices" ] && [ -n "$session_id" ]; then
    IFS=$'\t' read -r p_in p_cached p_out <<<"$prices"
    cost_cache="$cache_dir/cost-$session_id"
    [ "$(cache_age "$cost_cache")" -ge 15 ] &&
      spawn_refresh "cost-$session_id" cost "$session_id" "$transcript_path" \
        "$model_id" "$model_id_raw" "$p_in" "$p_cached" "$p_out"
    cost_val=$(to_num "$(cache_value "$cost_cache")" "")
    [ -n "$cost_val" ] && cost_fmt="~$(format_cost "$cost_val") api"
  fi
fi

# ===== OUTPUT =====

# Terminal width for truncation (fallback 80)
term_cols=$(to_int "${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}" 80)

# Truncate string to max length, appending … if cut
truncate_str() {
  local str=$1 max=$2
  if [ "${#str}" -gt "$max" ]; then
    echo "${str:0:$((max - 1))}…"
  else
    echo "$str"
  fi
}

# Repo name: extract from git remote, fallback to directory name
if [ -n "$git_branch" ]; then
  remote_url=$(git -C "$cwd" --no-optional-locks config --get remote.origin.url 2>/dev/null)
  if [ -n "$remote_url" ]; then
    # handle https://host/user/repo.git and git@host:user/repo.git formats
    dir_name=$(basename "$remote_url" .git | awk -F'[:/@]' '{print $NF}')
  else
    dir_name=$(basename "$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)")
  fi
else
  dir_name="$cwd"
fi

# Line 0: dir on git:branch [time] [vim]
time_field=" [${time}]"
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

  repo_name=""
  [ -n "$worktree_orig" ] && repo_name=$(basename "$worktree_orig" 2>/dev/null)
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

# Line 1: Model | tokens used/total (%) | cost | effort
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
printf "%b%s%b" "$C_BLUE" "$model_display" "$C_RESET"
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

# Line 2+: the quota surface the resolved provider can actually support.
case "$family" in
anthropic)
  if [ -n "$rl5_pct" ]; then
    five_hour_pct=$(echo "$rl5_pct" | awk '{printf "%d", int($1 + 0.5)}')
    seven_day_pct=$(echo "${rl7_pct:-0}" | awk '{printf "%d", int($1 + 0.5)}')
    printf "\n"
    printf "%bcurrent:%b " "$C_WHITE" "$C_RESET"
    build_bar "$five_hour_pct" 10
    printf " %b%s%%%b" "$C_CYAN" "$five_hour_pct" "$C_RESET"
    printf "%b" "$SEP"
    printf "%bweekly:%b " "$C_WHITE" "$C_RESET"
    build_bar "$seven_day_pct" 10
    printf " %b%s%%%b" "$C_CYAN" "$seven_day_pct" "$C_RESET"

    # Per-model weekly windows (Fable, ...) sit alongside the all-models one.
    printf '%s\n' "$model_scoped_records" | tr '\036' '\n' |
      while IFS=$'\037' read -r sc_label sc_pct sc_reset || [ -n "$sc_label" ]; do
        [ -n "$sc_label" ] && [ "$sc_pct" != "-" ] && [ -n "$sc_pct" ] || continue
        sc_pct=$(echo "$sc_pct" | awk '{printf "%d", int($1 + 0.5)}')
        printf "%b" "$SEP"
        printf "%b%s:%b " "$C_WHITE" \
          "$(printf '%s' "$sc_label" | tr '[:upper:]' '[:lower:]')" "$C_RESET"
        build_bar "$sc_pct" 10
        printf " %b%s%%%b" "$C_CYAN" "$sc_pct" "$C_RESET"
      done

    printf "\n"
    printf "%bresets:%b 5h @ %s" "$C_WHITE" "$C_RESET" \
      "$(format_reset_time_epoch "$rl5_reset" "time")"
    printf "%b" "$SEP"
    printf "7d @ %s" "$(format_reset_time_epoch "$rl7_reset" "datetime")"
    printf '%s\n' "$model_scoped_records" | tr '\036' '\n' |
      while IFS=$'\037' read -r sc_label sc_pct sc_reset || [ -n "$sc_label" ]; do
        [ -n "$sc_label" ] && [ "$sc_reset" != "-" ] && [ -n "$sc_reset" ] || continue
        sc_epoch=$(iso_to_epoch "$sc_reset")
        [ -n "$sc_epoch" ] || continue
        printf "%b" "$SEP"
        printf "%s @ %s" "$(printf '%s' "$sc_label" | tr '[:upper:]' '[:lower:]')" \
          "$(format_reset_time_epoch "$sc_epoch" "datetime")"
      done
    # These buckets come from Claude Code's own usage cache, which it refreshes
    # on its own schedule — stamp the age so a stale 100% is not read as live.
    if [ -n "$scoped_fetched_ms" ]; then
      scoped_age=$(($(date +%s) - $(to_int "${scoped_fetched_ms%???}")))
      if [ "$scoped_age" -ge 900 ]; then
        age_color="$C_DIM"
        [ "$scoped_age" -ge 21600 ] && age_color="$C_YELLOW"
        printf "%b" "$SEP"
        printf "%bas of %s%b" "$age_color" "$(format_age "$scoped_age")" "$C_RESET"
      fi
    fi
  fi
  ;;
chatgpt)
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

    if [ -n "$codex_reset_primary" ] || [ -n "$codex_reset_secondary" ] ||
      [ -n "$quota_as_of" ] || [ -n "$codex_label" ]; then
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
      # Which codex account these numbers describe — only shown when more than
      # one auth.json exists, i.e. when the answer is not obvious.
      if [ -n "$codex_label" ]; then
        printf "%b" "$SEP"
        printf "%b%s%b" "$C_DIM" "$codex_label" "$C_RESET"
      fi
      if [ -n "$quota_as_of" ]; then
        quota_age=$(($(date +%s) - $(to_int "$quota_as_of")))
        age_color="$C_DIM"
        [ "$quota_age" -ge 7200 ] && age_color="$C_YELLOW"
        printf "%b" "$SEP"
        printf "%bas of %s%b" "$age_color" "$(format_age "$quota_age")" "$C_RESET"
      fi
    fi
  elif [ -n "$codex_acct" ]; then
    # Credentials are fine, the first refresh just has not landed yet.
    printf "\n"
    printf "%bcodex:%b %bfetching limits…%b" "$C_ORANGE" "$C_RESET" "$C_DIM" "$C_RESET"
  else
    printf "\n"
    printf "%bcodex:%b %bno limit data — check %s%b" \
      "$C_ORANGE" "$C_RESET" "$C_DIM" "${codex_home:-$HOME/.codex}/auth.json" "$C_RESET"
  fi
  ;;
opencode)
  printf "\n"
  printf "%b%s%b" "$C_ORANGE" "$provider_id" "$C_RESET"
  if [ "$oc_ok" = 1 ]; then
    # Real quota beats the locally derived estimate, so it takes the line.
    oc_bar() {
      local label=$1 pct=$2 status=$3
      [ -n "$pct" ] && [ "$pct" != "-" ] || return 0
      pct=$(echo "$pct" | awk '{printf "%d", int($1 + 0.5)}')
      printf "%b%s:%b " "$C_WHITE" "$label" "$C_RESET"
      build_bar "$pct" 10
      printf " %b%s%%%b" "$C_CYAN" "$pct" "$C_RESET"
      # Anything other than "ok" means the window is capped or degraded; the
      # percentage alone would not show that.
      [ -n "$status" ] && [ "$status" != "ok" ] && [ "$status" != "-" ] &&
        printf " %b%s%b" "$C_RED" "$status" "$C_RESET"
      return 0
    }
    printf " "
    oc_bar "5h" "$oc_p1" "$oc_s1"
    printf "%b" "$SEP"
    oc_bar "weekly" "$oc_p2" "$oc_s2"
    printf "%b" "$SEP"
    oc_bar "monthly" "$oc_p3" "$oc_s3"

    printf "\n"
    printf "%bresets:%b" "$C_WHITE" "$C_RESET"
    oc_reset() {
      local label=$1 iso=$2 style=$3 epoch
      [ -n "$iso" ] && [ "$iso" != "-" ] || return 0
      epoch=$(iso_to_epoch "$iso")
      [ -n "$epoch" ] || return 0
      printf "%s @ %s" "$label" "$(format_reset_time_epoch "$epoch" "$style")"
      return 0
    }
    printf " "
    oc_reset "5h" "$oc_r1" time
    printf "%b" "$SEP"
    oc_reset "weekly" "$oc_r2" datetime
    printf "%b" "$SEP"
    oc_reset "monthly" "$oc_r3" datetime
    # The plan is flat-rate, so quota answers "can I keep going" and this
    # answers "is it worth paying for" — different questions, both wanted.
    if [ -n "$spend_total" ] && [ -n "$spend_pct" ]; then
      printf "%b" "$SEP"
      printf "%b%s of %s plan%b" "$C_DIM" "$(format_money "$spend_total")" \
        "$(format_money "$spend_budget")" "$C_RESET"
    fi
    if [ -n "$oc_as_of" ]; then
      oc_age=$(($(date +%s) - $(to_int "$oc_as_of")))
      age_color="$C_DIM"
      [ "$oc_age" -ge 7200 ] && age_color="$C_YELLOW"
      printf "%b" "$SEP"
      printf "%bas of %s%b" "$age_color" "$(format_age "$oc_age")" "$C_RESET"
    fi
  elif [ -n "$spend_total" ]; then
    printf " %b%dd:%b " "$C_WHITE" "$spend_days" "$C_RESET"
    if [ -n "$spend_pct" ]; then
      # Not a spend cap: the plan is flat-rate, so this is the API-equivalent
      # value pulled out of it against what it costs. Past 100% it has paid for
      # itself, which is why the bar fills toward green.
      build_bar "$spend_pct" 10 value
      printf " %b%s%%%b %b%s of %s plan%b" "$C_CYAN" "$spend_pct" "$C_RESET" "$C_DIM" \
        "$(format_money "$spend_total")" "$(format_money "$spend_budget")" "$C_RESET"
    else
      # No budget configured — the figure alone, no bar to imply a limit.
      printf "%b%s%b" "$C_CYAN" "$(format_cost "$spend_total")" "$C_RESET"
    fi
    # A few cents of deepseek-flash says nothing on its own; the request count
    # and the model doing the spending are what make the line readable.
    if [ "$spend_reqs" -gt 0 ]; then
      printf " %b· %s req%s%b" "$C_DIM" "$spend_reqs" \
        "$([ "$spend_reqs" -eq 1 ] || printf 's')" "$C_RESET"
    fi
    # This is the window's dominant model, not the session's — right under the
    # model name on line 1 it has to say so, or it reads as the active model.
    if [ -n "$spend_top" ] && [ "$spend_top" != "-" ]; then
      if [ -n "$spend_top_pct" ] && [ "$spend_top_pct" != "-" ]; then
        printf " %b· %s %s%% of spend%b" "$C_DIM" "$spend_top" "$spend_top_pct" "$C_RESET"
      else
        printf " %b· mostly %s%b" "$C_DIM" "$spend_top" "$C_RESET"
      fi
    fi
  else
    printf " %bspend pending%b" "$C_DIM" "$C_RESET"
  fi
  # Only claim there is no quota when we genuinely could not read one — saying
  # it next to live quota bars would be nonsense.
  if [ "$oc_ok" != 1 ]; then
    printf "%b" "$SEP"
    printf "%bno quota reading%b" "$C_DIM" "$C_RESET"
  fi
  ;;
*)
  # A clodex provider we know nothing about: say so rather than borrow the
  # Anthropic bars, which describe an account this session never touched.
  printf "\n"
  printf "%b%s%b %b· no quota data%b" "$C_ORANGE" "$provider_id" "$C_RESET" "$C_DIM" "$C_RESET"
  ;;
esac

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
