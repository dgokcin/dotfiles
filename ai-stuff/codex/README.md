# Codex Layer

Codex reads skills only from `.agents/skills` (repo and `$HOME`) and ignores
`~/.codex/skills`. `make skills` installs skills into `~/.agents/skills`; see
[ai-stuff/README.md](../README.md). `make codex` prunes our dead symlinks in
`~/.codex/skills` and installs:

- **Hooks** — [`hooks.json`](hooks.json) → `~/.codex/hooks.json`
- **AGENTS.md + RTK.md** — [`AGENTS.md`](AGENTS.md) → `~/.codex/AGENTS.md` (Codex's global instruction file), [`RTK.md`](RTK.md) → `~/.codex/RTK.md` (rtk prefix rule — declarative equivalent of `rtk init -g --codex`)
- **config.toml managed block** — see below

## config.toml

`~/.codex/config.toml` contains machine-local project trust levels and cannot
be symlinked wholesale. Instead,
[`config.managed.toml`](config.managed.toml) holds all non-project settings and
state, and
[`scripts/sync-config.sh`](scripts/sync-config.sh) idempotently rewrites a
marker-delimited block at the top of the file (`make codex` runs it).
Project tables outside the markers are machine-local and untouched.

Hooks are enabled by default in current Codex; disable with
`[features] hooks = false`.

## Hooks

Codex's hook system accepts similar inputs to Claude Code, but its
`PreToolUse` decisions differ: `permissionDecision: "allow"` is valid only
when rewriting input. Codex's auto permission mode handles normal tool
approval, so the Claude allowlist is intentionally not installed here.

Converted from the Claude Code setup:

| Event | Hook | Notes |
| --- | --- | --- |
| SessionStart | caveman-mode context echo | migrated from hand-made `~/.codex/hooks.json` |
| SessionStart | git worktree context echo | same command as Claude's |
| PostToolUse (`apply_patch\|Edit\|Write`) | nvim `checktime` | refresh open buffers |

**Not portable** (no Codex equivalent): `WorktreeCreate`/`WorktreeRemove`,
statusline, file-suggestion.

## Trust

Codex requires reviewing + trusting non-managed hooks: run `/hooks` inside
Codex after install (or re-install). Editing a hook changes its hash →
re-review.
