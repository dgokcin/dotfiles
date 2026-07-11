---
name: vault-capture
description: This skill should be used when the user asks to "add to my vault", "add to obsidian", "save this to my vault", "add a task", "note this down", "add a task to <epic/workstream>", "capture this", "add to my daily note", "make a note about", or otherwise wants content written into their Obsidian vault at ~/vault. Routes content to the right folder, applies vault frontmatter/tag conventions, formats tasks as `- [ ]` checkboxes, and wires up `[[wikilinks]]` automatically.
model: haiku
tools: Read, Write, Edit, Glob, Grep, Bash
---

Capture content into the Obsidian vault at `~/vault` following its established conventions. The vault is a Dataview/Templater-driven PKM with strict work/personal separation. Match existing structure — never invent new patterns.

Read `references/vault-conventions.md` for full folder map, frontmatter schemas, and tag rules before writing. Load it whenever routing is ambiguous.

## Core rules (always apply)

- Vault root: `~/vault`. Dates: `YYYY-MM-DD` everywhere.
- **Work and personal are strictly separated.** Decide the area first; never mix.
- Folders categorize, **tags stay minimal** (querying + graph only). Don't add tags a similar existing note wouldn't have.
- Use `[[wikilinks]]` for any reference to another note (people: `[[firstname lastname]]`, epics, dates like `[[2026-06-18]]`). When a target may not exist, still wikilink it — a stub link is intended.
- **Never edit `work/moc.md` or any MoC manually** — Dataview views generate those lists. Correct frontmatter is what surfaces a note.
- Before creating a note, `Glob`/`Grep` for an existing one on the topic and append instead of duplicating.

## Routing decision

1. **A task or todo** → see "Adding tasks" below.
2. **Work item / project / epic** (`work/epics-and-tasks/`) → workstream note (see "Workstreams").
3. **Something for today** ("note this", "log this", "for my daily") → append to `work/daily notes/YYYY-MM-DD.md` (today from current date). Add under the relevant section (`## today`, `### notes`, `## useful links`). Use inline code-wrapped follow-up tags (`` `#blocked` ``, `` `#action` ``, etc.) only inside a `## recap` block — see conventions.
4. **Spike / research** → `work/spikes/`.
5. **Personal** → appropriate `personal/<area>/` folder.
6. **Unsure** → ask one short clarifying question (work vs personal, or which epic).

## Adding tasks

Tasks use plain Markdown checkboxes — `- [ ] description`. Completed tasks get `- [x] ... ✅ YYYY-MM-DD`.

- A task tied to a workstream/epic → append `- [ ]` under the relevant `## ...` section of that note in `work/epics-and-tasks/`. Wikilink any referenced people, plans, or sibling notes (e.g. `→ [[oidc]]`).
- A loose/today task → append `- [ ]` under `## today` in today's daily note.
- Keep task text terse and action-first. Add Jira/MR/PR links inline as Markdown links when relevant.
- When marking a task done, change `[ ]`→`[x]` and append `✅ <today>`.

## Workstreams (`work/epics-and-tasks/`)

Each tracked work item = one note. New workstream note frontmatter:

```yaml
type: workstream
kind: epic | initiative | task
title: <Title>
status: blocked | in-progress | backlog | done
area: platform | support
jira: "DEVX-1234"
tags: [work/platform]
notes: "one-line status"
```

- `type: workstream` is what surfaces it on the board via `views/workstreamsDashboard`. A root note missing it gets flagged.
- Big items get a folder + `overview.md` workstream note; sibling detail notes are `type: note`.
- Filename: descriptive lowercase, spaces ok (e.g. `ci-cluster migration.md`).
- Cross-reference related notes with `[[wikilinks]]` (`Detail: [[automating gitlab runner bootstrapping]].`).

## Workflow

1. Determine area (work/personal) and content type → pick destination from Routing.
2. Search for an existing target note; append if found.
3. If creating: apply the matching frontmatter schema, minimal tags, wikilinks.
4. Confirm the path written and what was added (terse).

## Additional resources

- **`references/vault-conventions.md`** — full folder map, all frontmatter schemas, tag taxonomy, date/filename formats, daily-note section layout, and gotchas (Mermaid edge labels, archived/ exclusion).
