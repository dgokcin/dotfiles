# Cursor Layer

Cursor reads the universal skills from the cross-tool standard directory
`~/.agents/skills` (installed by [`makefiles/ai.mk`](../../makefiles/ai.mk) via
`make ai-agents`) — see [ai-stuff/README.md](../README.md). `make cursor`
additionally installs:

- **Agents** — Cursor agents symlinked into `~/.cursor/agents` (same
  definitions as Claude Code)
- **Hooks** — [`hooks.json`](hooks.json) → `~/.cursor/hooks.json`
- **Hook scripts** — into `~/.cursor/scripts/`

## Hooks

Cursor's hook system (config `version: 1`) does **not** reuse Claude Code's
protocol the way Codex does. Two things differ:

1. **Event model.** Instead of one `PreToolUse`/`PermissionRequest` pair,
   Cursor splits permission across tool-specific events —
   `beforeShellExecution`, `beforeReadFile`, `beforeMCPExecution` — plus a
   generic `preToolUse`. Each fires with its own stdin payload
   (`{command, cwd, sandbox}`, `{file_path, ...}`, ...) carrying base fields
   (`hook_event_name`, `workspace_roots`, `conversation_id`, ...).
2. **Output protocol.** A `before*` hook returns
   `{"permission": "allow" | "deny" | "ask"}` (optionally `user_message` /
   `agent_message`), not Claude's `hookSpecificOutput.permissionDecision`.
   `preToolUse` additionally supports `{"updated_input": {...}}` to rewrite a
   tool's input before it runs. `sessionStart` returns
   `{"additional_context": "...", "env": {...}}`; `stop` returns
   `{"followup_message": "..."}`.

Because the shapes differ, the shared allowlist
([`ai-stuff/_shared/scripts/auto-approve-tools.sh`](../_shared/scripts/auto-approve-tools.sh))
is reused unmodified but wrapped by a thin adapter,
[`auto-approve-cursor.sh`](scripts/auto-approve-cursor.sh), that translates
Cursor's payload into the Claude shape the allowlist understands and its
Claude-shaped verdict back into `{"permission": "allow"}`. The same allowlist
therefore governs Claude Code, Codex, and Cursor.

Converted from the Claude Code setup:

| Claude event | Cursor event | Hook | Notes |
| --- | --- | --- | --- |
| SessionStart (git worktree echo) | `sessionStart` | [`session-start-context.sh`](scripts/session-start-context.sh) | emits `{"additional_context": ...}` (Cursor ignores raw stdout) |
| PreToolUse (`auto-approve-tools.sh pre-tool`) | `beforeShellExecution` | [`auto-approve-cursor.sh`](scripts/auto-approve-cursor.sh) | synthesizes a `Bash` payload, calls the shared allowlist, maps `allow` → `{"permission":"allow"}` |
| PreToolUse (Read auto-approve) | `beforeReadFile` | [`auto-approve-cursor.sh`](scripts/auto-approve-cursor.sh) | synthesizes a `Read` payload against the same allowlist |
| PreToolUse (`rtk hook claude`) | `preToolUse` | `rtk hook cursor` | rtk has a native `cursor` processor; it rewrites via `updated_input` and deliberately answers `"ask"` — rtk rewrites mutating commands too (`git push`, `curl`), so auto-flipping to `"allow"` would bypass prompts. Output is passed through untouched; the allowlist hook and Cursor's own prompt decide |
| PermissionRequest (`auto-approve-tools.sh permission`) | — | folded into `beforeShellExecution`/`beforeReadFile` | Cursor has no separate permission event; the `before*` verdict *is* the permission decision |
| PostToolUse (`Write\|Edit\|MultiEdit`) | `afterFileEdit` | inline `nvim ... checktime` | refresh open buffers; same command as Claude/Codex |
| Stop | `stop` | [`notify-stop.sh`](scripts/notify-stop.sh) | terminal-notifier + click-to-focus iTerm; reads `workspace_roots[0]` |

**Not portable** (no Cursor equivalent, or Claude Code-specific):

- `cc-notifier` (Claude's `SessionStart init`, `Stop notify`,
  `Notification`, `SessionEnd cleanup`) — tied to Claude Code's lifecycle;
  Cursor's `stop` uses `notify-stop.sh` instead. Cursor *does* have
  `sessionEnd`, but there is nothing Claude-side to convert once cc-notifier is
  dropped.
- `session-start.sh` (worktree session auto-naming) — a Claude Code feature.
- `WorktreeCreate` / `WorktreeRemove` — no Cursor event.
- `statusLine`, `fileSuggestion` — Claude Code-only surfaces, not hooks.

## rtk command rewriting

Unlike `beforeShellExecution` (which can only allow/deny/ask), Cursor's
`preToolUse` supports `updated_input`, so `rtk hook cursor` **can** rewrite a
command (e.g. `git status` → `rtk git status`) for token savings — the one
Cursor event that permits rewriting. rtk pairs each rewrite with
`"permission": "ask"` on purpose; we don't override it, because rtk also
rewrites mutating commands (`git push`, `git commit`, `curl`) and a blanket
`allow` would silently bypass Cursor's prompts. Read-only rewritten commands
still auto-approve via the allowlist's `rtk `-prefixed rules. This all depends
on Cursor routing terminal commands through `preToolUse` with
`tool_input.command`; if a given Cursor build only surfaces shell commands via
`beforeShellExecution`, the rewrite silently no-ops and `beforeShellExecution`
still auto-approves the original command (graceful degradation — auto-approve
works, token savings don't).

## Trust / enable

Cursor loads **user-level** hooks (`~/.cursor/hooks.json`) automatically; no
beta flag or toggle is required. **Project-level** hooks
(`<repo>/.cursor/hooks.json`) only run in a **trusted workspace** — trust the
folder when Cursor prompts. Editing `hooks.json` or a hook script is picked up
on the next session; reload the Cursor window if a change is not reflected.

Hook commands run through a shell, so `~`, pipes, `&&`/`||`, `$NVIM`, and
`$(...)` all work (same assumption as the Codex `hooks.json`).
