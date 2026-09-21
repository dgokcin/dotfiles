#!/usr/bin/env bash
# Verify that commands resolve through the package owner declared by this repo.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$REPO/.path"

fail=0
ok=0

pass() { printf '  ok     %s\n' "$1"; ok=$((ok + 1)); }
fail_at() { printf '  FAIL   %s\n' "$1"; fail=$((fail + 1)); }

assert_path() {
  local command_name="$1" expected="$2" actual
  actual="$(type -P "$command_name" || true)"
  if [[ -z "$actual" ]]; then
    fail_at "$command_name is missing (expected $expected)"
  elif [[ "$actual" == "$expected" ]]; then
    pass "$command_name -> $actual"
  else
    fail_at "$command_name -> $actual (expected $expected)"
  fi
}

assert_prefix() {
  local command_name="$1" expected_prefix="$2" actual
  actual="$(type -P "$command_name" || true)"
  if [[ -z "$actual" ]]; then
    fail_at "$command_name is missing (expected under $expected_prefix)"
  elif [[ "$actual" == "$expected_prefix"/* ]]; then
    pass "$command_name -> $actual"
  else
    fail_at "$command_name -> $actual (expected under $expected_prefix)"
  fi
}

echo "verify-tool-owners: checking preferred installers"

for command_name in node npm npx corepack yarn gemini clodex clodex-claude \
  claude-agent-acp codex-acp; do
  assert_path "$command_name" "$VOLTA_HOME/bin/$command_name"
done

assert_path codex "$HOME/.local/bin/codex"
assert_path claude "$HOME/.local/bin/claude"
assert_path uv "$HOME/.local/bin/uv"
assert_path uvx "$HOME/.local/bin/uvx"
assert_path opencode "$HOME/.opencode/bin/opencode"
assert_path bun "$BUN_INSTALL/bin/bun"
assert_prefix pnpm "$PNPM_HOME"

echo
echo "verify-tool-owners: $ok passed, $fail failed"
((fail == 0))
