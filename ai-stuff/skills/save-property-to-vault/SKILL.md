---
name: save-property-to-vault
description: Save an analyzed property listing to the Obsidian vault using the property frontmatter schema and body template. Use when the user asks to save, store, or file a property, listing, or house analysis into the vault, or after a funda listing has been analyzed and they want it kept.
model: haiku
allowed-tools: Read, Write, Edit, Glob
---

Save property analysis to Obsidian vault.

## Templates

Read both templates — relative paths resolve from this skill's directory:

- [property frontmatter schema](../_shared/templates/property-frontmatter.yaml)
- [property body template](../_shared/templates/property-template.md)

## Vault Configuration

Read [house search config](../_shared/config/house-search-config.md).

## Instructions

1. Read frontmatter schema from `property-frontmatter.yaml`
2. Read body template from `property-template.md`
3. Create property note at: `~/vault/personal/nl/house search/buying a house/properties/<address-slug>.md`
   - Address slug: lowercase, spaces allowed (e.g., "van woustraat 123.md")
4. Populate all frontmatter fields from analysis data
5. Set `viewing_requested: false` initially
6. Set `found_date` to today's date
7. Fill body sections from analysis
8. Use `[[wikilinks]]` for internal links (e.g., `[[Neighborhood Name]]`)
9. If neighborhood note missing, create via neighborhood template at `~/vault/personal/nl/house search/buying a house/neighborhoods/<neighborhood-slug>.md`

## Important

- Do NOT edit MoC manually — Dataview queries handle property lists
- `tier` field determines MoC section
- Always include funda URL as clickable link in Summary