#!/usr/bin/env bash
# PreToolUse + PermissionRequest hook: auto-approve tool calls
# Workaround for https://github.com/anthropics/claude-code/issues/18160
#
# Uses the same permission format as settings.json allow rules.
# Bash(cmd *) matches command by glob. Read/Glob/Grep/etc match by path glob.
# Bare tool name (e.g. "Read") matches all calls to that tool.
# Tilde (~) is expanded to $HOME.
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
  "Bash(rtk git log *)"
  "Bash(rtk git show *)"
  "Bash(rtk git status*)"
  "Bash(rtk git diff*)"
  "Bash(rtk git branch*)"
  "Bash(rtk ls *)"
  "Bash(rtk find *)"
  "Bash(rtk head *)"
  "Bash(rtk gh pr view *)"
  "Bash(rtk gh pr diff *)"
  "Bash(rtk gh pr list *)"
  "Bash(rtk glab mr view *)"
  "Bash(rtk glab mr diff *)"
  "Bash(rtk glab mr list *)"
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

    if [ "$TOOL" = "Bash" ]; then
      CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
      # Normalize colon format: "ls:*" → "ls *"
      pattern=$(expand_pattern "${rule_arg/:/  }")
      # shellcheck disable=SC2254
      [[ "$CMD" == $pattern ]] && approve "$rule"
    else
      PATH_ARG=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.pattern // empty' 2>/dev/null)
      pattern=$(expand_pattern "$rule_arg")
      # shellcheck disable=SC2254
      [[ "$PATH_ARG" == $pattern ]] && approve "$rule"
    fi
  fi
done

echo '{}'
