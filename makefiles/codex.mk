# Codex configuration setup (tool-specific layer)
#
# Codex has no tool-specific artifacts here — its skills come from the
# universal installer (makefiles/ai.mk), which symlinks ai-stuff/skills/*
# into ~/.codex/skills. These aliases keep `make codex` working.

codex: ai-codex ## Install Codex skills (alias for ai-codex)

codex-clean: ai-clean-codex ## Remove Codex skills (alias for ai-clean-codex)

.PHONY: codex codex-clean
