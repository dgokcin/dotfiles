---
name: save-property-to-vault
description: Save analyzed property to Obsidian vault with proper frontmatter and templates
model: haiku
tools: Read, Write, Edit, Glob
---

Save the property analysis to the Obsidian vault.

## Templates

@~/.claude/templates/property-frontmatter.yaml
@~/.claude/templates/property-template.md

## Vault Configuration

@~/.claude/config/house-search-config.md

## Instructions

1. Read the frontmatter schema from `property-frontmatter.yaml`
2. Read the body template from `property-template.md`
3. Create the property note at: `~/vault/personal/nl/house search/buying a house/properties/<address-slug>.md`
   - Address slug: lowercase, spaces allowed (e.g., "van woustraat 123.md")
4. Populate all frontmatter fields from the analysis data
5. Set `viewing_requested: false` initially
6. Set `found_date` to today's date
7. Fill in the body sections based on the analysis
8. Use `[[wikilinks]]` for internal links (e.g., `[[Neighborhood Name]]`)
9. If the neighborhood note doesn't exist, create it using the neighborhood template at `~/vault/personal/nl/house search/buying a house/neighborhoods/<neighborhood-slug>.md`

## Important

- Do NOT manually edit the MoC — Dataview queries handle property lists automatically
- The `tier` field determines which MoC section the property appears in
- Always include the funda URL as a clickable link in the Summary section
