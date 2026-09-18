#!/usr/bin/env bash
# Confirm every Brewfile tap/formula/cask still resolves.
#
# Missing packages and failed taps always fail the run (install would break).
# Disabled or deprecated packages emit a GitHub annotation and fail only when
# FAIL_STALE=1 (the weekly CI). SKIP_BREW_UPDATE=1 skips `brew update`.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
BREWFILE="${1:-$REPO/Brewfile}"

if ! command -v brew >/dev/null 2>&1; then
  echo "brew-health: brew not found" >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "brew-health: jq not found" >&2
  exit 2
fi
if [[ ! -f "$BREWFILE" ]]; then
  echo "brew-health: Brewfile not found at $BREWFILE" >&2
  exit 2
fi

taps=()
brews=()
casks=()

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z "$line" ]] && continue
  if [[ "$line" =~ ^tap[[:space:]]+\"([^\"]+)\" ]]; then
    taps+=("${BASH_REMATCH[1]}")
  elif [[ "$line" =~ ^brew[[:space:]]+\"([^\"]+)\" ]]; then
    brews+=("${BASH_REMATCH[1]}")
  elif [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
    casks+=("${BASH_REMATCH[1]}")
  fi
done < "$BREWFILE"

if [[ "${SKIP_BREW_UPDATE:-}" != "1" ]]; then
  echo "updating Homebrew..."
  brew update --quiet
fi

tap_fail=0
for tap in "${taps[@]}"; do
  if brew tap "$tap" >/dev/null; then
    echo "  tap ok    $tap"
  else
    echo "  tap FAIL  $tap"
    echo "::error file=Brewfile::failed to tap $tap"
    tap_fail=$((tap_fail + 1))
  fi
done

missing=0
disabled=0
deprecated=0

check_item() {
  local kind="$1" name="$2" json flag
  if [[ "$kind" == cask ]]; then
    json="$(brew info --json=v2 --cask "$name" 2>/dev/null || true)"
    flag=".casks[0]"
  else
    json="$(brew info --json=v2 "$name" 2>/dev/null || true)"
    flag=".formulae[0]"
  fi

  if [[ -z "$json" ]] || ! jq -e "$flag != null" >/dev/null 2>&1 <<<"$json"; then
    echo "  missing   $kind $name"
    echo "::error file=Brewfile::$kind '$name' is missing or renamed"
    missing=$((missing + 1))
    return
  fi

  local is_disabled is_deprecated
  is_disabled="$(jq -r "$flag.disabled // false" <<<"$json")"
  is_deprecated="$(jq -r "$flag.deprecated // false" <<<"$json")"

  if [[ "$is_disabled" == true ]]; then
    echo "  disabled  $kind $name"
    echo "::warning file=Brewfile::$kind '$name' is disabled"
    disabled=$((disabled + 1))
    return
  fi
  if [[ "$is_deprecated" == true ]]; then
    echo "  deprecated $kind $name"
    echo "::warning file=Brewfile::$kind '$name' is deprecated"
    deprecated=$((deprecated + 1))
    return
  fi
  echo "  ok        $kind $name"
}

for name in "${brews[@]}"; do
  check_item brew "$name"
done
for name in "${casks[@]}"; do
  check_item cask "$name"
done

echo
echo "brew-health: ${#taps[@]} taps, ${#brews[@]} formulae, ${#casks[@]} casks"
echo "  missing=$missing disabled=$disabled deprecated=$deprecated tap_fail=$tap_fail"

fail=0
if (( missing + tap_fail > 0 )); then
  fail=1
fi
if [[ "${FAIL_STALE:-0}" == "1" ]] && (( disabled + deprecated > 0 )); then
  fail=1
fi
exit "$fail"
