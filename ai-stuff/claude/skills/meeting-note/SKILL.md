---
name: meeting-note
description: Create a meeting note in the vault with proper frontmatter and structure. Use when starting or documenting a meeting.
tools: Write, Read, Glob
argument-hint: <meeting title>
---

# Create Meeting Note

Create a meeting note in the Obsidian vault following the established template.

## Instructions

1. Parse the meeting title from: `$ARGUMENTS`
   - If no arguments provided, ask for the meeting title
2. Get today's date in `YYYY-MM-DD` format
3. Create the file at: `~/vault/work/meetings/YYYY-MM-DD <title>.md`
   - Use the vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`

### File Format

```markdown
---
date: YYYY-MM-DD HH:mm
type: meeting
client: N/A
tags: meeting
summary: " "
---
tags: [[salonized/meetings/moc]]
Date: [[YYYY-MM-DD]]

# [[YYYY-MM-DD <title>]]

**Attendees**:
-

## Agenda

*What is the meeting agenda*

## Questions
-

## Notes
-

## Action Items
```

4. Use the current time for the `date` field (YYYY-MM-DD HH:mm format)
5. The H1 title must be a wikilink wrapping the full filename (without .md)
6. Report the created file path when done
