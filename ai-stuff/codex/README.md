# Codex Skills

This directory contains Codex-native equivalents of the custom setup under `ai-stuff/claude`.

## What maps directly

- `skills/`: repo-local Codex skills with simplified frontmatter
- `skills/_shared/`: shared personas, configs, templates, and helper scripts referenced by the skills
- `makefiles/codex.mk`: installer target that symlinks full skill directories into `~/.codex/skills`

## What does not map 1:1

- Claude agents/personas/settings hooks do not have a direct Codex manifest equivalent here
- Claude `@file` includes and command injection were converted into plain references and run-time instructions inside each skill
- Claude `settings.json` hooks, permissions, status line, and plugins were not mirrored because Codex uses a different runtime model

## Install

```bash
make codex
```

That creates:

- `~/.codex/skills/_shared`
- `~/.codex/skills/<skill-name>` for each migrated skill
