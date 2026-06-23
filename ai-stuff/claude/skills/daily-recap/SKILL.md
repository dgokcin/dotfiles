---
name: daily-recap
description: "Fetch today's activity from Slack, Gmail, and Google Calendar, then update/create your daily note in the vault with a recap and standup draft."
disable-model-invocation: true
argument-hint: "[YYYY-MM-DD] (defaults to today)"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(obsidian read:*)
  - Bash(obsidian append:*)
  - Bash(obsidian templates:*)
  - Bash(obsidian create:*)
  - Bash(obsidian file:*)
  - Bash(obsidian files:*)
  - Bash(obsidian folder:*)
  - Bash(obsidian folders:*)
  - Bash(obsidian search:*)
  - Bash(obsidian outline:*)
  - Bash(obsidian tags:*)
  - Bash(obsidian properties:*)
  - Bash(obsidian help:*)
  - Bash(sleep:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(date:*)
  - Bash(find:*)
- Bash(python3 ~/.claude/skills/daily-recap/scripts/summarize-claude-sessions.py:*)
- Bash(claude -p:*)
  # Slack (read-only)
  - mcp__claude_ai_Slack__slack_search_public_and_private
  - mcp__claude_ai_Slack__slack_search_public
  - mcp__claude_ai_Slack__slack_read_channel
  - mcp__claude_ai_Slack__slack_read_thread
  - mcp__claude_ai_Slack__slack_read_user_profile
  - mcp__claude_ai_Slack__slack_search_channels
  - mcp__claude_ai_Slack__slack_search_users
  # Gmail (read-only)
  - mcp__claude_ai_Gmail__gmail_search_messages
  - mcp__claude_ai_Gmail__gmail_read_message
  - mcp__claude_ai_Gmail__gmail_read_thread
  - mcp__claude_ai_Gmail__gmail_get_profile
  - mcp__claude_ai_Gmail__gmail_list_labels
  # Google Calendar (read-only)
  - mcp__claude_ai_Google_Calendar__list_events
  - mcp__claude_ai_Google_Calendar__get_event
  - mcp__claude_ai_Google_Calendar__list_calendars
  - mcp__claude_ai_Google_Calendar__find_my_free_time
  # Google Drive (read-only — meeting notes)
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__claude_ai_Google_Drive__search_files
---

# Daily Recap

Fetch today's Slack/Gmail/Calendar activity. Synthesize → daily recap → update vault.

## Injected context

- Today's date: !`date +%Y-%m-%d`
- Tomorrow's date: (today + 1 day — derive from the today date above)
- Existing daily notes: !`ls "/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault/work/daily notes/" 2>/dev/null`
- Output template: @~/.claude/templates/daily-recap-output.md

## Constants

- **Vault**: `vault`
- **Vault path**: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
- **Daily notes dir**: `work/daily notes/`
- **Timezone**: `Europe/Amsterdam`
- **Slack user ID**: `U07QR93GVRU`

## Rules for tool usage

- **NEVER use `cd`** — obsidian CLI works from any cwd. Call `obsidian ...` directly. `cd` → permission prompts + wasted tokens.
- **NEVER escape spaces in obsidian args** — CLI handles vault path internally; pass `path="work/daily notes"` as-is.
- Use injected context above instead of re-running `ls`, `date`, or `cat` on template.

## Instructions

### Step 1: Determine date

Parse from `$ARGUMENTS`:

- Date like `2026-03-23`: use that
- Empty: use today from injected context

### Step 2: Gather data (all in parallel, including 2h)

#### 2a. Today's calendar events

Fetch today's events via `gcal_list_events`:

- Start: `YYYY-MM-DDT00:00:00`
- End: `YYYY-MM-DDT23:59:59`
- Note titles, times, attendees

#### 2b. Tomorrow's calendar events

Fetch tomorrow's events for standup prep.

#### 2c. Slack — your thread activity (PRIMARY source)

Highest-signal query. Shows thread replies grouped by topic.

```
slack_search_public_and_private(
  query: "on:YYYY-MM-DD is:thread from:<@U07QR93GVRU>",
  sort: "timestamp",
  limit: 20,
  include_context: true,
  response_format: "detailed"
)
```

Captures: support threads, code review discussions, technical questions answered, decisions. Context messages show what was asked + what you replied — best signal for "what you did".

>20 results → paginate via `cursor` from `pagination_info`.

#### 2d. Slack — messages sent to you (incoming work)

```
slack_search_public_and_private(
  query: "on:YYYY-MM-DD to:<@U07QR93GVRU>",
  sort: "timestamp",
  limit: 20,
  include_context: true,
  response_format: "detailed"
)
```

Captures: Jira bot notifications, PR approval requests, direct questions, alerts. → "needs attention" bucket.

#### 2e. Slack — all messages you sent (SUPPLEMENTARY)

Only use if 2c returned <5 results — otherwise redundant.

```
slack_search_public_and_private(
  query: "on:YYYY-MM-DD from:<@U07QR93GVRU>",
  sort: "timestamp",
  limit: 20,
  include_context: true,
  response_format: "detailed"
)
```

Broader sweep. Catches non-threaded channel msgs + DMs. Noisy — includes casual chat. Apply heavy filtering.

#### 2f. Slack — read specific threads for deeper context

If search result looks like meaty work discussion but context truncated, use `slack_read_thread`:

```
slack_read_thread(
  channel_id: "<channel_id from search result>",
  message_ts: "<parent thread_ts>",
  response_format: "concise"
)
```

#### 2g. Gmail — today's emails

Use `gmail_search_messages` with multiple targeted searches:

**General:**

```
query: "after:YYYY/MM/DD before:YYYY/MM/DD+1"
```

**GitLab-specific** (MR reviews, pipeline updates, mentions):

```
query: "from:gitlab@twtools.io after:YYYY/MM/DD before:YYYY/MM/DD+1"
```

Look for:

- **MR review requests** — your MR needs review or you're assigned reviewer
- **MR approvals/changes** — feedback on your MRs
- **Pipeline notifications** — CI/CD failures or successes on your branch/MR
- **Mentions** — @mentioned in MR comment or issue
- **MR merges** — your MR or related MRs merged

**Jira-specific:**

```
query: "from:jira@wahanda.atlassian.net after:YYYY/MM/DD before:YYYY/MM/DD+1"
```

Look for:

- **New tickets assigned** → `## recap → needs attention` tag `#new-ticket`
- **Status changes on your tickets** — context for what changed
- **Comments on watched tickets** — flag `#review-feedback` if actionable
- **Blocker notifications** — tickets blocking you or blocked by you

Read most relevant emails via `gmail_read_message`. Focus on: action items, decisions made, unresolved items. Skip automation spam + FYI-only.

#### 2h. Dia browser — daily activity summary

Dia generates daily activity summaries as HTML. Captures work context Slack/Gmail misses (browsing, GitLab MR reviews in browser, etc.).

**Dia context files injected above.** Pick most recent date → read via Read tool.

**No output** → skip silently.

**Parse HTML** — look for:

- `.section` with label **"Completed"** → `.item h3` + `.item p` + `.tag` spans
- `.section` with label **"Meetings"** → `.meeting` rows (time + title)
- `.section` with label **"Tomorrow"** → `.next-item` rows

**No context modified today** → skip silently.

**Merge into Step 4:**

- Dia "Completed" → Bucket 1 (today). No dups from Slack/Gmail. Dia has richer descriptions of browser work.
- Dia "Tomorrow" → Bucket 2 (notes for tomorrow)
- Dia tags (e.g. `DEVX-1111`, `Datadog`) → context only, not literal Obsidian tags

#### 2i. Google Drive — Gemini meeting notes

For each meeting from step 2a that has an `attachments` entry with a Google Docs URL (Gemini auto-notes):

1. Extract the `fileId` from the attachment URL: `https://docs.google.com/document/d/{fileId}/edit?...`
2. Fetch in parallel: `mcp__claude_ai_Google_Drive__read_file_content(fileId: "{fileId}")`
3. From the response parse: **Summary**, **Decisions** (Aligned + Needs Further Discussion), **Next steps**
4. Filter next steps to only items assigned to you (your name appears in the bracket)

**Skip silently if:**

- Meeting has no attachments / no Docs URL (e.g. standup without notes, focus time, lunch)
- `read_file_content` returns "not found" or permission error

**Do NOT fetch the transcript** — the Summary + Decisions + Next steps sections are sufficient.

#### 2j. Claude Code sessions (Haiku subagent)

Run the companion script to extract session data, then pipe to a Haiku subagent for summarization. This captures engineering work that never surfaces in Slack or Gmail (local coding, debugging, config changes, dotfiles work).

```bash
python3 ~/.claude/skills/daily-recap/scripts/summarize-claude-sessions.py YYYY-MM-DD | \
  claude -p --model claude-haiku-4-5-20251001 \
  "Summarize these Claude Code sessions into 2-5 bullet points of what engineering work was done. Focus on: features built, tickets worked, bugs debugged, code changed. Skip meta/tooling sessions (e.g. only ran 'exit', only did shell commands with no edits). Max one line per bullet. Output plain bullets only."
```

**No sessions found** → skip silently (script exits 0 with a note).

**Merge into step 4:**
- Session bullets → `## today` (engineering work items, mark as `- [x]`)
- Dedup against Slack/GitLab items already found (same ticket or task → merge, don't repeat)

### Slack filtering guidance

**Keep** (work signal):

- Thread replies in team channels (#team-devx-public, #team-devx-private, etc.)
- Code review discussions (MR links, GitLab/GitHub links)
- Support given
- Technical decisions
- Jira ticket assignments/updates
- PR approval requests

**Skip** (noise):

- Personal DM chatter (physio, office plans, social)
- Short acks ("hi", "yess", "sure", emoji-only)
- Pure-info bot messages (unless actionable)
- Non-work channels unless work discussion inside

### Step 3: Ensure daily note exists

**Note**: Vault uses Periodic Notes community plugin, NOT core Daily Notes. `obsidian daily:*` commands will NOT work.

Check injected **"Existing daily notes"** list:

- **`YYYY-MM-DD.md` in list**: note exists → read with `obsidian read path="work/daily notes/YYYY-MM-DD.md"`
- **Not in list**: create from template:

  ```bash
  obsidian create name="YYYY-MM-DD" path="work/daily notes" template="daily-template" silent
  ```

  Wait (`sleep 3`) for Templater to process, then read.

### Step 4: Synthesize and format output

Output template injected above under "Output template". Use for exact structure, formatting, examples, rules. Do NOT re-read it.

Template defines three sections. Analyze all data → populate each following template exactly.

### Step 5: Write to vault

Three separate edits (see template for exact content format):

1. **`## today`** — append `- [x]` task lines (replace placeholder `- [ ]` if present, else append after existing tasks). Include session bullets from step 2j as engineering work items; dedup against Slack/GitLab items already found.
2. **`## notes for tomorrow`** — insert calendar + standup draft
3. **`## recap`** — append as new section at very bottom. Always includes `### needs attention`. If meeting notes were fetched in step 2i, also include `### meetings`:

```markdown
### meetings

#### [HH:MM] Meeting Title
**Summary:** one-sentence
**Decisions:** bullet list (aligned items first, then open items if any)
**My next steps:** bullet list — only items assigned to you; omit if none
```

Omit the `### meetings` subsection entirely if no meeting notes were accessible.

Read daily note to find each section, then use `Edit` to insert.

### Step 6: Summary

Brief conversational summary after writing:

- One line on overall day vibe
- 1-2 things needing attention tomorrow
- Confirm file updated

## Rules

- **Follow output template** — `~/.claude/templates/daily-recap-output.md` has all formatting/voice/structure rules
- **Don't invent data** — only include what found in Slack/Gmail/Calendar/Dia
- **Skip noise** — ignore bot spam, non-actionable automated notifications
- **Group intelligently** — multiple Slack msgs on same topic → one task line
- **Respect existing content** — never overwrite existing tasks or notes, only append/insert
- **NEVER create daily note with Write tool** — always use `obsidian create name="YYYY-MM-DD" path="work/daily notes" template="daily-template" silent` via Bash. Template has Templater logic Obsidian must process. Manual write → broken note.

