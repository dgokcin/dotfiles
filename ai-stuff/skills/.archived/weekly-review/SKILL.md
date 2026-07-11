---
name: weekly-review
description: Generate a weekly review by aggregating daily notes, meetings, and completed tasks from the current or specified week.
tools: Read, Glob, Grep
disable-model-invocation: true
argument-hint: [YYYY-Www, e.g. 2026-W11]
---

# Weekly Review

Generate weekly review summary by reading actual daily notes and meetings from vault.

## Instructions

1. Parse week from: `$ARGUMENTS`
   - Week string like `2026-W11`: use that week
   - Empty: use current week
2. Calculate Mon-Fri date range for target week
3. Read all daily notes in range from: `~/vault/work/daily notes/`
   - Vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
   - Files named `YYYY-MM-DD.md`
4. Read all meeting notes in that date range from: `~/vault/work/meetings/`
   - Files prefixed with `YYYY-MM-DD`
5. Aggregate and present:

### Output Format

```markdown
## Week Summary: YYYY-Www (Mon DD - Fri DD Month)

### Completed Tasks

- [aggregated from daily notes - items marked with [x] or ✅]

### Key Meetings

- [list of meetings with brief summaries from the meeting notes]

### Notes & Decisions

- [important notes, decisions, or blockers found in daily notes]

### Carried Forward

- [uncompleted tasks or "notes for tomorrow" from the last day of the week]
```

### Rules

- Read actual file contents — no guessing/inventing
- Extract tasks from `## today` section of daily notes (lines starting with `- [x]` or `- [ ]`)
- Extract "notes for tomorrow" sections from each day
- For meetings, read `## Notes` and `## Action Items` sections
- Summary: concise but complete
- Missing daily note for weekday → note it (likely PTO/holiday)
- Output to conversation — do NOT create file unless asked