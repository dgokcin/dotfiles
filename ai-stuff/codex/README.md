# Codex Layer

Codex consumes the universal skills from [`ai-stuff/skills/`](../skills/) —
see [ai-stuff/README.md](../README.md). `make codex` installs:

- **Skills** — `ai-codex` symlinks every skill dir + `_shared` into `~/.codex/skills`
- **Hooks** — [`hooks.json`](hooks.json) → `~/.codex/hooks.json`
- **Hook scripts** — into `~/.codex/scripts/`

## Hooks

Codex's hook system (v0.117+) adopted Claude Code's protocol: same stdin
payload (`tool_name`, `tool_input`, `cwd`, ...) and same output schema
(`hookSpecificOutput.permissionDecision`, `decision.behavior`, ...). That
makes most Claude hooks portable — shared scripts live in
[`ai-stuff/_shared/scripts/`](../_shared/scripts/) and each tool symlinks
them into its own scripts dir.

Converted from the Claude Code setup:

| Event | Hook | Notes |
| --- | --- | --- |
| SessionStart | caveman-mode context echo | migrated from hand-made `~/.codex/hooks.json` |
| SessionStart | git worktree context echo | same command as Claude's |
| PreToolUse | `auto-approve-tools.sh pre-tool` | shared script, identical JSON protocol |
| PreToolUse | `rtk hook claude` | rtk has no `codex` processor yet; its `claude` processor speaks the same protocol. Deliberately emits `updatedInput` with **no** `permissionDecision`: rtk rewrites mutating commands too (`git push`, `curl`), so auto-approving every rewrite would bypass prompts. The allowlist hook (with its `rtk `-prefixed read-only rules) + codex's own permission flow decide on the rewritten command |
| PermissionRequest | `auto-approve-tools.sh permission` | shared script |
| PostToolUse (`apply_patch\|Edit\|Write`) | nvim `checktime` | refresh open buffers |
| Stop | `notify-stop.sh` | terminal-notifier + click-to-focus iTerm |

**Not portable** (no Codex equivalent): `Notification` event (cc-notifier
permission alerts), `SessionEnd` (cc-notifier cleanup), `WorktreeCreate`/
`WorktreeRemove`, statusline, file-suggestion.

## Trust

Codex requires reviewing + trusting non-managed hooks: run `/hooks` inside
Codex after install (or re-install). Editing a hook changes its hash →
re-review.
