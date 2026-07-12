#!/usr/bin/env bash
# PreToolUse + PermissionRequest hook: auto-approve tool calls
# Workaround for https://github.com/anthropics/claude-code/issues/18160
#
# Uses the same permission format as settings.json allow rules.
# Bash(cmd *) matches command by glob. Read/Glob/Grep/etc match by path glob.
# Bare tool name (e.g. "Read") matches all calls to that tool.
# Tilde (~) is expanded to $HOME.
#
# Compound Bash commands (&&, ||, ;) are split and EVERY segment must match a
# rule (subshell parens are stripped). A leading "rtk " is ignored when
# matching, so one rule covers both plain and rtk-rewritten forms. Quotes are
# not parsed — a quoted '&&' splits too, which fails safe: the mangled
# segment won't match, the hook stays silent, and the tool's normal
# permission prompt takes over.
#
# Called with $1 = "pre-tool" (default) or "permission"

ALLOW=(
  "Read(~/codes/**)"
  "Read(~/.claude/**)"
  "Glob"
  "Grep"
  "Bash(git log *)"
  "Bash(git show *)"
  "Bash(git status*)"
  "Bash(git diff*)"
  "Bash(git branch*)"
  "Bash(git rev-parse*)"
  "Bash(git ls-files*)"
  "Bash(git worktree list*)"
  "Bash(git symbolic-ref *)"
  "Bash(git remote -v*)"
  "Bash(git config --get *)"
  "Bash(true)"
  "Bash(ls:*)"
  "Bash(ls *)"
  "Bash(find:*)"
  "Bash(head:*)"
  "Bash(grep *)"
  "Bash(gh pr view *)"
  "Bash(gh pr diff *)"
  "Bash(gh pr list *)"
  "Bash(glab mr view *)"
  "Bash(glab mr diff *)"
  "Bash(glab mr list *)"
  "Bash(rtk grep *)"
  "Bash(rtk read *)"
)

INPUT=$(cat 2>/dev/null || true)
MODE="${1:-pre-tool}"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // .tool // empty' 2>/dev/null)

[ -z "$TOOL" ] && { echo '{}'; exit 0; }

approve() {
  if [ "$MODE" = "permission" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
  else
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"permissionDecisionReason\":\"Auto-approved ${1}\"}}"
  fi
  exit 0
}

# Expand ~ and normalize ** to * for bash glob matching
expand_pattern() {
  local p="${1/\~/$HOME}"
  echo "${p//\*\*/*}"
}

# Does a single (non-compound) command match any Bash rule?
cmd_allowed() {
  local cmd="$1" rule pattern
  local bare="${cmd#rtk }"
  for rule in "${ALLOW[@]}"; do
    [[ "$rule" =~ ^Bash\((.+)\)$ ]] || continue
    # Normalize colon format: "ls:*" → "ls *"
    pattern=$(expand_pattern "${BASH_REMATCH[1]/:/ }")
    # shellcheck disable=SC2254
    if [[ "$cmd" == $pattern || "$bare" == $pattern ]]; then
      return 0
    fi
  done
  return 1
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  echo "$s"
}

if [ "$TOOL" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
  if [ -n "$CMD" ]; then
    # Split compound command into segments on && / || / ;
    segs="${CMD//&&/$'\n'}"
    segs="${segs//\|\|/$'\n'}"
    segs="${segs//;/$'\n'}"
    all_ok=1
    while IFS= read -r seg; do
      seg=$(trim "$seg")
      # Strip subshell parens: "(git foo" / "git foo)"
      seg="${seg#\(}"
      seg="${seg%\)}"
      seg=$(trim "$seg")
      [ -z "$seg" ] && continue
      cmd_allowed "$seg" || { all_ok=0; break; }
    done <<<"$segs"
    [ "$all_ok" -eq 1 ] && approve "Bash allowlist (all segments)"
  fi
else
  for rule in "${ALLOW[@]}"; do
    # Bare tool name: "Read", "Glob", etc.
    if [[ "$rule" == "$TOOL" ]]; then
      approve "$rule"
    fi

    # Tool(pattern) format
    if [[ "$rule" =~ ^([A-Za-z]+)\((.+)\)$ ]]; then
      rule_tool="${BASH_REMATCH[1]}"
      rule_arg="${BASH_REMATCH[2]}"

      [ "$TOOL" != "$rule_tool" ] && continue

      PATH_ARG=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.pattern // empty' 2>/dev/null)
      pattern=$(expand_pattern "$rule_arg")
      # shellcheck disable=SC2254
      [[ "$PATH_ARG" == $pattern ]] && approve "$rule"
    fi
  done
fi

echo '{}'
