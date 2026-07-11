---
name: add-recipe
description: Add a cooking recipe to the vault with proper frontmatter. Accepts a recipe name, description, or URL to parse.
tools: Write, Read, Glob, WebFetch
disable-model-invocation: true
argument-hint: <recipe name or URL>
---

# Add Recipe

Add cooking recipe to Obsidian vault in established format.

## Instructions

1. Parse input from: `$ARGUMENTS`
   - URL → fetch page, extract recipe
   - Name/description → create note
   - No args → ask what recipe to add
2. Create file at: `~/vault/personal/cooking/<recipe-name-slug>.md`
   - Vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
   - slug: lowercase with spaces (e.g., "citir tavuk.md", "boyoz.md")

### File Format

```markdown
---
title: <Recipe Name>
ingredients:
  - ingredient 1
  - ingredient 2
steps:
  - Step 1 description.
  - Step 2 description.
tags:
  - cooking
  - <category tag: e.g., breakfast, dinner, snack>
  - <cuisine tag: e.g., Turkish, Italian>
  - <type tag: e.g., pastry, meat, vegetarian>
prep_time: X min
cook_time: X min
difficulty: Easy|Medium|Hard
servings: X
category: <Breakfast|Lunch|Dinner|Snack|Dessert|Side>
rating: <1-5, leave empty if new>
notes: <brief personal note about the recipe>
---

<Optional personal notes in Turkish or English - casual cooking tips, shortcuts, or reminders>
```

### Rules

- Steps: concise, practical (not essay-style)
- Body below frontmatter: casual personal notes (Turkish ok)
- User input in Turkish → keep Turkish in body
- Frontmatter fields (title, steps, ingredients): English
- Tags: `cooking` + relevant category/cuisine/type
- Report created file path when done