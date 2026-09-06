# Skill invocation: user-invoked vs model-invoked

Every `SKILL.md` under [`skills/`](skills/) is a skill. One axis splits them:
**who can reach it**. Each harness gates that in its own way, so a skill
carries the same answer in two places and they must never disagree:

| | Claude Code (`SKILL.md` frontmatter) | Codex (`agents/openai.yaml`) |
| --- | --- | --- |
| **User-invoked** | `disable-model-invocation: true` | `policy.allow_implicit_invocation: false` |
| **Model-invoked** (default) | key omitted | `policy` block omitted |

`make ai-check` (run automatically by `make ai`, `make claude`, `make codex`,
`make cursor`) fails the install when the two drift.

## Which one is it?

**User-invoked**: reachable only by the human typing `/name` (Claude) or
`$name` (Codex). Use for persona sessions and orchestrators, and for things
that must never fire by accident (`daily-recap`, `address-review`).
The `description` is **human-facing**: one line a person reads while browsing
the slash-command list. Strip trigger phrasing ("Use when the user says…").

**Model-invoked**: reachable by the model *or* the human. The default. The
test: *could the model usefully reach for this on its own?* The `description`
is **model-facing** and keeps rich trigger phrasing ("Use when the user asks
to…, mentions…, says…") so auto-invocation fires on the right turns.

## Dependencies between skills

An operative step that needs another skill says exactly:

```
Call the Skill tool with "create-pr"
```

Not `/create-pr`, not `invoke the create-pr skill`, not a relative link into
the other skill's folder. Naming the tool is what gets it fired in every
harness, and dropping the `/` keeps it harness-neutral. One skill per call: a
step that needs two is two calls, say so.

**Invariant**: a user-invoked skill can never be reached this way. No other
skill can call it, including by naming it to the Skill tool. So anything an
orchestrator calls must be model-invoked; that is why `get-story` and
`create-story` are model-invoked even though they run under a persona: a
user-invoked session skill that wanted to call them could, the reverse never.
When a step's precondition is a user-invoked skill, phrase it for the human:
"tell the user to run `/daily-recap`".

Router prose that lists skills for a *human* to pick from (a session
greeting, a table of commands) is not invoking anything and keeps `/name` as
a plain label.

## `agents/openai.yaml`

Sits beside every `SKILL.md`. Codex reads it for the `$` skill picker; every
other harness ignores it.

```yaml
interface:
  display_name: "Create PR"                                # picker title
  short_description: "Open a GitHub PR or GitLab MR"       # picker subtitle, <= 64 chars
policy:                                                    # user-invoked skills only
  allow_implicit_invocation: false
```

`make ai-skill-meta` scaffolds a starter file for any skill missing one
(display name from the directory name, subtitle from the first sentence of
`description`, policy from `disable-model-invocation`). Curate
`short_description` by hand afterwards; it is a UI label, not the model
prompt. The lint checks presence, length, and the policy pairing.

## Frontmatter hygiene (also linted)

- `allowed-tools:`, never the legacy `tools:` key.
- Omit `disable-model-invocation: false`; absent is the default.
- No `SKILL.original.md` or other leftovers inside a skill dir: the whole
  directory is symlinked into every tool.
- Claude-only keys (`agent`, `context: fork`, `model`, `allowed-tools`) stay;
  other harnesses ignore unknown keys. See the portability rules in
  [README.md](README.md).
