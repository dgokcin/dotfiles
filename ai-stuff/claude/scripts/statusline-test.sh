#!/bin/bash
# Fixture-driven tests for statusline.sh.
#
# Runs the real script against stdin fixtures with CLODEX_HOME / CODEX_HOME /
# XDG_CACHE_HOME / CLAUDE_CONFIG_DIR redirected at a scratch tree, so nothing
# here reads the developer's actual accounts and no test touches the network.
# Repo-only: this is not symlinked into ~/.claude.

set -u
here=$(cd "$(dirname "$0")" && pwd)
script="$here/statusline.sh"
fixtures="$here/fixtures"
scratch=$(mktemp -d "${TMPDIR:-/tmp}/statusline-test.XXXXXX")
trap 'rm -rf "$scratch"' EXIT

pass=0
fail=0

# ===== scratch environment =====

clodex="$scratch/clodex"
mkdir -p "$clodex/logs/sessions"

cat >"$clodex/providers.json" <<'JSON'
{
  "schemaVersion": 4,
  "providers": [
    {
      "id": "openai-oauth",
      "name": "OpenAI (ChatGPT)",
      "authType": "oauth",
      "api": { "url": "https://api.openai.com/v1" }
    },
    {
      "id": "opencode-go",
      "name": "OpenCode Go",
      "authType": "api",
      "api": { "url": "https://opencode.ai/zen/go/v1" },
      "modelsCache": {
        "models": [
          { "id": "deepseek-v4-pro", "upstreamModelId": "deepseek-v4-pro",
            "cost": { "input": 0.66, "output": 1.98, "cache_read": 0.022 } },
          { "id": "minimax-m3", "upstreamModelId": "minimax-m3",
            "cost": { "input": 0.3, "output": 1.2, "cache_read": 0.06 } },
          { "id": "qwen-write", "upstreamModelId": "qwen-write",
            "cost": { "input": 1, "output": 2, "cache_read": 0.1, "cache_write": 4 } }
        ]
      }
    },
    {
      "id": "mystery-provider",
      "name": "Mystery",
      "authType": "api",
      "api": { "url": "https://example.invalid/v1" }
    }
  ]
}
JSON

cat >"$clodex/config.json" <<'JSON'
{
  "modelAliases": [
    { "name": "deepseek-v4-pro", "providerId": "opencode-go", "modelId": "deepseek-v4-pro" }
  ]
}
JSON

cat >"$clodex/pricing-cache.json" <<'JSON'
{
  "models": [
    {
      "model_id": "gpt-5.6-sol",
      "pricing": [
        { "platform": "openai", "tier": "standard",
          "input_per_1m_tokens": 1.25,
          "cached_input_per_1m_tokens": 0.125,
          "output_per_1m_tokens": 10 }
      ]
    }
  ]
}
JSON

# A clodex session log naming a provider for a bare alias — the one case the
# model id alone cannot answer. The trailing line is a background request on a
# different model: Claude Code fires those inside the same session and they log
# as anthropic/passthrough, so a resolver that just takes the session's last
# line reports the wrong backend for the whole statusline.
cat >"$clodex/logs/sessions/20260912-000000000Z-claude-http-proxy-pid1-0.jsonl" <<'JSON'
{"timestamp":"2026-09-12T08:00:00.000Z","event":"request","claudeSessionId":"fx-opencode","modelId":"deepseek-v4-pro","provider":"opencode-go","route":"translated"}
{"timestamp":"2026-09-12T08:00:01.000Z","event":"request","claudeSessionId":"fx-opencode","modelId":"claude-haiku-4-5-20251001","provider":"anthropic","route":"passthrough"}
JSON

# Transcript for the cost regression: one response written as two content-block
# lines sharing a message.id (must be counted once), recorded under the bare
# model id while stdin reports it with a [1m] marker.
transcript="$scratch/transcript.jsonl"
cat >"$transcript" <<'JSON'
{"message":{"id":"m1","model":"minimax-m3","usage":{"input_tokens":1000,"cache_creation_input_tokens":2000,"cache_read_input_tokens":100000,"output_tokens":500}}}
{"message":{"id":"m1","model":"minimax-m3","usage":{"input_tokens":1000,"cache_creation_input_tokens":2000,"cache_read_input_tokens":100000,"output_tokens":500}}}
{"message":{"id":"m2","model":"some-other-model","usage":{"input_tokens":999999,"output_tokens":999999}}}
{"message":{"id":"m3","model":"minimax-m3","usage":
JSON

settings_dir="$scratch/claude"
mkdir -p "$settings_dir"
cat >"$settings_dir/settings.json" <<'JSON'
{ "env": { "CLODEX_PLAN_USD": "20", "CLODEX_SPEND_WINDOW_DAYS": "7" } }
JSON

# ===== harness =====

strip_ansi() { sed $'s/\033\\[[0-9;]*m//g'; }

# run <fixture-file> -> populates $out / $err / $status
run() {
  local fx=$1 stdin_file="$scratch/stdin.json"
  if [ "$fx" = "-" ]; then
    cat >"$stdin_file"
  else
    cp "$fx" "$stdin_file"
  fi
  # Claude Code exports its settings env block into child processes, so a
  # developer running this from inside a session would otherwise inherit their
  # own budget/auto-compact values and see different output than CI.
  env -u CLODEX_PLAN_USD -u CLODEX_SPEND_BUDGET_USD -u CLODEX_SPEND_WINDOW_DAYS \
    -u CLAUDE_CODE_AUTO_COMPACT_WINDOW -u CLAUDE_AUTOCOMPACT_PCT_OVERRIDE \
    -u STATUSLINE_DEBUG \
    CLODEX_HOME="$clodex" \
    CODEX_HOME="$scratch/codex-missing" \
    OPENCODE_AUTH_JSON="$scratch/opencode-auth-missing.json" \
    XDG_CACHE_HOME="$scratch/cache" \
    CLAUDE_CONFIG_DIR="$settings_dir" \
    COLUMNS=120 \
    "$script" <"$stdin_file" >"$scratch/stdout" 2>"$scratch/stderr"
  status=$?
  out=$(strip_ansi <"$scratch/stdout")
  err=$(cat "$scratch/stderr")
}

ok() {
  pass=$((pass + 1))
  printf '  ok   %s\n' "$1"
}
no() {
  fail=$((fail + 1))
  printf '  FAIL %s\n' "$1"
  [ -n "${2:-}" ] && printf '       %s\n' "$2"
}

expect_contains() {
  case "$out" in
  *"$1"*) ok "contains: $1" ;;
  *) no "contains: $1" "got: $(printf '%s' "$out" | tr '\n' '/')" ;;
  esac
}

expect_absent() {
  case "$out" in
  *"$1"*) no "absent: $1" "got: $(printf '%s' "$out" | tr '\n' '/')" ;;
  *) ok "absent: $1" ;;
  esac
}

expect_clean() {
  [ "$status" = "0" ] && ok "exit 0" || no "exit 0" "status=$status"
  [ -z "$err" ] && ok "no stderr" || no "no stderr" "$err"
}

seed_cache() {
  local name=$1 value=$2 age=${3:-0}
  mkdir -p "$scratch/cache/claude-statusline"
  printf '%s\n%s\n' "$(($(date +%s) - age))" "$value" \
    >"$scratch/cache/claude-statusline/$name"
}

# ===== cases =====

printf '\nanthropic: stdin rate limits drive the bars\n'
run "$fixtures/anthropic.json"
expect_clean
expect_contains "current:"
expect_contains "31%"
expect_contains "weekly:"
expect_contains "48%"
expect_contains "cost: \$0.4213"
expect_absent "no quota data"

printf '\nopenai-oauth: codex bars from cache, API-equivalent cost\n'
# 31/61 pct, 300/10080 minute windows, reset epochs.
seed_cache "quota-acct-test" "31	300	1789000000	61	10080	1789300000"
mkdir -p "$scratch/codex-missing"
cat >"$scratch/codex-missing/auth.json" <<'JSON'
{ "tokens": { "access_token": "stub", "account_id": "acct-test" } }
JSON
run "$fixtures/openai-oauth.json"
expect_clean
expect_contains "codex"
expect_contains "5h:"
expect_contains "31%"
expect_contains "weekly:"
expect_contains "61%"
# A fresh reading is stamped too: codex's own /status replays a snapshot from
# its last request, so an unlabelled number cannot be compared against it.
expect_contains "as of"
expect_absent "current:"
rm -rf "$scratch/codex-missing"

printf '\nopencode-go: real quota from the provider /usage endpoint\n'
# 5h / weekly / monthly: percent, resetsAt, status.
seed_cache "ocusage-opencode-go" \
  $'1\0372026-09-12T13:25:25.939Z\037ok\0371\0372026-09-14T00:00:00.939Z\037ok\03724\0372026-09-30T09:34:36.939Z\037ok'
run "$fixtures/opencode-go.json"
expect_clean
expect_contains "5h:"
expect_contains "weekly:"
expect_contains "monthly:"
expect_contains "24%"
expect_contains "monthly @"
# Real quota supersedes the local estimate, so the "no quota" disclaimer and the
# spend bar must both step aside.
expect_absent "no quota reading"
expect_absent "of spend"
expect_contains "as of"
# Anthropic's own limits still must not leak in.
expect_absent "current:"

printf '\nopencode-go: a capped window is flagged, not just shown as a number\n'
seed_cache "ocusage-opencode-go" \
  $'100\0372026-09-12T13:25:25.939Z\037limited\0371\0372026-09-14T00:00:00.939Z\037ok\03724\0372026-09-30T09:34:36.939Z\037ok'
run "$fixtures/opencode-go.json"
expect_clean
expect_contains "limited"
rm -f "$scratch/cache/claude-statusline/ocusage-opencode-go"

printf '\nopencode-go: falls back to the local estimate without a quota reading\n'
seed_cache "spend-opencode-go-7d" $'7.62\03789\037deepseek-v4.1-flash\03763'
run "$fixtures/opencode-go.json"
expect_clean
expect_contains "opencode-go"
expect_contains "7d:"
expect_contains "38%"
expect_contains "\$7.62 of \$20 plan"
# A few cents means nothing alone; volume and the model burning it carry the line.
expect_contains "89 reqs"
# Must read as a window aggregate: directly under the session's model name on
# line 1, a bare model id reads as the model currently in use.
expect_contains "deepseek-v4.1-flash 63% of spend"
# With no reading available it must say so, rather than let the local estimate
# pass for real quota.
expect_contains "no quota reading"
# The whole point of the change: the Anthropic numbers on stdin must not leak
# into a session that never touched that account.
expect_absent "current:"
expect_absent "resets:"

printf '\nopencode-go: legacy bare-total cache still renders\n'
seed_cache "spend-opencode-go-7d" "7.62"
rm -f "$scratch/cache/claude-statusline/provider-fx-opencode-deepseek-v4-pro"
run "$fixtures/opencode-go.json"
expect_clean
expect_contains "\$7.62 of \$20 plan"
expect_absent "reqs"
expect_absent "of spend"
seed_cache "spend-opencode-go-7d" $'7.62\03789\037deepseek-v4.1-flash\03763'

printf '\nopencode-go: value past 100%% reports the real figure\n'
seed_cache "spend-opencode-go-7d" $'14.80\037870\037kimi-k3\03791'
rm -f "$scratch/cache/claude-statusline/provider-fx-opencode-deepseek-v4-pro"
run "$fixtures/opencode-go.json"
expect_clean
# Not a cap: exceeding the plan cost is the good case, so the number is not
# clamped to 100 the way a quota percentage would be.
expect_contains "74%"
expect_contains "\$14.80 of \$20 plan"
seed_cache "spend-opencode-go-7d" $'7.62\03789\037deepseek-v4.1-flash\03763'

printf '\nopencode-go: provider resolved from the clodex session log\n'
# fx-opencode is a bare alias; the log entry is what proves the provider. Drop
# the alias table so only the log can answer.
mv "$clodex/config.json" "$clodex/config.json.off"
rm -f "$scratch/cache/claude-statusline/provider-fx-opencode"
run "$fixtures/opencode-go.json"
expect_clean
expect_contains "opencode-go"
expect_contains "7d:"
mv "$clodex/config.json.off" "$clodex/config.json"

printf '\nno context reading yet: a dash, not a misleading 0%%\n'
# current_usage is null until the model completes an API call (e.g. straight
# after /model). Rendering that as 0 / 272k (0%) reads as a broken statusline.
jq 'del(.context_window.current_usage) | del(.context_window.total_input_tokens)' \
  "$fixtures/anthropic.json" >"$scratch/no-ctx.json"
run "$scratch/no-ctx.json"
expect_clean
expect_contains "ctx: –"
expect_absent "(0%)"
expect_absent "acp:"

printf '\nexpired codex token: says so instead of quietly ageing\n'
mkdir -p "$scratch/codex-missing"
cat >"$scratch/codex-missing/auth.json" <<'JSON'
{ "tokens": { "access_token": "stub", "account_id": "acct-401" } }
JSON
seed_cache "quota-acct-401" "31	300	1789000000	61	10080	1789300000" 36000
seed_cache "quota-acct-401.err" "401" 30
mkdir -p "$scratch/cache/claude-statusline/.lock-quota-acct-401"
run "$fixtures/openai-oauth.json"
expect_clean
expect_contains "as of 10h ago"
expect_contains "token expired"
rmdir "$scratch/cache/claude-statusline/.lock-quota-acct-401"
rm -rf "$scratch/codex-missing" "$scratch/cache/claude-statusline/quota-acct-401.err"

printf '\nsparse session json: null fields must not shift later values\n'
run "$fixtures/sparse.json"
expect_clean
# 1000 + 5000, with cache_creation_input_tokens absent entirely.
expect_contains "ctx: 6k / 272k"
expect_contains "effort: n/a"
expect_contains "12%"
# display_name is null; the id is a better fallback than a blank.
expect_contains "claude-opus-5"
# The five_hour reset epoch must stay in the reset slot. It leaking into a token
# count or a percentage is the signature of a field-alignment bug.
expect_absent "1789257600%"
expect_absent "1789.2m"

printf '\nopencode-go: no plan cost configured degrades to the bare figure\n'
cat >"$settings_dir/settings.json" <<'JSON'
{ "env": { "CLODEX_SPEND_WINDOW_DAYS": "7" } }
JSON
run "$fixtures/opencode-go.json"
expect_clean
expect_contains "\$7.62"
expect_absent "of \$20 plan"
expect_absent "○"
expect_absent "●"
cat >"$settings_dir/settings.json" <<'JSON'
{ "env": { "CLODEX_PLAN_USD": "20", "CLODEX_SPEND_WINDOW_DAYS": "7" } }
JSON

printf '\n[1m] marker: cost still resolves (regression)\n'
# Compute the cost synchronously, the way the detached refresher would.
CLODEX_HOME="$clodex" XDG_CACHE_HOME="$scratch/cache" \
  "$script" --refresh cost fx-1m "$transcript" "minimax-m3" "minimax-m3[1m]" \
  0.3 0.06 1.2 2>"$scratch/stderr"
[ -s "$scratch/stderr" ] && no "refresh cost quiet" "$(cat "$scratch/stderr")" || ok "refresh cost quiet"
sed "s#TRANSCRIPT_PLACEHOLDER#$transcript#" "$fixtures/opencode-1m.json" \
  >"$scratch/opencode-1m.json"
run "$scratch/opencode-1m.json"
expect_clean
# (1000 + 2000) * 0.3 + 100000 * 0.06 + 500 * 1.2, per 1M, counting the repeated
# message.id once and ignoring the other model's line.
expect_contains "cost: ~\$0.0075 api"

printf '\ncache writes use their published rate, not the input rate\n'
# Same transcript numbers as the [1m] case: 1000 in, 2000 cache-write,
# 100000 cache-read, 500 out. At 1 / 4 / 0.1 / 2 per 1M that is
# 1000 + 8000 + 10000 + 1000 = 20000 -> $0.0200. Billing writes at the input
# rate instead would give $0.0140, a 30% undercount.
sed 's/minimax-m3/qwen-write/g' "$transcript" >"$scratch/transcript-write.jsonl"
CLODEX_HOME="$clodex" XDG_CACHE_HOME="$scratch/cache" \
  "$script" --refresh cost fx-write "$scratch/transcript-write.jsonl" \
  "qwen-write" "qwen-write" 1 0.1 2 4 2>"$scratch/stderr"
[ -s "$scratch/stderr" ] && no "cache-write refresh quiet" "$(cat "$scratch/stderr")" ||
  ok "cache-write refresh quiet"
write_cost=$(sed -n 2p "$scratch/cache/claude-statusline/cost-fx-write" 2>/dev/null)
case "$write_cost" in
0.02*) ok "cache writes billed at cache_write rate ($write_cost)" ;;
*) no "cache writes billed at cache_write rate" "got $write_cost, expected 0.02" ;;
esac

printf '\nunknown provider: no quota, no invented cost\n'
run "$fixtures/unknown-provider.json"
expect_clean
expect_contains "mystery-provider"
expect_contains "no quota data"
expect_absent "current:"
expect_absent "cost:"

printf '\nmissing codex auth: renders cleanly, says why\n'
rm -rf "$scratch/codex-missing"
run "$fixtures/missing-auth.json"
expect_clean
expect_contains "no limit data"
expect_absent "current:"

printf '\ncold cache with valid auth: says fetching, not "check auth.json"\n'
mkdir -p "$scratch/codex-missing"
cat >"$scratch/codex-missing/auth.json" <<'JSON'
{ "tokens": { "access_token": "stub", "account_id": "acct-cold" } }
JSON
# Hold the refresh lock so the render cannot spawn a refresher — this asserts
# the cold-cache message, and keeps the suite off the network.
mkdir -p "$scratch/cache/claude-statusline/.lock-quota-acct-cold"
run "$fixtures/openai-oauth.json"
expect_clean
expect_contains "fetching limits"
expect_absent "check"
rmdir "$scratch/cache/claude-statusline/.lock-quota-acct-cold"
rm -rf "$scratch/codex-missing"

printf '\nstale cache: reading is stamped with its age\n'
mkdir -p "$scratch/codex-missing"
cat >"$scratch/codex-missing/auth.json" <<'JSON'
{ "tokens": { "access_token": "stub", "account_id": "acct-stale" } }
JSON
# 3h old, past the 5m "worth mentioning" threshold. Cache is keyed by account so
# this cannot collide with the fresh reading seeded earlier.
seed_cache "quota-acct-stale" "31	300	1789000000	61	10080	1789300000" 10800
run "$fixtures/openai-oauth.json"
expect_clean
expect_contains "as of 3h ago"
rm -rf "$scratch/codex-missing"

printf '\nmalformed stdin: degrades instead of erroring\n'
run "$fixtures/malformed.json"
expect_clean
expect_contains "ctx:"

printf '\nmissing clodex home: routed model falls back without noise\n'
saved_clodex="$clodex"
clodex="$scratch/clodex-absent"
run "$fixtures/opencode-go.json"
expect_clean
clodex="$saved_clodex"

printf '\nSTATUSLINE_DEBUG reports the resolution chain\n'
debug_out=$(env -u CLODEX_PLAN_USD -u CLODEX_SPEND_BUDGET_USD -u CLODEX_SPEND_WINDOW_DAYS \
  CLODEX_HOME="$clodex" CODEX_HOME="$scratch/codex-missing" \
  XDG_CACHE_HOME="$scratch/cache" CLAUDE_CONFIG_DIR="$settings_dir" \
  STATUSLINE_DEBUG=1 "$script" <"$fixtures/opencode-go.json" 2>&1 >/dev/null)
case "$debug_out" in
*"provider=opencode-go"*"family=opencode"*) ok "debug line" ;;
*) no "debug line" "$debug_out" ;;
esac

printf '\nwarm caches: the render refreshes nothing\n'
# Counting lock dirs measured their asynchronous cleanup, not spawning. A
# completed refresh rewrites its cache stamp, so compare stamps instead.
# Wait out refreshers spawned by earlier cases: the lock is released only after
# the child finishes, so no locks means nothing is still in flight to rewrite a
# cache underneath this check.
drain=0
while [ -n "$(find "$scratch/cache" -name '.lock-*' 2>/dev/null)" ] && [ "$drain" -lt 2000 ]; do
  drain=$((drain + 1))
done
seed_cache "ocusage-opencode-go" \
  $'1\0372026-09-12T13:25:25.939Z\037ok\0371\0372026-09-14T00:00:00.939Z\037ok\03724\0372026-09-30T09:34:36.939Z\037ok'
seed_cache "cost-fx-opencode" "0.004"
warm_before=$(cat "$scratch/cache/claude-statusline/ocusage-opencode-go" \
  "$scratch/cache/claude-statusline/spend-opencode-go-7d" \
  "$scratch/cache/claude-statusline/cost-fx-opencode" 2>/dev/null)
run "$fixtures/opencode-go.json"
expect_clean
warm_after=$(cat "$scratch/cache/claude-statusline/ocusage-opencode-go" \
  "$scratch/cache/claude-statusline/spend-opencode-go-7d" \
  "$scratch/cache/claude-statusline/cost-fx-opencode" 2>/dev/null)
[ "$warm_before" = "$warm_after" ] && ok "warm caches untouched" ||
  no "warm caches untouched" "a refresh rewrote a warm cache"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
