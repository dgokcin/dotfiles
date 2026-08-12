#!/usr/bin/env bash
# Sync the dotfiles-managed block of ~/.codex/config.toml from
# config.managed.toml. Only the block between the markers is owned by
# dotfiles; project trust levels stay machine-local and are left untouched.
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

# Keep only machine-local project tables outside the managed block. This also
# removes stale generated state for hooks that no longer exist.
awk '
  /^\[/ { keep = ($0 ~ /^\[projects\./) }
  keep { print }
' "$tmp" > "$tmp.2" && mv "$tmp.2" "$tmp"

{ echo "$BEGIN"; cat "$SRC"; echo "$END"; echo; cat "$tmp"; } > "$DST"
rm -f "$tmp"
echo "synced managed block -> $DST"
