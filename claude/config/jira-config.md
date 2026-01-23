# Jira Configuration Constants

## Hardcoded Values - NEVER waste tokens looking these up!

| Constant | Value |
|----------|-------|
| **cloudId** | `56552dac-b6cf-4e59-aa06-5e075dca9f8e` |
| **defaultProject** | `DEVX` |
| **atlassianUrl** | `https://wahanda.atlassian.net` |
| **currentUserAccountId** | `712020:e51cbeb5-c2ba-4aea-9f63-01e3c2ade7d4` |

## DEVX Issue Type IDs - No need to fetch!

| Type | ID |
|------|-----|
| Story | `7` |
| Task | `3` |
| Bug | `1` |
| Sub-task | `5` |
| Epic | `6` |
| Spike | `11502` |
| Support | `11719` |

## Required Custom Fields for DEVX

| Field ID | Name | Required | Format |
|----------|------|----------|--------|
| `customfield_14105` | Reason for the change | **YES** | ADF paragraph |
| `customfield_10020` | Acceptance Criteria and NFR | No | ADF taskList (checkboxes!) |
| `customfield_12700` | Team | No | - |
| `customfield_14453` | Scheduled Date | No | - |
| `customfield_14031` | Resources Required | No | - |

## Critical Rules

- **NEVER** call `getAccessibleAtlassianResources` - use hardcoded cloudId
- **NEVER** call `atlassianUserInfo` - use hardcoded accountId
- **NEVER** call `getVisibleJiraProjects` unless user explicitly mentions a non-DEVX project
- **NEVER** call `getJiraProjectIssueTypesMetadata` - use hardcoded issue type IDs
- **DEFAULT** to DEVX project unless user explicitly mentions another project prefix

## Format Rules

| Field | Format |
|-------|--------|
| `description` | **MARKDOWN** - `## headings`, `- bullets`, ``` code ``` |
| `customfield_14105` | **ADF** paragraph - REQUIRED! |
| `customfield_10020` | **ADF** taskList - renders as checkboxes! |

**CRITICAL**:
- NEVER put acceptance criteria in description - use `customfield_10020`!
- NEVER use markdown checkboxes (`- [ ]`) in description - they don't render!
- Each taskItem needs a unique localId (use UUID format)

## ADF Templates

### Simple Paragraph (for `customfield_14105` - Reason for change)
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [{"type": "text", "text": "YOUR REASON HERE"}]
    }
  ]
}
```

### Task List with Checkboxes (for `customfield_10020` - Acceptance Criteria)
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "taskList",
      "attrs": {"localId": "generate-unique-uuid-here"},
      "content": [
        {
          "type": "taskItem",
          "attrs": {"localId": "ac-1-uuid", "state": "TODO"},
          "content": [{"type": "text", "text": "First acceptance criterion"}]
        },
        {
          "type": "taskItem",
          "attrs": {"localId": "ac-2-uuid", "state": "TODO"},
          "content": [{"type": "text", "text": "Second acceptance criterion"}]
        }
      ]
    }
  ]
}
```

### Bullet List (for general lists, NOT acceptance criteria)
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "Item 1"}]}
          ]
        }
      ]
    }
  ]
}
```

## Description Template (MARKDOWN)

```markdown
## Problem
[What issue or need exists - be specific]

## Current State
[How things work now - include relevant details]

## Proposed Solution
[What changes are needed - be actionable]

## Implementation Details
[Technical specifics if applicable]

## References
- Related links/docs
```

**NOTE**: Do NOT put acceptance criteria in the description! Use `customfield_10020` with ADF taskList format instead!
