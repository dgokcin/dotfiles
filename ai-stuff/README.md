# AI Stuff — Universal Skills, One Source of Truth

Skills are authored **once** in [`skills/`](skills/) using the
[Agent Skills](https://agentskills.io) standard (the format Claude Code,
Codex, Cursor, Gemini CLI, and ~50 other tools read natively) and installed
into every tool by symlink. Switching or adding an LLM provider costs one
line in a Makefile table — never a second copy of a skill.

The approach mirrors [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)'s
platform installer (`tools/installer/ide/platform-codes.yaml`): one
tool-agnostic skill format + a per-tool directory registry + verbatim
installation. No per-tool transformation, no drift.

## Layout

```
ai-stuff/
├── skills/            # ⭐ single source of truth — universal Agent Skills
│   ├── _shared -> ../_shared   # makes relative ../_shared/... refs resolve
│   ├── slackify/
│   │   ├── SKILL.md            # frontmatter drives Claude Code
│   │   └── agents/openai.yaml  # picker metadata + policy for Codex
│   ├── daily-recap/SKILL.md + agents/ + scripts/
│   ├── vault-capture/SKILL.md + agents/ + references/
│   ├── .archived/     # retired skills (never installed)
│   └── ...
├── invocation.md      # user- vs model-invoked rules, Skill-tool phrasing, openai.yaml schema
├── _shared/           # personas, configs, templates referenced by skills+agents
│   ├── personas/      # gitboi, jira-girl, mega-dev, ...
│   ├── config/        # git-config, jira-config, .clusters.json, ...
│   └── templates/     # property/daily-recap output templates
├── agents/            # subagent definitions (Claude Code + Cursor)
├── claude/            # Claude Code-specific layer: settings.json, hook scripts
├── codex/             # Codex-specific layer (currently nothing beyond skills)
├── continue/          # Continue.dev config
└── fabric/            # Fabric patterns
```

## Installation

Driven by [`makefiles/ai.mk`](../makefiles/ai.mk) — the tool registry:

| Target       | Installs to        | Covers                                                               |
| ------------ | ------------------ | -------------------------------------------------------------------- |
| `ai-claude`  | `~/.claude/skills` | Claude Code                                                           |
| `ai-agents`  | `~/.agents/skills` | Codex, Cursor, Gemini CLI, Windsurf, Warp, Copilot, Roo, OpenHands, … |

Codex has no dedicated target: it ignores `~/.codex/skills` and reads only
`.agents/skills` (repo + `$HOME`), so `ai-agents` covers it. Cursor natively
also scans `~/.claude/skills` and `~/.claude/agents` — those entries are the
same symlinked files, deduplicated by `name`.

```bash
make ai          # ai-check, then install skills into all registered tools
make ai-check    # lint SKILL.md <-> agents/openai.yaml (invocation policy, legacy keys, leftovers)
make ai-skill-meta  # scaffold agents/openai.yaml for skills missing one
make ai-list     # show skills + tool registry
make ai-clean    # remove installed skills everywhere
make claude      # claude layer (agents/personas/configs/scripts/settings) + ai-claude
make cursor      # cursor agents + ai-agents (+ prunes legacy ~/.cursor layout)
make codex       # codex layer (hooks/AGENTS.md/config.toml managed block) + ai-agents
```

Each install: prune legacy names → `rm` old entry → symlink the whole skill
directory. Whole-dir symlinks mean new files inside a skill (references,
scripts) ship without touching any Makefile.

**Add a tool** (e.g. Cline) — 2 lines in `ai.mk`:

```make
AI_TOOLS += cline
ai_skills_dir_cline := ${HOME}/.cline/skills
```

**Add a skill** — create `ai-stuff/skills/<name>/SKILL.md`, decide whether it
is user- or model-invoked per [`invocation.md`](invocation.md), run
`make ai-skill-meta` and curate the generated `agents/openai.yaml`
`short_description`, then `make ai`. Discovery is by wildcard; `ai-check`
refuses to install if the two metadata files disagree.

**Retire a skill** — move its dir to `skills/.archived/` and append the name
to `AI_LEGACY_SKILLS` in `ai.mk` so installs prune it everywhere (BMAD's
`removals.txt` pattern).

## Portability conventions

Skills must work in any tool. Rules used throughout `skills/`:

1. **Shared content = relative markdown links.**
   `[GitBoi persona](../_shared/personas/gitboi.md)` — resolves from the
   skill's directory in the repo *and* in every install tree (the `_shared`
   symlink sits next to the installed skills). Never reference
   `~/.claude/...` for content another tool needs to read.

2. **`!`command`` dynamic-context lines are kept.**
   Claude Code executes them eagerly and injects the output before the model
   sees the prompt. Other tools show the line as text — models read it as
   "run this command", which degrades gracefully to one extra tool call.

3. **Claude-specific frontmatter keys are kept** (`allowed-tools`, `agent`,
   `context: fork`, `disable-model-invocation`). The Agent Skills spec says
   unknown keys are ignored, so other tools skip them. Claude Code is the
   primary driver here; don't strip its metadata for purity. The one key
   with a cross-tool twin is `disable-model-invocation`: it must agree with
   `policy.allow_implicit_invocation` in `agents/openai.yaml` (Codex). Rules
   and the openai.yaml schema live in [`invocation.md`](invocation.md).

6. **Cross-skill calls say `Call the Skill tool with "<name>"`**, never
   `/name`, and only ever target a model-invoked skill. See
   [`invocation.md`](invocation.md).

4. **Executable helpers used by universal skills live in `_shared/scripts/`**
   and are referenced via `~/.config/ai-shared/scripts/...` (e.g.
   `pr-status.sh`, `worktree-cleanup-*.sh`). That path is installed by
   `make ai-shared` — part of every tool's install target — so it resolves no
   matter which tool invokes the skill. Never reference `~/.claude/scripts/...`
   from a universal skill: it only exists when `make claude` ran.

5. **Skill-local assets stay inside the skill** (`references/`, `scripts/`)
   and are referenced by bare relative paths — self-contained, BMAD-style.

## Tool-specific layers

Anything that is *not* a skill stays out of `skills/`:

- **`agents/`** — subagent definitions with `tools:`/`model:` frontmatter.
  Installed to `~/.claude/agents` and `~/.cursor/agents`. They reference
  personas/configs via the tool-agnostic `~/.config/ai-shared/...` path
  (`make ai-shared` symlinks it to `ai-stuff/_shared`), so the same agent
  file works in every tool that can read files.
- **`claude/`** — `settings.json` (hooks, permissions, statusline, plugins)
  and Claude-only hook scripts. See [claude/README.md](claude/README.md).
- **`codex/`** — `hooks.json` + Codex-only hook scripts. Codex skill-picker
  metadata is *not* here: it lives beside each skill in `agents/openai.yaml`. See
  [codex/README.md](codex/README.md).
- **`_shared/scripts/`** — scripts shared across tools. Hook scripts
  (`auto-approve-tools.sh`, `focus-iterm.applescript`): Codex adopted Claude
  Code's hook protocol, so the same scripts serve both — symlinked into each
  tool's own scripts dir, never referenced across tool homes. Skill helpers
  (`pr-status.sh`, `worktree-cleanup-*.sh`): invoked by universal skills via
  the tool-agnostic `~/.config/ai-shared/scripts/...` path.
- Hooks have no cross-tool *standard* (event names/config differ per tool),
  so hook configs stay per-tool by design. A skill must never depend on
  hooks to function, only get better when they exist.
