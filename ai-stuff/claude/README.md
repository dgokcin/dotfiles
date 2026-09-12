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
| OpenCode Go (`opencode-go`) | API-equivalent value over the billing period vs. what the plan costs, with request count and the model doing the spending | per-provider costs in `~/.clodex/providers.json` |
| any other clodex provider | `· no quota data` | provider costs if known, otherwise nothing |

OpenCode Go publishes no usage/quota API that a statusline can poll — its limits
surface only inside 429 bodies, and the console API at `console.opencode.ai/api`
(`usage`, `budgets`, `billing/balance/summary`) authenticates with a Google or
GitHub browser session, not the inference API key (both `Authorization: Bearer`
and `x-api-key` return `401 {"_tag":"Unauthorized"}`).

The plan is flat-rate, so per-token cost is not what you are billed and a "spend
budget" would be meaningless. Instead the line prices the window's usage at the
provider's published rates and compares it to the plan fee — the question it
answers is whether the subscription is worth keeping. Past 100% it has paid for
itself, so the bar fills toward green rather than red, and the figure is not
clamped. Configure with `CLODEX_PLAN_USD` and `CLODEX_SPEND_WINDOW_DAYS`
(default 30, matching a monthly billing period) in `settings.json`; omit the plan
cost and it degrades to the bare figure. A few cents of a cheap model says
nothing on its own, so the line also carries the request count and the model
responsible — labelled with its share of window spend, since an unqualified
model id sitting under the session's own model reads as the one in use.

Anthropic meters some models on their own weekly window on top of the all-models
one — being at 100% on Fable while `weekly` reads 67% is the case worth seeing.
Claude Code 2.1.269 does not put those on stdin (its payload builder emits only
`five_hour`, `seven_day` and `spend_limit`), so the bars come from the limits
array it caches in `~/.claude.json` under `cachedUsageUtilization`, stamped with
its age because Claude Code refreshes it on its own schedule. Newer builds
document a `rate_limits.model_scoped` field; that is preferred when present and
renders without an age stamp.

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
