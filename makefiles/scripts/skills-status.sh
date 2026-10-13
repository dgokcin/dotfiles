#!/usr/bin/env bash
# List every skill in REPO and mark the ones the `skills` CLI has installed.
#
# The CLI picker cannot show install state, so `make skills` prints this first.
set -euo pipefail

REPO="$(cd "${1:?usage: skills-status.sh <skills-repo>}" && pwd)"
LOCK="$HOME/.agents/.skill-lock.json"

installed=""
if [[ -f "$LOCK" ]]; then
  installed="$(jq -r --arg repo "$REPO" \
    '.skills // {} | to_entries[] | select(.value.sourceType == "local" and .value.source == $repo) | .key' \
    "$LOCK")"
fi

have=0
total=0
for md in "$REPO"/skills/*/*/SKILL.md; do
  [[ "$md" == "$REPO/skills/archived/"* ]] && continue
  dir="$(dirname "$md")"
  name="$(basename "$dir")"
  bucket="$(basename "$(dirname "$dir")")"
  total=$((total + 1))
  if grep -qx "$name" <<<"$installed"; then
    printf '  \033[32m✓\033[0m %-24s %s\n' "$name" "$bucket"
    have=$((have + 1))
  else
    printf '  \033[2m·\033[0m %-24s %s\n' "$name" "$bucket"
  fi
done

echo "skills-status: $have of $total installed"
