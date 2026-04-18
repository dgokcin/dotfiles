# Claude Code Skills, Agents & Personas Framework

This directory contains a modular framework for extending Claude Code with custom skills, specialized agents, and distinct personas. It follows the [Claude Code Skills](https://code.claude.com/docs/en/skills) open standard while adding persona-driven behavior and orchestration patterns.

## Directory Structure

```
ai-stuff/claude/
├── agents/                 # Agent definitions (execution environments)
│   ├── gitboi.md          # Git workflow expert
│   ├── jiragirl.md        # Jira operations specialist
│   └── mega-dev.md        # Full-stack developer orchestrator
├── config/                # Shared configuration constants
│   ├── git-config.md      # Commit rules, VCS detection, PR templates
│   └── jira-config.md     # Hardcoded Jira values, ADF templates
├── personas/              # Personality definitions
│   ├── gitboi.md          # Sassy git expert personality
│   ├── jira-girl.md       # Bubbly Jira specialist personality
│   └── mega-dev.md        # Pragmatic developer personality
├── scripts/               # Shell scripts for Claude Code integration
│   ├── file-suggestion.sh # Custom file suggestion using rg + fzf
│   └── statusline.sh      # Custom statusline with git, context, vim mode
├── settings.json          # Claude Code settings (references scripts)
└── skills/                # Invocable slash commands
    ├── commit/            # /commit - Create conventional commits
    ├── create-pr/         # /create-pr - Create PR/MR
    ├── create-story/      # /create-story - Create Jira story
    ├── dev-story/         # /dev-story - Fetch story for dev context
    ├── get-story/         # /get-story - Display Jira issue
    ├── gitboi/            # /gitboi - Start GitBoi session
    ├── jiragirl/          # /jiragirl - Start Jira Girl session
    └── mega-dev/          # /mega-dev - Start Mega-Dev session
```

## Architecture

The framework uses a layered architecture where each component has a specific responsibility:

```
┌─────────────────────────────────────────────────────────────┐
│                         Skills                               │
│  User-invocable tasks (/commit, /create-pr, /get-story)     │
└──────────────────────────┬──────────────────────────────────┘
                           │ uses
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                         Agents                               │
│  Execution environments with specific tools + model         │
└──────────────────────────┬──────────────────────────────────┘
                           │ loads
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                        Personas                              │
│  Identity, personality traits, communication style          │
└──────────────────────────┬──────────────────────────────────┘
                           │ references
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                         Config                               │
│  Shared constants, templates, rules                         │
└─────────────────────────────────────────────────────────────┘
```

### Component Relationships

| Component | Purpose | Example |
|-----------|---------|---------|
| **Skill** | User-invocable task with specific instructions | `/commit` creates a conventional commit |
| **Agent** | Execution environment (model + tools + persona) | `gitboi` has Bash, Read, Grep, Glob |
| **Persona** | Personality and communication style | GitBoi is sassy and profane |
| **Config** | Shared constants and templates | Commit format rules, Jira field IDs |

## Skills

Skills are the primary interface for users. Each skill lives in its own directory with a `SKILL.md` file.

### Available Skills

| Skill | Command | Description | Agent |
|-------|---------|-------------|-------|
| commit | `/commit` | Create conventional commit with strict lowercase | gitboi |
| create-pr | `/create-pr` | Create GitHub PR or GitLab MR | gitboi |
| get-story | `/get-story <KEY>` | Fetch and display Jira issue | jiragirl |
| dev-story | `/dev-story <KEY>` | Fetch story with development context | jiragirl |
| create-story | `/create-story <desc>` | Create new Jira story | jiragirl |
| gitboi | `/gitboi` | Start interactive GitBoi session | - |
| jiragirl | `/jiragirl` | Start interactive Jira Girl session | - |
| mega-dev | `/mega-dev` | Start Mega-Dev orchestration session | - |

### Skill Anatomy

Each skill uses YAML frontmatter for configuration:

```yaml
---
name: commit
description: Create conventional commits with GitBoi's sass
disable-model-invocation: true  # Only manual invocation
context: fork                    # Run in isolated subagent
agent: gitboi                    # Use GitBoi agent
allowed-tools: Bash, Read, Grep, Glob
---

# Instructions follow in markdown...
```

### Key Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `name` | Slash command name (e.g., `commit` → `/commit`) |
| `description` | Helps Claude decide when to auto-invoke |
| `disable-model-invocation` | Prevents automatic triggering |
| `context: fork` | Runs in isolated subagent context |
| `agent` | Which agent configuration to use |
| `allowed-tools` | Tools available during execution |

### Dynamic Context Injection

Skills use `!`command`` syntax to inject live data:

```markdown
### Current Branch
!`git branch --show-current`

### Staged Changes
!`git diff --staged --stat`
```

These commands execute before Claude sees the prompt, replacing the placeholder with actual output.

## Agents

Agents define execution environments that combine a model, tools, and persona.

### Available Agents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| `gitboi` | sonnet | Bash, Read, Grep, Glob | Git operations |
| `jiragirl` | sonnet | Read, Glob, Grep + Jira MCP tools | Jira operations |
| `mega-dev` | sonnet | All tools + Skill | Full-stack orchestration |

### Agent Definition Format

```yaml
---
name: gitboi
description: Git workflow expert with sass
tools: Bash, Read, Grep, Glob
model: sonnet
---

You are **GitBoi**...

## Persona
@../personas/gitboi.md

## Configuration
@../config/git-config.md
```

The `@` reference syntax loads external files into the agent's context.

## Personas

Personas define the personality and communication style for each agent.

### GitBoi

- **Identity**: Battle-hardened version control veteran
- **Traits**: Sassy, confident, profane, meticulous about rules
- **Quirk**: Hates GitLab, gets extra aggressive when `.gitlab-ci.yml` detected
- **Output Style**: Sassy in chat, professional in commits/PRs

### Jira Girl

- **Identity**: Enthusiastic Jira specialist
- **Traits**: Bubbly, uses emojis, GenZ slang ("no cap", "slay", "bussin")
- **Quirk**: Obsessed with proper ADF formatting
- **Output Style**: Bubbly in chat, professional in tickets

### Mega-Dev

- **Identity**: Elite full-stack developer
- **Traits**: Direct, pragmatic, uses tech slang naturally
- **Quirk**: Delegates to specialists but owns the overall flow
- **Output Style**: Concise, action-oriented

## Configuration

### Git Configuration (`config/git-config.md`)

**Commit Rules:**
- ALL LOWERCASE - title AND body, no exceptions
- Conventional commit format: `type(scope): subject`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`
- Title under 60 characters, present tense
- **Forbidden**: AI attribution, "Co-Authored-By", emojis

**PR/MR Rules:**
- Normal sentence casing (unlike commits)
- VCS detection: `.gitlab-ci.yml` → GitLab (`glab`), otherwise GitHub (`gh`)
- Mandatory sections: Summary, Changes, Additional Notes

### Jira Configuration (`config/jira-config.md`)

**Hardcoded Values** (to avoid wasting tokens on API lookups):

| Constant | Value |
|----------|-------|
| cloudId | `56552dac-b6cf-4e59-aa06-5e075dca9f8e` |
| defaultProject | `DEVX` |
| atlassianUrl | `https://wahanda.atlassian.net` |
| currentUserAccountId | `712020:e51cbeb5-c2ba-4aea-9f63-01e3c2ade7d4` |

**Custom Fields:**

| Field ID | Name | Format |
|----------|------|--------|
| `customfield_14105` | Reason for change | ADF paragraph (REQUIRED) |
| `customfield_10020` | Acceptance Criteria | ADF taskList (checkboxes) |

**Format Rules:**
- Description field: Markdown
- Custom fields: ADF (Atlassian Document Format)
- Never put acceptance criteria in description

## Usage Patterns

### Quick Commit

```
/commit
```

GitBoi analyzes staged changes and creates a conventional commit automatically.

### Create PR

```
/create-pr
```

GitBoi detects VCS, analyzes the branch diff, and creates a PR/MR.

### Fetch Story for Development

```
/dev-story DEVX-123
```

Jira Girl fetches the story with acceptance criteria, linked issues, and related PRs.

### Start Orchestration Session

```
/mega-dev
```

Starts a Mega-Dev session where you can use all skills and implement full features.

### Workflow Example: Story to PR

```
1. /dev-story DEVX-123     # Get story context
2. [Write code]            # Implement the feature
3. git add .               # Stage changes
4. /commit                 # GitBoi creates commit
5. /create-pr              # GitBoi creates PR
```

## Extending the Framework

### Adding a New Skill

1. Create directory: `skills/my-skill/`
2. Create `SKILL.md` with frontmatter and instructions
3. Reference persona and config files with `@../` syntax
4. Use `!`command`` for dynamic context injection

### Adding a New Agent

1. Create `agents/my-agent.md`
2. Define frontmatter: name, tools, model
3. Reference persona: `@../personas/my-persona.md`
4. Reference config: `@../config/my-config.md`

### Adding a New Persona

1. Create `personas/my-persona.md`
2. Define: Identity, Personality Traits, Core Principles
3. Include interaction examples
4. Specify professional vs conversational output style

## Key Design Decisions

1. **Persona-Driven Behavior**: Agents have distinct personalities that affect chat style but not output quality

2. **Auto-Execution**: Skills like `/commit` execute immediately without asking for confirmation

3. **Hardcoded Configuration**: Jira values are hardcoded to avoid wasteful API calls

4. **Separation of Concerns**: Each agent has specific tools and cannot access others' domains

5. **Reference-Based Organization**: Skills reference personas and configs using `@` paths for reuse

6. **Format Enforcement**: Strict rules for commits (lowercase) vs PRs (sentence case) vs Jira (ADF)

## External Dependencies

This framework integrates with external tools via the hooks system in `settings.json`:

### cc-notifier

**Purpose**: Notification bridge for Claude Code session lifecycle events

**Repository**: [trentmcnitt/cc-notifier](https://github.com/trentmcnitt/cc-notifier)

**Integration**: Configured in `settings.json` hooks for:
- `SessionStart`: Initialize notification context
- `Stop`: Notify on session end (e.g., to Slack/Discord/desktop)
- `Notification`: Alert on permission prompts
- `SessionEnd`: Cleanup notification state

**Example Configuration**:
```json
"SessionStart": [
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "$HOME/.cc-notifier/cc-notifier init"
      }
    ]
  }
]
```

### rtk (Rust Token Killer)

**Purpose**: Token optimization CLI proxy (60-90% savings on dev operations)

**Repository**: [rtk-ai/rtk](https://github.com/rtk-ai/rtk)

**Integration**: Injected into `PreToolUse` hook to transparently rewrite commands

**How It Works**:
- `git status` → `rtk git status` (automatic via hook)
- Filters redundant output, caches results, batches operations
- Zero token overhead — hook rewriting is transparent to user

**Example Configuration**:
```json
"PreToolUse": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "rtk hook claude"
      }
    ]
  }
]
```

**Meta Commands** (always use rtk directly):
- `rtk gain` — Show token savings analytics
- `rtk gain --history` — Show usage history with savings
- `rtk discover` — Analyze Claude Code history for missed opportunities
- `rtk --version` — Verify installation

### Hook Execution Flow

```
User Input
    ↓
SessionStart Hook (cc-notifier init)
    ↓
PreToolUse Hook (rtk rewrite + auto-approve)
    ↓
Tool Execution
    ↓
Permission/Notification Hooks (cc-notifier)
    ↓
Stop/SessionEnd Hooks (cc-notifier cleanup)
```

Dependencies are loaded transparently — no configuration changes needed once installed.

## Related Documentation

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Atlassian Document Format (ADF)](https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/)
