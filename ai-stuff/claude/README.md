# Claude Code Layer

Claude Code-specific configuration: hook scripts, `settings.json`, and the
install wiring for agents/personas/configs/templates. **Skills do not live
here** — they are universal and come from [`ai-stuff/skills/`](../skills/)
via `make ai-claude`. See [ai-stuff/README.md](../README.md) for the
cross-tool architecture.

## Directory Structure

```
ai-stuff/claude/
├── scripts/               # Claude-only hook + integration scripts (→ ~/.claude/scripts)
│   ├── file-suggestion.sh # Custom file suggestion using rg + fzf
│   ├── statusline.sh      # Statusline with git, context, vim mode
│   ├── session-start.sh   # Auto-name worktree sessions
│   ├── notify.sh          # Notification-event alert (claude-only event)
│   ├── pr-status.sh       # Used by the create-pr skill
│   └── worktree-*.sh      # Worktree hooks + worktree-cleanup skill helpers
│   (auto-approve-tools.sh + focus-iterm.applescript moved to
│    ai-stuff/_shared/scripts/ — shared with Codex hooks)
├── settings.json          # Hooks, permissions, statusline, plugins (→ ~/.claude/settings.json)
└── README.md
```

`make claude` also installs (sources live elsewhere):

| Target          | Source                 | Destination           | Consumed by                            |
| --------------- | ---------------------- | --------------------- | -------------------------------------- |
| `claude-agents` | `ai-stuff/agents/*.md` | `~/.claude/agents`    | Claude Code subagents                  |
| `ai-shared`     | `ai-stuff/_shared`     | `~/.config/ai-shared` | agents' `@~/.config/ai-shared/...` includes (tool-agnostic) |
| `ai-claude`     | `ai-stuff/skills/*`    | `~/.claude/skills`    | skills (universal, see ai.mk)          |

## Architecture

```
Skills (universal, ai-stuff/skills/)     ← same files for every AI tool
    │ uses (agent: frontmatter, Claude only)
    ▼
Agents (ai-stuff/agents/)                ← execution env: model + tools + persona
    │ loads via @~/.config/ai-shared/... includes (tool-agnostic path)
    ▼
Personas + Config (ai-stuff/_shared/)    ← identity, rules, shared constants
```

## Claude-specific skill features

Universal skills carry Claude-only frontmatter that other tools ignore:

| Field                      | Purpose                                    |
| -------------------------- | ------------------------------------------ |
| `disable-model-invocation` | Prevents automatic triggering              |
| `context: fork`            | Runs in isolated subagent context          |
| `agent`                    | Which agent definition to execute under    |
| `allowed-tools`            | Tool allowlist during execution            |

Dynamic context injection — Claude Code executes `!`command`` lines eagerly
and injects output before the model sees the prompt (other tools treat the
line as an instruction to run the command):

```markdown
### Staged Changes
!`git diff --staged --stat`
```

## Agents

| Agent               | Purpose                                    |
| ------------------- | ------------------------------------------ |
| `gitboi`            | Git operations with sass                   |
| `jiragirl`          | Jira operations (MCP Atlassian tools)      |
| `mega-dev`          | Story-to-PR orchestration                  |
| `gitops-geezer`     | ArgoCD / GitOps                            |
| `steve-square-meter`| Funda house-search analysis                |

Agent bodies reference personas/configs with `@~/.config/ai-shared/...` eager
includes — a tool-agnostic path (`make ai-shared`), so Cursor (which gets the
same agent files at `~/.cursor/agents`) resolves them identically. The only
`.claude` paths left in an agent file are Claude's own runtime features
(e.g. steve-square-meter's Persistent Agent Memory directory).

## External Dependencies (hooks in settings.json)

### cc-notifier

Notification bridge for session lifecycle events —
[trentmcnitt/cc-notifier](https://github.com/trentmcnitt/cc-notifier).
Wired into `SessionStart` (init), `Stop` / `Notification` (notify),
`SessionEnd` (cleanup).

### rtk (Rust Token Killer)

Token-optimizing CLI proxy (60-90% savings) — injected via `PreToolUse` hook
(`rtk hook claude`) to transparently rewrite commands (`git status` →
`rtk git status`). Meta commands: `rtk gain`, `rtk gain --history`,
`rtk discover`, `rtk --version`.

### Hook Execution Flow

```
User Input
    ↓
SessionStart Hook (cc-notifier init, session-start.sh)
    ↓
PreToolUse Hook (auto-approve-tools.sh, rtk rewrite)
    ↓
Tool Execution
    ↓
Permission/Notification Hooks (auto-approve-tools.sh, cc-notifier)
    ↓
Stop/SessionEnd Hooks (cc-notifier)
```

## Related Documentation

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Agent Skills standard](https://agentskills.io)
