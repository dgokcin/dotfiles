#!/usr/bin/env bash
# Verify the bootstrap graph without running installers or mutating the runner.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
bootstrap_output="$(mktemp)"
install_ci_output="$(mktemp)"
trap 'rm -f "$bootstrap_output" "$install_ci_output"' EXIT HUP INT TERM

make -C "$REPO" -n bootstrap >"$bootstrap_output"
make -C "$REPO" -n install-ci >"$install_ci_output"

expected_bootstrap=(
  'brew bundle'
  'https://get.volta.sh'
  'install node'
  '@google/gemini-cli'
  'https://get.pnpm.io/install.sh'
  'https://bun.com/install'
  'https://astral.sh/uv/install.sh'
  'awscli.amazonaws.com'
  'https://opencode.ai/install'
  'https://chatgpt.com/codex/install.sh'
  'https://claude.ai/install.sh'
  'makefiles/scripts/verify-tool-owners.sh'
)

fail=0
for expected in "${expected_bootstrap[@]}"; do
  if grep -Fq "$expected" "$bootstrap_output"; then
    printf '  ok     bootstrap contains %s\n' "$expected"
  else
    printf '  FAIL   bootstrap is missing %s\n' "$expected"
    fail=$((fail + 1))
  fi
done

installer_pattern='get\.volta\.sh|get\.pnpm\.io/install\.sh|bun\.com/install|astral\.sh/uv/install\.sh|awscli\.amazonaws\.com|opencode\.ai/install|chatgpt\.com/codex/install\.sh|claude\.ai/install\.sh'
if grep -Eq "$installer_pattern" "$install_ci_output"; then
  printf '  FAIL   install-ci includes a runtime or CLI installer\n'
  fail=$((fail + 1))
else
  printf '  ok     install-ci excludes runtime and CLI installers\n'
fi

echo
if ((fail > 0)); then
  printf 'test-bootstrap: %d failure(s)\n' "$fail" >&2
  exit 1
fi
echo "test-bootstrap: bootstrap contract OK"
