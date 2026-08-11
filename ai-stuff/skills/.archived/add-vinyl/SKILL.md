---
name: add-vinyl
description: Add a vinyl record to the collection with Discogs metadata. Accepts artist and album name, or a Discogs URL.
disable-model-invocation: true
tools: Write, Read, Glob, WebFetch, WebSearch
argument-hint: <"artist - album" or Discogs URL>
---

# Add Vinyl Record

Add vinyl record to Obsidian vault collection.

## Instructions

1. Parse input from: `$ARGUMENTS`
   - Discogs URL → fetch + extract metadata
   - "artist - album" format → web search for Discogs release page, extract metadata
   - No args → ask for artist + album
2. Create file at: `~/vault/personal/vinyl/records/collection/<artist> - <album>.md`
   - Vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
   - Filename: all lowercase (e.g., "daft punk - random access memories.md")

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

- Frontmatter values: all lowercase
- Genre + style: comma-separated strings (not arrays)
- `date_of_purchase` defaults to today
- Ask user for `purchased_store` if missing
- Cover image URL from Discogs
- `tags::` (double colon) = inline Dataview syntax, not frontmatter
- Report created file path when done