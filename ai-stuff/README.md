# AI Stuff

Per-tool AI configuration plus the content those tools share. Skills live in
a separate repo, `~/codes/skills`, and `make skills` installs them into
`~/.claude/skills` and `~/.agents/skills` (see [`makefiles/skills.mk`](../makefiles/skills.mk)).

## Layout

```
ai-stuff/
├── _shared/           # tool-agnostic content, linked to ~/.config/ai-shared
│   ├── config/        # git, gitops, jira, house-search config
│   ├── scripts/       # hook scripts and helpers shared across tools
│   └── templates/     # property and daily-recap output templates
├── agents/            # subagent definitions (Claude Code + Cursor)
├── output-styles/     # Claude Code output styles
├── claude/            # Claude Code settings, keybindings, hook scripts, mods
├── codex/             # Codex hooks, AGENTS.md, managed config.toml block
└── cursor/            # Cursor hooks, CLI config, editor settings, keybindings
```

## Installation

| Target      | Installs                                                        |
| ----------- | --------------------------------------------------------------- |
| `ai-shared` | `ai-stuff/_shared` to `~/.config/ai-shared`                     |
| `claude`    | agents, output styles, scripts, settings, keybindings, `ai-shared` |
| `cursor`    | agents, hook scripts, hooks.json, CLI config, editor settings   |
| `codex`     | hooks, `AGENTS.md`, `RTK.md`, managed `config.toml` block        |

Every install is a symlink back into this repo.

## Shared content

- **`_shared/`** is reachable at the tool-agnostic path
  `~/.config/ai-shared/...`. Agents and external skills reference it there, so
  the same file works in every tool and never depends on `~/.claude/...`.
- **`_shared/scripts/`** holds hook scripts (`auto-approve-tools.sh`,
  `focus-iterm.applescript`) that each tool's install symlinks into its own
  scripts dir. Codex adopted Claude Code's hook protocol, so the same scripts
  serve both. Cursor reuses the allowlist through an adapter.
- Hooks have no cross-tool standard, so hook configs stay per-tool.

## Tool-specific layers

- **`agents/`** holds subagent definitions with `tools:`/`model:`
  frontmatter, installed to `~/.claude/agents` and `~/.cursor/agents`.
- **`claude/`** holds `settings.json` and Claude-only hook scripts. See
  [claude/README.md](claude/README.md).
- **`codex/`** holds `hooks.json` and the managed config block. See
  [codex/README.md](codex/README.md).
- **`cursor/`** holds Cursor hooks and settings. See
  [cursor/README.md](cursor/README.md).
