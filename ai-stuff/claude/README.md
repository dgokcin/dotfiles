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
│   ├── statusline.sh      # Main-session statusline: git, context, per-provider quota/cost
│   ├── statusline-test.sh # Fixture tests for statusline.sh (repo-only, not installed)
│   ├── fixtures/          # stdin fixtures used by statusline-test.sh
│   ├── subagent-statusline.sh # Subagent rows with each task's resolved model
│   ├── session-start.sh   # Auto-name worktree sessions
│   ├── notify.sh          # Notification-event alert (claude-only event)
│   └── worktree-*.sh      # EnterWorktree/ExitWorktree hook scripts (claude hook protocol)
│   (auto-approve-tools.sh, focus-iterm.applescript, pr-status.sh, and the
│    worktree-cleanup skill helpers moved to ai-stuff/_shared/scripts/ —
│    shared across tools)
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

## Statusline

Claude Code is the interface; the model behind a session may be Anthropic's own
API or a third-party backend routed through the clodex proxy — so
`statusline.sh` resolves the real upstream provider per session and renders only
the quota surface that provider can actually support.

| Backend | Line 2 | Cost source |
|---|---|---|
| Anthropic | 5h / weekly bars from stdin `rate_limits`, plus a bar per model-scoped weekly window (Fable, ...) | Claude Code's `total_cost_usd` |
| ChatGPT (`openai-oauth`) | live bars polled from the ChatGPT usage endpoint | published OpenAI API rates (`~/.clodex/pricing-cache.json`) |
| OpenCode Go (`opencode-go`) | real 5h / weekly / monthly quota from the provider's `/usage` endpoint | per-provider costs in `~/.clodex/providers.json` |
| any other clodex provider | `· no quota data` | provider costs if known, otherwise nothing |

OpenCode Go serves real quota at `/usage` on its inference base (for Go:
`https://opencode.ai/zen/go/v1/usage`), authenticated by the same API key used
for inference — the 5-hour, weekly and monthly windows its web UI shows. The URL
is derived from `api.url` in the provider registry, so a rehosted base needs no
edit, and the key is read from opencode's own `auth.json` (clodex keeps its copy
in the keychain). Note this is *not* the console API at `console.opencode.ai/api`
(`usage`, `budgets`, `billing/balance/summary`), which is a separate
Google/GitHub browser-session system that rejects the API key.

When no reading is available — no key, offline, another provider — the line
falls back to pricing the window's usage from clodex's own per-request logs and
comparing it to the plan fee (`CLODEX_PLAN_USD`, `CLODEX_SPEND_WINDOW_DAYS`,
default 30 to match a monthly billing period), and says `no quota reading` so the
estimate is never mistaken for real quota. Since the plan is flat-rate, that
figure answers "is the subscription worth it" rather than "how much do I owe":
past 100% it has paid for itself, so the bar fills toward green and the value is
not clamped. It also carries the request count and the model responsible,
labelled with its share of window spend, since an unqualified model id sitting
under the session's own model reads as the one in use.

Provider resolution prefers ground truth (an id that names its provider, or the
clodex session log) over the alias table, which cannot answer for models that
have no alias or whose alias is ambiguous across providers. `STATUSLINE_DEBUG=1`
prints the resolution chain to stderr.

The render path does no network I/O: quota, spend and session cost all come from
`~/.cache/claude-statusline/`, refreshed by detached `statusline.sh --refresh`
runs. A failed refresh keeps the last good reading and stamps its age.

Run `./scripts/statusline-test.sh` after changing it — it drives the real script
against `scripts/fixtures/*.json` with a scratch clodex/codex home, so it touches
neither your accounts nor the network.

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
