---
name: get-story
description: Fetch and display a Jira issue with all details. Use when user asks about a ticket, wants issue details, or says "what's in DEVX-123"
context: fork
model: sonnet
allowed-tools: mcp__claude_ai_Atlassian_MCP__getJiraIssue
argument-hint: <DEVX-XXX or issue number>
---

# Fetch Jira Issue

## Configuration

Read [jira config](../_shared/config/jira-config.md).

## Instructions

Fetch Jira issue. Display body + comments only.

### Process

1. Parse issue key from argument-hint

   - Number only (e.g., `123`) → prepend `DEVX-`
   - Full key (e.g., `DEVX-123`) → use as-is
   - Different project prefix → use that

2. Fetch:

   ```
   mcp__claude_ai_Atlassian_MCP__getJiraIssue
   - cloudId: 56552dac-b6cf-4e59-aa06-5e075dca9f8e
   - issueKey: <parsed key>
   ```

3. Display only:

   - **Description** (full content)
   - **Comments** (all footer and inline comments)

4. Provide the issue URL: `[DEVX-XXX](https://wahanda.atlassian.net/browse/DEVX-XXX)`

### Output Format

```markdown
# DEVX-XXX

[Full description content]

## Comments

[All comments displayed in order]

View: [DEVX-XXX](https://wahanda.atlassian.net/browse/DEVX-XXX)
```

### Final Reply

Show the issue details and nothing else.

### Error Handling

- **Not found**: Suggest JQL search
- **Wrong project**: Confirm project key
- **No arguments**: Ask for issue key