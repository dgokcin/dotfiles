# Daily Recap — Output Template

This template defines the **exact structure** to append to a daily note after gathering data from Slack, Gmail, Calendar, and Dia.

The daily note already exists and has `## today` and `## notes for tomorrow` sections. You are inserting content into those sections and adding a new `## recap` section at the bottom.

---

## Section 1: `## today` — What you did

Insert completed task lines into the existing `## today` section (append after any existing content, never overwrite).

### Format (every line must match exactly)

```
- [x] concise description of what you did ✅ YYYY-MM-DD
```

- `- [x]` — checked Obsidian task
- `✅ YYYY-MM-DD` — the completion date (Obsidian Tasks format so dataview picks it up)
- One line per logical unit of work (group multiple Slack messages on the same topic into one line)

### What qualifies as a "today" task

- Merged MRs, completed reviews
- Support given (helped someone with something)
- Meaningful discussions or decisions
- Anything you actively did or contributed to
- Dia "Completed" items that aren't already covered by Slack/Gmail data

### Voice and style

Write like a human — casual, concise, lowercase-ish. NOT a formal report.

### Examples (copy the tone)

```
- [x] paired a little with mauri in the morning for looking into the drone - gh actions migration ✅ 2026-03-20
- [x] increased the failure threshold for sft namespace, it is better now but still a little fucked? ✅ 2026-03-20
- [x] reviewed rosarios mr about adding rum totally the wrong way :D ✅ 2026-03-20
- [x] helped [[ben minter]] debug the flaky pipeline on devx/k8s-gitops ✅ 2026-03-20
- [x] merged [!31](https://git.treatwell.net/devx/k8s-gitops/-/merge_requests/31) — terragrunt module cleanup ✅ 2026-03-20
```

### Formatting rules

- **Wikilinks for people**: `[[person name]]` (check `work/people/` for existing notes)
- **GitLab MR links**: always a markdown link with the full URL — `[!31](https://git.treatwell.net/<project>/-/merge_requests/31)`. GitLab base URL is `https://git.treatwell.net`. Never write bare `!31`.
- **No emojis** unless the user asked for them
- **No invented data** — only include what was actually found in Slack/Gmail/Calendar/Dia

---

## Section 2: `## notes for tomorrow` — Forward-looking

Insert into the existing `## notes for tomorrow` section.

This section has two parts: tomorrow's calendar and a standup draft.

### Part A: Tomorrow's calendar

Only include if there are notable events. Skip filler (lunch, focus time blocks).

```markdown
### tomorrow's calendar
- 09:30 — Sprint planning
- 11:00 — 1:1 with [[manager name]]
- 14:00 — Tech design review
```

### Part B: Standup draft

3-5 concise first-person bullet points, ready to paste into Slack. Cover what you did today + what's planned next. Wrap in a blockquote so it's visually distinct.

```markdown
### standup
> - reviewed the k8s-gitops terragrunt cleanup mr and merged it
> - helped ben with the flaky pipeline issue
> - bumped failure threshold for sft namespace
> - today: sprint planning, then picking up DEVX-1234
```

---

## Section 3: `## recap` — Needs attention

This is a **new section** appended at the very bottom of the daily note, after `## notes for tomorrow`. It captures things that came *to* you that you haven't acted on yet.

### What goes here

- New tickets assigned to you
- Stale reviews waiting on you
- Review feedback on your MRs
- Alerts or incidents flagged
- Unanswered questions directed at you
- Anything incoming that needs action

### Format

```markdown

## recap

### needs attention
- **DEVX-1234 assigned** — new ticket about flaky drone builds `#new-ticket`
- **MR feedback on !42** — rosario left comments on your terragrunt MR `#review-feedback`
- **Pipeline alert** — staging deploy failed for sft namespace `#alert`
- **Question from [[ben minter]]** — asked about the k8s node pool sizing `#question`
```

### Available tags

| Tag | Use when |
|-----|----------|
| `#new-ticket` | A Jira ticket was newly assigned to you |
| `#review-feedback` | Someone left comments on your MR |
| `#review-stale` | A review request has been waiting on you |
| `#alert` | An alert or incident was flagged |
| `#question` | Someone asked you a question you haven't answered |
| `#blocked` | Something is blocked on you or you're blocked on something |

### Rules for recap

- Each item: `- **Bold title** — brief context \`TAG\``
- Only include genuinely actionable items, not FYI noise
- If nothing needs attention, omit the entire `## recap` section

---

## Full output example

Here's what a complete daily recap insertion looks like across all three sections:

### Inserted into `## today`:

```
- [x] paired with [[mauri]] on the drone to gh actions migration ✅ 2026-03-20
- [x] increased failure threshold for sft namespace ✅ 2026-03-20
- [x] reviewed rosarios mr [!78](https://git.treatwell.net/devx/infra/-/merge_requests/78) about adding rum ✅ 2026-03-20
- [x] helped [[ben minter]] debug the flaky staging pipeline ✅ 2026-03-20
```

### Inserted into `## notes for tomorrow`:

```
### tomorrow's calendar
- 09:30 — Sprint planning
- 14:00 — Tech design review with platform team

### standup
> - reviewed and merged the rum instrumentation mr
> - helped ben with staging pipeline flakiness
> - bumped sft failure threshold, seems better now
> - today: sprint planning, then continuing drone migration
```

### Appended at the bottom as new section:

```

## recap

### needs attention
- **DEVX-1234 assigned** — flaky drone builds investigation `#new-ticket`
- **MR feedback on [!42](https://git.treatwell.net/devx/k8s-gitops/-/merge_requests/42)** — 2 unresolved comments from rosario `#review-feedback`
- **Question from [[ana]]** — asked about the new namespace quota policy `#question`
```
