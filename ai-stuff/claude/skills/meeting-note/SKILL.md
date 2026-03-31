---
name: meeting-note
description: "Create a meeting note in the vault with proper frontmatter and structure. Use when the user mentions a meeting, wants to take notes for a call, says 'meeting with X', 'sync with X', 'let me document this call', or is about to join or just finished a meeting."
tools: Bash, Read
argument-hint: <meeting title>
---

# Create Meeting Note

Create a meeting note in the Obsidian vault using the `meeting-template` via the Obsidian CLI.

## Instructions

1. Parse the meeting title from: `$ARGUMENTS`
   - If no arguments provided, ask for the meeting title
2. Create the note using the Obsidian CLI:
   ```bash
   obsidian create name="<meeting title>" template="meeting-template"
   ```
   The template handles everything — frontmatter, date prefix, folder placement (`work/meetings/`), and structure. No need to manually construct paths or content.
3. Confirm creation and report the file path

### What the template produces

The meeting-template creates a note at `work/meetings/YYYY-MM-DD <title>.md` with:
- Frontmatter: date, type, client, tags, summary
- Sections: Attendees, Agenda, Questions, Notes, Action Items
- Wikilinks to the daily note and meetings MoC

### After creation

If the user provided attendees, agenda items, or context in their message, use `obsidian append` to fill in the relevant sections:
```bash
obsidian append file="YYYY-MM-DD <title>" content="- @person1\n- @person2"
```

### Summary field

The `summary` frontmatter field is important — it powers the meeting views (MoC, date summary, monthly summary). Remind the user to fill it in after the meeting, or offer to set it if they share what the meeting was about:
```bash
obsidian property:set file="YYYY-MM-DD <title>" name="summary" value="discussed X and decided Y"
```
