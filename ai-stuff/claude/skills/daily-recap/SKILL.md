---
name: daily-recap
description: Fetch today's activity from Slack, Gmail, and Google Calendar, then update/create your daily note in the vault with a recap and standup draft.
argument-hint: [YYYY-MM-DD] (defaults to today)
model: sonnet
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
  - mcp__claude_ai_Google_Calendar__gcal_list_events
  - mcp__claude_ai_Google_Calendar__gcal_get_event
  - mcp__claude_ai_Google_Calendar__gcal_list_calendars
  - mcp__claude_ai_Google_Calendar__gcal_find_my_free_time
---

# Daily Recap

Fetch today's activity from Slack, Gmail, and Google Calendar. Synthesize into a daily recap and update the vault's daily note.

## Injected context

- Existing daily notes: !`ls "/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault/work/daily notes/" 2>/dev/null`
- Dia context files: !`find "$HOME/Library/Application Support/Dia/User Data/Profile 1/AgentServer/contexts" -name "index.html" -exec ls -la {} \; 2>/dev/null`

## Constants

- **Vault**: `vault`
- **Vault path**: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
- **Daily notes dir**: `work/daily notes/`
- **Timezone**: `Europe/Amsterdam`
- **Slack user ID**: `U07QR93GVRU`

## Instructions

### Step 1: Determine date

Parse from `$ARGUMENTS`:
- If a date like `2026-03-23`: use that
- If empty: use today's date

### Step 2: Gather data (do ALL of these in parallel, including 2h)

#### 2a. Today's calendar events

Fetch today's events using `gcal_list_events`:
- Start: `YYYY-MM-DDT00:00:00`
- End: `YYYY-MM-DDT23:59:59`
- Note event titles, times, attendees

#### 2b. Tomorrow's calendar events

Fetch tomorrow's events (next day's date range) for the standup prep section.

#### 2c. Slack — your thread activity (PRIMARY source)

This is the highest-signal query. It shows your thread replies grouped by conversation topic.

```
slack_search_public_and_private(
  query: "on:YYYY-MM-DD is:thread from:<@U07QR93GVRU>",
  sort: "timestamp",
  limit: 20,
  include_context: true,
  response_format: "detailed"
)
```

This captures: support threads you participated in, code review discussions, technical questions you answered, decisions made in threads. The context messages show what was asked and what you replied — this is the best signal for "what you did".

If there are more than 20 results, paginate using the `cursor` from `pagination_info`.

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

This captures: Jira bot notifications (ticket assignments), PR approval requests, direct questions, alerts. Good for the "needs attention" bucket.

#### 2e. Slack — all messages you sent (SUPPLEMENTARY)

Only use this if the thread query (2c) returned fewer than 5 results — otherwise it's redundant.

```
slack_search_public_and_private(
  query: "on:YYYY-MM-DD from:<@U07QR93GVRU>",
  sort: "timestamp",
  limit: 20,
  include_context: true,
  response_format: "detailed"
)
```

This is a broader sweep. It catches non-threaded channel messages and DMs. Useful for finding work activity that wasn't in a thread. However it's noisy — includes casual DM chat ("hi", "yess", emoji reactions). Apply heavy filtering.

#### 2f. Slack — read specific threads for deeper context

If any search result looks like a meaty work discussion but the context is truncated, use `slack_read_thread` to get the full thread:

```
slack_read_thread(
  channel_id: "<channel_id from search result>",
  message_ts: "<parent thread_ts>",
  response_format: "concise"
)
```

#### 2g. Gmail — today's emails

Use `gmail_search_messages` with multiple targeted searches:

**General email search:**
```
query: "after:YYYY/MM/DD before:YYYY/MM/DD+1"
```

**GitLab-specific search** (MR reviews, pipeline updates, mentions):
```
query: "from:gitlab@twtools.io after:YYYY/MM/DD before:YYYY/MM/DD+1"
```

Look for:
- **MR review requests** — your MR needs review or someone assigned you a review
- **MR approvals/changes** — feedback on your MRs
- **Pipeline notifications** — CI/CD failures or successes on your branch/MR
- **Mentions in discussions** — someone @mentioned you in an MR comment or issue
- **MR merges** — your MR or related MRs that merged

**Jira-specific search** (ticket assignments, workflow changes):
```
query: "from:jira@wahanda.atlassian.net after:YYYY/MM/DD before:YYYY/MM/DD+1"
```

Look for:
- **New tickets assigned to you** — add to `## recap → needs attention` with tag `#new-ticket`
- **Status changes on your tickets** — useful context for what changed
- **Comments on tickets you watch** — decide if actionable, flag with `#review-feedback` if relevant
- **Blocker notifications** — tickets you're blocked on or blocking others

**Read most relevant emails** with `gmail_read_message`. Focus on:
- Action items (needs your review, response, or decision)
- Decisions made (merged MRs, closed tickets)
- Unresolved items (pending reviews, open feedback)
- Skip pure automation spam or FYI-only notifications

#### 2h. Dia browser — daily activity summary

Dia is a browser that generates its own daily activity summaries as HTML artifacts. These often capture work context that Slack/Gmail misses (browsing activity, GitLab MR reviews done in the browser, etc.).

**The Dia context files are injected in the "Injected context" section above.** Pick the one with the most recent date and read it using the Read tool.

**If no output is returned**, skip this step silently.

**Parse the HTML content** — look for these sections (the structure is consistent):
- `.section` with section-label **"Completed"** → `.item h3` (title) + `.item p` (description) + `.tag` spans
- `.section` with section-label **"Meetings"** → `.meeting` rows with time + title
- `.section` with section-label **"Tomorrow"** → `.next-item` rows

**If no context was modified today**, skip this step silently (don't fail).

**Merge Dia data into synthesis (Step 4):**
- Dia "Completed" items → merge into Bucket 1 (what you did today). Avoid duplicating items already captured from Slack/Gmail. Dia tends to have richer descriptions of browser-based work (MR reviews, Datadog investigations, etc.)
- Dia "Tomorrow" items → merge into Bucket 2 (notes for tomorrow)
- Dia tags (e.g. `DEVX-1111`, `Datadog`) → use as context when writing task descriptions, but don't include them literally as Obsidian tags

### Slack filtering guidance

When synthesizing Slack data, apply these filters:

**Keep** (work signal):
- Thread replies in team channels (#team-devx-public, #team-devx-private, etc.)
- Code review discussions (MR links, GitLab/GitHub links)
- Support given (helping others with questions)
- Technical decisions and discussions
- Jira ticket assignments and updates
- PR approval requests

**Skip** (noise):
- Personal DM chatter (physio appointments, office plans, social banter)
- Short acknowledgments ("hi", "yess", "sure", emoji-only messages)
- Bot messages that are purely informational (unless they indicate something actionable)
- Messages in non-work channels unless they contain work discussion

### Step 3: Ensure daily note exists

**Note**: This vault uses the Periodic Notes community plugin, NOT the core Daily Notes plugin. The `obsidian daily:*` commands will NOT work.

Check the injected **"Existing daily notes"** list above:

- **If `YYYY-MM-DD.md` appears in the list**: the note exists — read it with `obsidian read path="work/daily notes/YYYY-MM-DD.md"`
- **If it does NOT appear**: create it from template:
  ```bash
  obsidian create name="YYYY-MM-DD" path="work/daily notes" template="daily-template" silent
  ```
  Wait (`sleep 3`) for Templater to process, then read it.

### Step 4: Synthesize and format output

Read the output template for the exact structure, formatting, examples, and rules:

```
Read file: ~/.claude/templates/daily-recap-output.md
```

The template defines three sections to write. Analyze all gathered data and populate each one following the template exactly.

### Step 5: Write to vault

Use the Obsidian CLI to write to the daily note. Three separate edits (see template for exact content format):

1. **`## today`** — append `- [x]` task lines (replace placeholder `- [ ]` if present, otherwise append after existing tasks)
2. **`## notes for tomorrow`** — insert calendar + standup draft
3. **`## recap`** — append as new section at the very bottom of the file

Read the daily note file directly to find each section, then use `Edit` to insert.

### Step 6: Summary

After writing, give a brief conversational summary:
- One line on the overall vibe of the day
- Call out 1-2 things that need attention tomorrow
- Confirm the file was updated

## Rules

- **Follow the output template** — read `~/.claude/templates/daily-recap-output.md` for all formatting, voice, and structure rules
- **Don't invent data** — only include what you found in Slack/Gmail/Calendar/Dia
- **Skip noise** — ignore bot spam, automated notifications that aren't actionable
- **Group intelligently** — multiple Slack messages on the same topic become one task line
- **Respect existing content** — never overwrite existing tasks or notes, only append/insert
- **NEVER create a daily note with Write tool** — always use `obsidian create name="YYYY-MM-DD" path="work/daily notes" template="daily-template" silent` via Bash. The template has Templater logic that Obsidian must process. Writing the file manually will produce a broken note.
