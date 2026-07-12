#!/usr/bin/env bash
# Sync the dotfiles-managed block of ~/.codex/config.toml from
# config.managed.toml. Only the block between the markers is owned by
# dotfiles; everything else (project trust levels, hooks.state trusted
# hashes, caches) is machine state and left untouched.
#
# The block is prepended because TOML requires top-level keys to appear
# before the first table header.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config.managed.toml"
DST="${CODEX_HOME:-$HOME/.codex}/config.toml"
BEGIN="# --- BEGIN dotfiles-managed (ai-stuff/codex/config.managed.toml) ---"
END="# --- END dotfiles-managed ---"

mkdir -p "$(dirname "$DST")"
touch "$DST"

tmp=$(mktemp)
# Drop the previous managed block.
awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1} !skip; $0==e{skip=0}' "$DST" > "$tmp"

# Drop bare duplicates (outside any table) of top-level keys the block owns,
# so the merged file has no duplicate TOML keys.
managed_keys=$(grep -oE '^[a-zA-Z_]+' "$SRC" | sort -u)
for k in $managed_keys; do
  awk -v key="$k" '/^\[/{intable=1} !(intable!=1 && $0 ~ "^"key" *=")' "$tmp" > "$tmp.2" && mv "$tmp.2" "$tmp"
done

{ echo "$BEGIN"; cat "$SRC"; echo "$END"; echo; cat "$tmp"; } > "$DST"
rm -f "$tmp"
echo "synced managed block -> $DST"
