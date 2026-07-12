#!/usr/bin/env bash
# Check PR/MR status for create-pr skill
# Detects VCS from remote URL and outputs current PR/MR state

remote=$(git remote -v 2>/dev/null | head -1)

if echo "$remote" | grep -q 'git.treatwell.net'; then
  glab mr view -F json 2>/dev/null && echo "MODE: UPDATE (MR exists)" || echo "MODE: CREATE (no existing MR)"
else
  gh pr view --json number,title,state,url 2>/dev/null && echo "MODE: UPDATE (PR exists)" || echo "MODE: CREATE (no existing PR)"
fi
