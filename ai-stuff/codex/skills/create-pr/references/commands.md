# PR/MR Command Templates

## GitHub PR Create

```bash
gh pr create \
  --head $(git branch --show-current) \
  --base <base-branch> \
  --title "DEVX-123: Description here" \
  --body "## Summary
Brief description of changes

## Changes
- Change 1
- Change 2

## Additional Notes
Any extra context"
```

## GitHub PR Edit (Update Existing)

```bash
gh pr edit <number> \
  --title "DEVX-123: Updated description" \
  --body "## Summary
Updated description of ALL changes in branch

## Changes
- All changes from all commits
- Not just the latest

## Additional Notes
Any extra context"
```

## GitLab MR Create

**IMPORTANT**: Escape all backticks with `\` in the description!

```bash
glab mr create \
  --push \
  --target-branch <base-branch> \
  --title "DEVX-123: Description here" \
  --description "## Summary
Brief description of changes

## Changes
- Added \`someFunction\` to handle X
- Updated \`config.ts\` for Y

## Additional Notes
Any extra context"
```

## GitLab MR Update (Update Existing)

**IMPORTANT**: Escape all backticks with `\` in the description!

```bash
glab mr update <number> \
  --title "DEVX-123: Updated description" \
  --description "## Summary
Updated description of ALL changes in branch

## Changes
- Updated \`someFile.ts\` with new logic
- Refactored \`utils/helper.ts\`

## Additional Notes
Any extra context"
```
