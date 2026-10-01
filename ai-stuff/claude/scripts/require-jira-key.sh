#!/usr/bin/env bash
# PreToolUse(Bash): block PR/MR creation until the branch or title carries a Jira key.

input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
cwd=$(jq -r '.cwd // "."' <<<"$input")

pr_re='(gh pr create|glab mr create)'
key_re='[A-Z][A-Z0-9]+-[0-9]+'

[[ $cmd =~ $pr_re ]] || exit 0
[[ $cmd == *JIRA_SKIP=1* ]] && exit 0

branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
[[ "$branch $cmd" =~ $key_re ]] && exit 0

echo "No Jira key on branch '$branch' or in the PR title. Call the Skill tool with \"log-work\", then retry with the key it returns at the start of the PR title, or prefix the command with JIRA_SKIP=1 if it returns that." >&2
exit 2
