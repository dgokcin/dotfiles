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

Fill the funda viewing request form for the property at: $ARGUMENTS

## My Details

@~/.claude/config/_house-search-private.md

## Form Fields to Fill

The funda viewing form has these fields:

1. **Question textarea**: Leave empty (optional field)
2. **Request viewing checkbox**: Check "I would like to request a viewing of this house"
3. **Days available**: Select ALL days (Mo, Tu, We, Th, Fr)
4. **Part of day**: Select BOTH (Morning, Afternoon)
5. **Email**: dgokcin+funda@gmail.com (may be pre-filled from login)
6. **First name**: Deniz
7. **Last name**: Gokcin
8. **Phone number**: +31629778322
9. **Postcode**: 1013RJ
10. **House number**: 423
11. **Addition**: (leave empty)
12. **Selling current house**: Select "No"
13. **Financial consultation**: Select "Yes"

## Steps

1. Navigate to the funda listing URL if not already there
2. Find and click the "Plan bezichtiging" or "Plan viewing" button
3. Wait for the form to load
4. Fill all form fields as specified above
5. Take a screenshot of the filled form for verification
6. Submit the form
7. After successful submission, update the property note in Obsidian:
   - Set `viewing_requested: true`
   - Set `viewing_requested_date: <today's date in YYYY-MM-DD format>`
8. Report success with confirmation details
