---
name: worktree-cleanup
description: "Find and clean up stale git worktrees whose PRs/MRs have already merged. Scans a single repo OR a directory of repos (e.g. ~/codes/work) for worktrees, detects which branches are merged into the default branch — including SQUASH-merged PRs/MRs that ordinary `git branch --merged` misses — then bulk-removes the merged ones and lets you hand-pick which unmerged ones to drop. Use whenever the user wants to clean up / prune / delete / tidy worktrees, mentions stale or leftover worktrees, says their worktree dir is cluttered, or asks which worktrees are safe to remove. Removes the worktree dir, prunes git metadata, and deletes the local branch in one pass."
argument-hint: "[repo-or-dir path]"
allowed-tools:
  - AskUserQuestion
  - Read
  - Bash(~/.config/ai-shared/scripts/worktree-cleanup-scan.sh:*)
  - Bash(~/.config/ai-shared/scripts/worktree-cleanup-remove.sh:*)
  - Bash(git worktree list:*)
  - Bash(git status:*)
  - Bash(git rev-parse:*)
  - Bash(jq:*)
  - Bash(echo:*)
---

# Worktree Cleanup

Find git worktrees whose work has already merged and clean them up — the worktree
directory, the git metadata, and the local branch, in one pass.

## Why this skill exists

Worktrees pile up. Each PR/MR gets its own worktree (e.g. under
`<repo>/.claude/worktrees/<name>`), but once the PR merges nothing deletes it.
The hard part is detection: most PRs/MRs are **squash-merged**, so the branch's
individual commits never appear in `main` verbatim and `git branch --merged`
reports them as *unmerged*. The bundled scan script handles this with layered
checks (ancestor → rebased → remote-branch-gone → forge query), so a squash-merged
branch is correctly classified as safe to delete.

## Input

The user may give a path as `$1`:

- A **single repo** (or any path inside one) → scan that repo's worktrees.
- A **directory of repos** (e.g. `~/codes/work`) → scan each immediate child repo.
- **Nothing** → default to the current directory.

## Workflow

### 1. Scan

Run the scan script with the target path (quote it; default to `.` if none given):

```bash
~/.config/ai-shared/scripts/worktree-cleanup-scan.sh "<path>"
```

It prints a JSON array, one object per non-main worktree:

```json
{ "repo": "...", "repo_name": "...", "worktree": "...", "branch": "...",
  "status": "merged|unmerged|unknown", "reason": "...",
  "dirty": false, "ahead": 0, "warnings": [] }
```

The script auto-fetches with `--prune` so remote-deleted branches are detected.
It never returns the main worktree or any worktree parked on the default branch —
those are safe by construction.

If the array is empty, tell the user there's nothing to clean up and stop.

### 2. Summarize

Show a compact table grouped by status so the user sees the picture at a glance:

```
MERGED (safe to delete)
  repo-a  feat/DEVX-123-login   remote branch deleted (squash-merged)
  repo-a  fix/DEVX-130-typo     ancestor of origin/main

UNMERGED (your call)
  repo-b  spike/new-cache       not merged into main   ⚠ uncommitted changes
  repo-b  feat/DEVX-141-wip     not merged into main   ⚠ 3 unpushed commits

UNKNOWN
  repo-c  (detached HEAD)       detached — no branch to evaluate
```

Always surface `warnings` (uncommitted changes, unpushed commits, "branch gone
from origin with no merged PR") — these are the cases where deleting loses work.

### 3. Bulk-delete merged worktrees

If there are any `merged` worktrees, ask with **AskUserQuestion**:

- Header: `Merged`
- Question: e.g. *"Found N merged worktrees. Delete all of them?"*
- Options: `Delete all N` / `Pick individually` / `Skip merged`

On **Delete all**, remove each merged worktree (see step 5).
On **Pick individually**, fall through to a multiSelect like step 4 but over the
merged list.

### 4. Hand-pick unmerged worktrees

If there are any `unmerged` (or `unknown`) worktrees, ask with **AskUserQuestion**
using `multiSelect: true` so the user can tick the ones to drop:

- Header: `Unmerged`
- Question: *"Which unmerged worktrees should I delete? (these still have work that isn't in the default branch)"*
- One option per worktree. Put the warning in the description so the risk is
  visible, e.g. label `repo-b / spike/new-cache`, description `⚠ uncommitted changes — deleting loses this work`.

Anything the user does NOT select is left untouched. Do not pre-select unmerged
worktrees — unmerged means real work could be lost, so deletion must be explicit.

### 5. Remove

For each worktree the user chose, call the remove script with the repo, worktree
path, and branch (all from the scan JSON):

```bash
~/.config/ai-shared/scripts/worktree-cleanup-remove.sh "<repo>" "<worktree>" "<branch>"
```

It removes the worktree (`--force`), prunes git metadata, and deletes the local
branch (never `main`/`master`). Run it once per selected worktree.

### 6. Report

Summarize what happened: how many removed, which were kept and why, and any that
errored. Keep it tight.

## Rules

- **Never remove the main worktree or the default branch** — the scan script
  already excludes both, so don't reconstruct paths by hand or operate on
  worktrees that aren't in the scan output.
- **Two separate prompts.** Bulk-confirm merged worktrees first, then hand-pick
  unmerged ones. Don't lump them together — the risk profiles are different.
- **Warn before destroying work.** A worktree with uncommitted changes or unpushed
  commits gets its warning shown in the prompt, not hidden. When in doubt, surface
  it and let the user decide.
- **Trust the scan, not the commit graph.** A squash-merged branch looks unmerged
  to `git branch --merged`; the script's layered detection is why this skill exists.
  If `status` is `merged`, treat it as safe.
- **Multi-repo runs are fine.** When scanning `~/codes/work`, group output by repo
  so the user can reason about each project.
- If `gh`/`glab` aren't installed or auth fails, the scan still works from local +
  remote-tracking refs — just note that forge confirmation was unavailable.
