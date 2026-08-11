# RTK - Rust Token Killer (Codex CLI)

**Usage**: Token-optimized CLI proxy for shell commands.

## Rule

Always prefix shell commands with `rtk`.

Examples:

```bash
rtk git status
rtk cargo test
rtk npm run build
rtk pytest -q
```

A PreToolUse hook (`rtk hook claude` in `~/.codex/hooks.json`) also attempts
to rewrite unprefixed commands, but whether Codex applies `updatedInput`
mutations is unverified — the manual prefix rule above is the reliable path
(this matches `rtk init -g --codex`'s own instructions-only approach).

## Meta Commands

```bash
rtk gain            # Token savings analytics
rtk gain --history  # Recent command savings history
rtk proxy <cmd>     # Run raw command without filtering
```

## Verification

```bash
rtk --version
rtk gain
which rtk
```
