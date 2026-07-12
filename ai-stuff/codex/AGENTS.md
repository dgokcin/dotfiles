# Global Instructions

## Rules

Before editing any file, read it first. Before modifying a function, grep for
all callers. Research before edit.

Do not read or search files under these directories unless explicitly asked:
node_modules, .git, dist, __pycache__.

## RTK - Rust Token Killer

Token-optimized CLI proxy (60-90% savings on dev operations). A PreToolUse
hook rewrites shell commands transparently (`git status` → `rtk git status`).

Meta commands (always use rtk directly):

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (debugging)
```
