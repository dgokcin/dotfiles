---
name: add-vinyl
description: Add a vinyl record to the collection with Discogs metadata. Accepts artist and album name, or a Discogs URL.
tools: Write, Read, Glob, WebFetch, WebSearch
argument-hint: <"artist - album" or Discogs URL>
---

# Add Vinyl Record

Add a vinyl record to the Obsidian vault collection.

## Instructions

1. Parse input from: `$ARGUMENTS`
   - If a Discogs URL: fetch and extract metadata
   - If "artist - album" format: use web search to find the Discogs release page and extract metadata
   - If no arguments: ask for artist and album name
2. Create the file at: `~/vault/personal/vinyl/records/collection/<artist> - <album>.md`
   - Use the vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
   - filename: all lowercase (e.g., "daft punk - random access memories.md")

### File Format

```markdown
---
artist: <lowercase artist name>
album_name: <lowercase album name>
cover: <discogs cover image URL>
released: <release year>
country: <country code: EU, US, UK, etc.>
genre: <comma-separated genres, lowercase>
style: <comma-separated styles, lowercase>
discogs_link: <full discogs release URL>
date_of_purchase: <YYYY-MM-DD, default to today>
purchased_store: <store name, ask user if not provided>
---
tags:: [[virtual library]]

### Album Cover

![cover](<cover image URL>)

### Album Information

N/A
```

### Rules

- All text values in frontmatter are lowercase
- Genre and style are comma-separated strings (not arrays)
- `date_of_purchase` defaults to today if not specified
- Ask the user for `purchased_store` if not provided
- The cover image URL should be from Discogs
- `tags::` (with double colon) is inline Dataview syntax, not frontmatter
- Report the created file path when done
