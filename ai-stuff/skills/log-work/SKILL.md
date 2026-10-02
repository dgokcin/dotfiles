---
name: log-work
description: Create a DEVX story for work already done on the current branch, written as a to-do, and move it to Code Review. Use when a PR or MR has no Jira key, a hook asks for one, or the user says "log this work" or "make a ticket for what I did".
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git branch:*), AskUserQuestion, mcp__claude_ai_Atlassian_MCP__createJiraIssue, mcp__claude_ai_Atlassian_MCP__transitionJiraIssue, Read
---

# Log Work

Read [jira config](../_shared/config/jira-config.md). Never call lookup APIs.

## Process

1. Gather what was done from this conversation plus:
   - `git log --oneline main..HEAD`
   - `git diff --stat main...HEAD`
2. Write it up as if the work still needs doing:
   - **summary**: imperative, at most 10 words ("Fix runner cache eviction")
   - **description** (markdown): `## Problem` and `## Proposed Solution`, 1 to 3 sentences each
   - **customfield_14105** (Reason for the change): one ADF paragraph, one sentence. Required.
3. Call `AskUserQuestion` before creating anything. Put the drafted summary and reason in the question text, header `Jira`, with these options:
   - **Create story (Recommended)**: create it as drafted
   - **Use existing ticket**: the user types the key via "Other"
   - **Skip ticket**: open the PR without a Jira key
4. Act on the answer:
   - **Create story**: continue to step 5. If the user typed edits via "Other", apply them first.
   - **Use existing ticket**: reply with that key and stop.
   - **Skip ticket**: reply `JIRA_SKIP=1` and stop. The caller prefixes the PR command with it (`JIRA_SKIP=1 gh pr create ...`) so the hook lets it through.
5. Call `createJiraIssue`:
   - cloudId `56552dac-b6cf-4e59-aa06-5e075dca9f8e`, projectKey `DEVX`, issueTypeName `Story`
   - assignee `currentUserAccountId` from the config
   - no acceptance criteria, labels, or other custom fields
6. Call `transitionJiraIssue` on the new key with transitionId `101` (moves it to **Code Review**).
7. Reply with only `[DEVX-XXX](https://wahanda.atlassian.net/browse/DEVX-XXX)`.
