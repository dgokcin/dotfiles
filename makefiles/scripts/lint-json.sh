#!/usr/bin/env bash
# Validate JSON that tools parse strictly.
#
# Editor settings/keybindings are JSONC (comments, trailing commas) and are
# skipped. The statusline fixture `malformed.json` is intentionally invalid.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO"

is_skipped() {
  case "$1" in
    */malformed.json) return 0 ;;
    */ai-stuff/cursor/settings.json) return 0 ;;
    */ai-stuff/cursor/keybindings.json) return 0 ;;
    */other/vscode/keybindings.json) return 0 ;;
    */other/winterm/*) return 0 ;;
    *) return 1 ;;
  esac
}

fail=0
count=0
while IFS= read -r -d '' f; do
  is_skipped "$f" && continue
  count=$((count + 1))
  if ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" 2>/tmp/lint-json.err; then
    printf '%s\n' "$f"
    sed 's/^/  /' /tmp/lint-json.err
    fail=$((fail + 1))
  fi
done < <(/usr/bin/find "$REPO" \( -name '*.json' -o -name '.neoconf.json' \) \
  -not -path '*/.git/*' -print0)

if (( fail > 0 )); then
  echo "lint-json: $fail invalid file(s) of $count" >&2
  exit 1
fi
echo "lint-json: $count files OK"
