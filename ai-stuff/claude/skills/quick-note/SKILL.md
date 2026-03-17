---
name: quick-note
description: Quick capture a note to work/random or personal/random. Use for ad-hoc ideas, links, or anything that needs a quick home.
tools: Write, Read, Glob
argument-hint: <note title> [--personal]
---

# Quick Note

Quickly capture a note to the vault's random folders.

## Instructions

1. Parse input from: `$ARGUMENTS`
   - If `--personal` flag is present: file to `personal/random/`
   - Otherwise: default to `work/random/`
   - The remaining text is the note title
   - If no arguments: ask what to capture
2. Create the file at the appropriate path:
   - Work: `~/vault/work/random/<title-slug>.md`
   - Personal: `~/vault/personal/random/<title-slug>.md`
   - Use the vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
   - title-slug: lowercase with spaces (e.g., "devx support bot idea.md")

### File Format

```markdown
# <Title>

<content from conversation or user input>
```

### Rules

- Minimal structure - no frontmatter needed (random notes don't use it)
- Just a title and content
- If the user provides content in the same message, include it
- If only a title, create the note with the title and leave room for content
- Report the created file path when done
