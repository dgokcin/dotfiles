---
name: weekly-review
description: Generate a weekly review by aggregating daily notes, meetings, and completed tasks from the current or specified week.
---

# Weekly Review

Generate a weekly review summary by reading actual daily notes and meetings from the vault.

## Instructions

1. Parse the week from: `the user's input`
   - If a week string like `2026-W11`: use that week
   - If empty: use the current week
2. Calculate the Monday-Friday date range for the target week
3. Read all daily notes in that range from: `~/vault/work/daily notes/`
   - Use the vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
   - Files are named `YYYY-MM-DD.md`
4. Read all meeting notes from that date range in: `~/vault/work/meetings/`
   - Files are prefixed with `YYYY-MM-DD`
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

- Read the actual file contents - don't guess or invent
- Extract tasks from the `## today` section of daily notes (lines starting with `- [x]` or `- [ ]`)
- Extract "notes for tomorrow" sections from each day
- For meetings, read the `## Notes` and `## Action Items` sections
- Keep the summary concise but complete
- If a daily note doesn't exist for a weekday, note it (likely PTO/holiday)
- Output directly to the conversation - do NOT create a file unless asked
