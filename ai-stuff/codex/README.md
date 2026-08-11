# Codex Layer

Codex consumes the universal skills from [`ai-stuff/skills/`](../skills/) —
see [ai-stuff/README.md](../README.md). **Codex reads skills only from
`.agents/skills` (repo + `$HOME`)** — it ignores `~/.codex/skills` — so
skills arrive via ai.mk's `agents` pseudo-tool (`~/.agents/skills`), which
`make codex` depends on. `make codex` installs:

- **Skills** — `ai-agents` symlinks every skill dir + `_shared` into `~/.agents/skills` (prunes the dead `~/.codex/skills`)
- **Hooks** — [`hooks.json`](hooks.json) → `~/.codex/hooks.json`
- **Hook scripts** — into `~/.codex/scripts/`
- **AGENTS.md + RTK.md** — [`AGENTS.md`](AGENTS.md) → `~/.codex/AGENTS.md` (Codex's global instruction file), [`RTK.md`](RTK.md) → `~/.codex/RTK.md` (rtk prefix rule — declarative equivalent of `rtk init -g --codex`)
- **config.toml managed block** — see below

## config.toml

`~/.codex/config.toml` is mostly machine state (project trust levels,
`hooks.state` trusted hashes, caches) and cannot be symlinked wholesale.
Instead, [`config.managed.toml`](config.managed.toml) holds the versionable
prefs (model, reasoning effort) and
[`scripts/sync-config.sh`](scripts/sync-config.sh) idempotently rewrites a
marker-delimited block at the top of the file (`make codex` runs it).
Everything outside the markers is machine-local and untouched.

Hooks are enabled by default in current Codex; disable with
`[features] hooks = false` (documented in the managed block).

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
| PreToolUse | `rtk hook claude` | rtk has no `codex` processor yet; its `claude` processor rewrites commands without granting permission. ⚠ Unverified whether Codex applies `updatedInput` mutations like Claude does — check `rtk gain` after a few Codex sessions; flat counters mean the rewrite silently no-ops |
| PostToolUse (`apply_patch\|Edit\|Write`) | nvim `checktime` | refresh open buffers |
| Stop | `notify-stop.sh` | terminal-notifier + click-to-focus iTerm |

**Not portable** (no Codex equivalent): `Notification` event (cc-notifier
permission alerts), `SessionEnd` (cc-notifier cleanup), `WorktreeCreate`/
`WorktreeRemove`, statusline, file-suggestion.

## Trust

Codex requires reviewing + trusting non-managed hooks: run `/hooks` inside
Codex after install (or re-install). Editing a hook changes its hash →
re-review.
