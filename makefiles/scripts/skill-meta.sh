#!/usr/bin/env bash
# skill-meta.sh — keep every universal skill agent-agnostic.
#
# Each skill in ai-stuff/skills/<name>/ carries two metadata surfaces that must
# agree (see ai-stuff/invocation.md):
#   SKILL.md frontmatter      -> Claude Code (disable-model-invocation, ...)
#   agents/openai.yaml        -> Codex skill picker (interface.*, policy.*)
#
# Usage:
#   skill-meta.sh [--check]     lint every skill, exit 1 on any violation (default)
#   skill-meta.sh --scaffold    write a starter agents/openai.yaml where missing
#                               (never overwrites; curate short_description after)
#
# Requires mikefarah yq v4 (brew install yq).

set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="${SKILLS_DIR:-$REPO/ai-stuff/skills}"
MAX_SHORT=64

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

mode=check
case "${1:-}" in
  ""|--check) mode=check ;;
  --scaffold) mode=scaffold ;;
  -h|--help) usage; exit 0 ;;
  *) echo "skill-meta: unknown argument '$1'" >&2; usage >&2; exit 2 ;;
esac

if ! command -v yq >/dev/null 2>&1; then
  echo "skill-meta: yq not found. Install with 'brew install yq' (or 'make yq')." >&2
  exit 2
fi

# fm FILE EXPR -> frontmatter value, "null" when absent
fm() { yq --front-matter=extract "$2" "$1" 2>/dev/null || echo null; }
# yv FILE EXPR -> yaml value, "null" when absent
yv() { yq "$2" "$1" 2>/dev/null || echo null; }

# title_case "aws-debug" -> "Aws Debug"
title_case() {
  awk -F- '{ for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2); print }' OFS=' ' <<<"$1"
}

# first_sentence "A. B c." -> "A." truncated to MAX_SHORT
first_sentence() {
  local s
  s="$(sed -E 's/([.!?])( .*)?$/\1/' <<<"$1")"
  s="$(sed -E 's/^(.{'"$MAX_SHORT"'}).+$/\1/' <<<"$s")"
  printf '%s' "$s"
}

violations=0
fail() { printf '  %-24s %s\n' "$1" "$2"; violations=$((violations + 1)); }

skills=0
scaffolded=0
for dir in "$SKILLS_DIR"/*/; do
  dir="${dir%/}"
  name="$(basename "$dir")"
  skill_md="$dir/SKILL.md"
  [ -f "$skill_md" ] || continue          # _shared symlink, stray files
  skills=$((skills + 1))

  yaml="$dir/agents/openai.yaml"
  if ! yq --front-matter=extract '.' "$skill_md" >/dev/null 2>&1; then
    fail "$name" "SKILL.md frontmatter is not valid YAML"
    continue
  fi
  fm_name="$(fm "$skill_md" '.name')"
  desc="$(fm "$skill_md" '.description')"
  dmi="$(fm "$skill_md" '.["disable-model-invocation"]')"
  legacy_tools="$(fm "$skill_md" '.tools')"

  if [ "$mode" = scaffold ]; then
    [ -f "$yaml" ] && continue
    display="$(title_case "$name")"
    short=""
    [ "$desc" != null ] && short="$(first_sentence "$desc")"
    short="${short//\"/\\\"}"
    mkdir -p "$dir/agents"
    {
      printf 'interface:\n'
      printf '  display_name: "%s"\n' "$display"
      printf '  short_description: "%s"\n' "$short"
      if [ "$dmi" = true ]; then
        printf 'policy:\n'
        printf '  allow_implicit_invocation: false\n'
      fi
    } >"$yaml"
    echo "scaffolded $name/agents/openai.yaml (curate short_description)"
    scaffolded=$((scaffolded + 1))
    continue
  fi

  # --- check mode -----------------------------------------------------------
  [ "$fm_name" = "$name" ] || fail "$name" "frontmatter name '$fm_name' != directory name"
  [ "$legacy_tools" = null ] || fail "$name" "legacy 'tools:' key; use 'allowed-tools:'"
  [ "$dmi" != false ] || fail "$name" "'disable-model-invocation: false' is the default; drop the key"
  [ ! -e "$dir/SKILL.original.md" ] || fail "$name" "stale SKILL.original.md; delete it"

  if [ ! -f "$yaml" ]; then
    fail "$name" "missing agents/openai.yaml (run: make ai-skill-meta)"
    continue
  fi

  display="$(yv "$yaml" '.interface.display_name')"
  short="$(yv "$yaml" '.interface.short_description')"
  allow="$(yv "$yaml" '.policy.allow_implicit_invocation')"

  [ -n "$display" ] && [ "$display" != null ] || fail "$name" "openai.yaml: interface.display_name missing"
  if [ -z "$short" ] || [ "$short" = null ]; then
    fail "$name" "openai.yaml: interface.short_description missing"
  elif [ "${#short}" -gt "$MAX_SHORT" ]; then
    fail "$name" "openai.yaml: short_description is ${#short} chars (max $MAX_SHORT)"
  fi

  if [ "$dmi" = true ] && [ "$allow" != false ]; then
    fail "$name" "user-invoked in Claude (disable-model-invocation: true) but openai.yaml lacks policy.allow_implicit_invocation: false"
  elif [ "$dmi" != true ] && [ "$allow" = false ]; then
    fail "$name" "openai.yaml blocks implicit invocation but SKILL.md lacks disable-model-invocation: true"
  fi
done

if [ "$mode" = scaffold ]; then
  echo "skill-meta: $scaffolded scaffolded, $skills skills total"
  exit 0
fi

if [ "$violations" -gt 0 ]; then
  echo "skill-meta: $violations violation(s) across $skills skills" >&2
  exit 1
fi
echo "skill-meta: $skills skills OK"
