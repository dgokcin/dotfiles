#!/usr/bin/env bash
# Trust every third-party tap the Brewfile declares.
#
# Homebrew 7 refuses to load formulae from untrusted taps, which breaks
# `brew bundle` and `brew info` on a fresh machine. Trusting the taps we
# already committed to the Brewfile restores an unattended bootstrap.
#
# No-op on older Homebrew releases that predate `brew trust`.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
BREWFILE="${1:-$REPO/Brewfile}"

if ! command -v brew >/dev/null 2>&1; then
  echo "brew-trust: brew not found" >&2
  exit 2
fi
if [[ ! -f "$BREWFILE" ]]; then
  echo "brew-trust: Brewfile not found at $BREWFILE" >&2
  exit 2
fi
if ! brew trust --help >/dev/null 2>&1; then
  echo "brew-trust: this Homebrew has no 'trust' command, skipping"
  exit 0
fi

taps=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ "$line" =~ ^tap[[:space:]]+\"([^\"]+)\" ]] && taps+=("${BASH_REMATCH[1]}")
done < "$BREWFILE"

if (( ${#taps[@]} == 0 )); then
  echo "brew-trust: no taps declared in $BREWFILE"
  exit 0
fi

failed=0
for tap in "${taps[@]}"; do
  if brew trust --tap "$tap" >/dev/null 2>&1; then
    echo "  trusted   $tap"
  else
    echo "  trust FAIL $tap" >&2
    failed=$((failed + 1))
  fi
done

exit $(( failed > 0 ))
