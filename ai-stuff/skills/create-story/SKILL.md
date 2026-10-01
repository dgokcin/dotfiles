---
name: create-story
description: Create a Jira story with proper ADF formatting. Use when the user asks to create a Jira story, ticket, or issue, wants requirements or notes turned into a ticket, or says "make a story for X".
context: fork
model: sonnet
allowed-tools: mcp__claude_ai_Atlassian_MCP__getJiraIssue, Read
argument-hint: <story description or requirements>
---

# Create Jira Story

## Configuration
Read [jira config](../_shared/config/jira-config.md).

## Instructions

Create properly formatted Jira Story for DEVX project.

### Process

1. Parse user description from: `$ARGUMENTS`
2. **NEVER** call lookup APIs - use hardcoded values:
   - cloudId: `56552dac-b6cf-4e59-aa06-5e075dca9f8e`
   - projectKey: `DEVX`
   - issueTypeName: `Story`
3. Craft concise, action-oriented summary
4. Build description in **MARKDOWN** format:
   ```markdown
   ## Problem
   [What needs to be done]

   ## Proposed Solution
   [How we'll solve it]

   ## Implementation Details
   [Technical specifics]
   ```
5. Create `customfield_14105` (Reason for change) in **ADF** format - REQUIRED!
6. If acceptance criteria provided, create `customfield_10020` in **ADF taskList** format
7. Execute `mcp__claude_ai_Atlassian_MCP__createJiraIssue`
8. Provide the issue URL: `[DEVX-XXX](https://wahanda.atlassian.net/browse/DEVX-XXX)`

### Critical Reminders

- Description = MARKDOWN, Custom fields = ADF
- NEVER put acceptance criteria in description - use `customfield_10020`!
- NEVER use markdown checkboxes (`- [ ]`) - they don't render!
- Each taskItem needs a unique localId (UUID format)
- `customfield_14105` REQUIRED - always include!

### Final Reply

Reply with only `[DEVX-XXX](https://wahanda.atlassian.net/browse/DEVX-XXX)`.
