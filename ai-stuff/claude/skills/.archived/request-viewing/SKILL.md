---
name: request-viewing
description: Fill a viewing request form on funda.nl for a property
context: fork
model: haiku
disable-model-invocation: true
tools: Read, Edit, mcp__claude-in-chrome__*
mcpServers:
  - claude-in-chrome
---

Fill funda viewing request form for property at: $ARGUMENTS

## My Details

@~/.claude/config/\_house-search-private.md

## Form Fields & Selectors

### Textboxes & Text Fields
- `textarea[placeholder*="question"]`: I really liked the apartment and would like to request a viewing.
- `input[type="email"]`: REDACTED@example.com
- `input[type="text"][placeholder*="First"]`: Deniz
- `input[type="text"][placeholder*="Last"]`: Gokcin
- `input[type="tel"]`: +31000000000
- `input[type="text"][placeholder*="Post code"]`: 0000XX
- `input[type="text"][placeholder*="House number"]`: 000
- `input[type="text"][placeholder*="Addition"]`: (leave empty)

### Checkboxes (use getElementById with ID)
- `#checkbox-viewingRequest`: Check
- **Days (select ALL)**: `#checkbox-Mo`, `#checkbox-Tu`, `#checkbox-We`, `#checkbox-Th`, `#checkbox-Fr`
- **Time (select BOTH)**: `#checkbox-Morning`, `#checkbox-Afternoon`

### Radio Groups
- **Selling house**: Select No (second option)
- **Financial consultation**: Select Yes (first option)

## Steps

1. Navigate directly to viewing request URL (form pre-loaded)
2. Fill all textbox fields via CSS selectors as specified
3. Check all checkbox IDs listed (use `document.getElementById(id).checked = true`)
4. Select radio options by label text or data attribute
5. Submit form with button containing "Send message" text
6. After successful submission, update property note in Obsidian:
   - Set `viewing_requested: true`
   - Set `viewing_requested_date: <today's date in YYYY-MM-DD format>`
7. Report success