#!/usr/bin/env bash
# Run shellcheck on every repo script at error severity.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
fail=0
count=0

while IFS= read -r -d '' f; do
  count=$((count + 1))
  if ! shellcheck -S error "$f"; then
    fail=$((fail + 1))
  fi
done < <(/usr/bin/find "$REPO" -name '*.sh' -not -path '*/.git/*' -print0)

if (( fail > 0 )); then
  echo "lint-shell: $fail script(s) failed of $count" >&2
  exit 1
fi
echo "lint-shell: $count scripts OK"
