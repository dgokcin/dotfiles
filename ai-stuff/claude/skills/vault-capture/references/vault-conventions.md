# Vault Conventions (`~/vault`)

Obsidian PKM vault. Work + personal knowledge, temporal planning, Dataview/CustomJS dashboards. Folders are self-describing — explore before assuming. This file mirrors the vault's own `~/vault/CLAUDE.md`; if they diverge, the vault file wins.

## Folder map

```
~/vault/
├── work/
│   ├── epics-and-tasks/      # workstream notes (epics/initiatives/tasks) + plans/ subfolder
│   ├── daily notes/          # YYYY-MM-DD.md (Periodic Notes plugin)
│   ├── monthly notes/        # YYYY-MM.md
│   ├── spikes/               # research / investigations
│   ├── meetings/             # YYYY-MM-DD [title].md (auto-filed from template)
│   ├── people/               # firstname lastname.md
│   ├── docs/ presentations/ random/ creds/ visa/
│   └── moc.md                # work dashboard — DO NOT edit manually
├── personal/
│   ├── cooking/ health/ photography/ read/ visa/ nl/ watch/
│   ├── projects/ startup ideas/ monthly-notes/ traveling/ vinyl/
│   ├── interviews/ certification/ creds/ random/ bases/
│   └── moc.md
├── templates/                # Templater templates; some auto-file on creation
├── views/<name>/view.js      # Dataview JS dashboards (dark HTML-card style)
├── scripts/                  # dataviewUtils.js → customJS.DataviewUtils
├── archived/                 # old jobs/projects, READ-ONLY, excluded from active queries
├── attachments/ meta/ random/ read later/
```

Work and personal are **strictly separated**. Never write personal content into `work/` or vice versa.

## Dates & filenames

- Dates: `YYYY-MM-DD` everywhere.
- Daily `YYYY-MM-DD.md`, weekly `YYYY-Www.md`, monthly `YYYY-MM.md`.
- Meetings `YYYY-MM-DD [title].md`, people `firstname lastname.md`.
- Folders: lowercase, spaces ok.

## Frontmatter schemas

### Workstream (`work/epics-and-tasks/` root notes)

```yaml
type: workstream          # required — drives the board view
kind: epic | initiative | task
title: ...
status: blocked | in-progress | backlog | done
area: platform | support
jira: "DEVX-1234"         # or ""
tags: [work/platform]     # add ci-cd / github-actions etc only if it aids querying
notes: "one-line status"  # short, current state; may contain a markdown link
```

Big items: a folder + `overview.md` (the workstream note); sibling detail notes use `type: note`.

### Daily note

```yaml
tags: daily
type: daily_note
creation date: YYYY-MM-DD HH:MM
modification date: <weekday string>
```

### MoC

```yaml
type: moc
tags: [work/moc]
```

## Tags (keep minimal — folders categorize; tags = querying + graph clustering)

- Note types: `#daily`, `#meeting`, `#weekly-notes`, `#monthly-notes`.
- Area clustering: `#work/platform`, `#work/support`.
- Daily-note follow-up tags — **inline, code-wrapped** `` `#tag` ``, placed in a `## recap` section so the `needsAttention` view aggregates them:
  `#blocked` `#review-stale` `#review-feedback` `#new-ticket` `#question` `#action` `#alert`.

## Tasks

- Open: `- [ ] action-first description`
- Done: `- [x] description ✅ YYYY-MM-DD`
- Grouped under `## ` section headers inside the relevant workstream note, or under `## today` in the daily note.
- Tasks plugin is installed; the simple checkbox + `✅ date` form is what these notes actually use. Add Tasks-plugin emoji metadata (📅 due, ⏫ priority) only if the user explicitly asks for scheduling/priority.
- Inline-link people/plans/PRs: `- [ ] follow up with [[Pio Francisco]] on [[oidc]] → MR https://...`

## Daily note section layout

```
# YYYY/MM/DD - Weekday
[[YYYY]] / [[YYYY-Qn|Qn]] / [[YYYY-MM|Month]] / [[YYYY-Www|Week n]]
❮ [[prev-day]] | today | [[next-day]] ❯

# daily updates
## yesterday        (dataviewjs views)
## today
- [ ] ...           ← loose tasks go here
## useful links
## notes for tomorrow
```

A `## recap` section (when present) is where code-wrapped follow-up tags live.

## Plugins

Templater (`<% %>`), Dataview (JS views), Tasks, CustomJS. Daily/periodic notes via **Periodic Notes** plugin. Use `templates/` for new notes of a known type.

## Gotchas

- **Never hand-edit MoC lists** — `views/workstreamsDashboard`, `needsAttention`, `spikesMoc` generate them from frontmatter. Fix the note's frontmatter instead.
- `archived/` is read-only and excluded from active queries — don't write there.
- Mermaid edge labels: no leading `1. ` / `1) ` (triggers "Unsupported markdown: list"). Plain strings only.
- Before creating any note, search for an existing one on the topic and append rather than duplicate.
