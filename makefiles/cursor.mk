# Cursor configuration setup (tool-specific layer)
#
# Cursor reads skills from the cross-tool standard directory ~/.agents/skills
# (installed by makefiles/ai.mk via make ai-agents). This file only handles
# Cursor-specific agents and cleans up the legacy ~/.cursor layout that
# predates the universal skills setup.

CURSOR_HOME := ${HOME}/.cursor

# Old per-tool skill/persona/config/template symlinks installed by the
# pre-universal cursor.mk — pruned on install.
CURSOR_LEGACY := $(addprefix ${CURSOR_HOME}/skills/,gitboi jiragirl mega-dev commit create-pr create-story dev-story get-story) \
	${CURSOR_HOME}/personas ${CURSOR_HOME}/config ${CURSOR_HOME}/templates

cursor: cursor-agents ai-agents ## Install Cursor agents + universal skills (~/.agents/skills)
	$(call pretty_print, "Pruning legacy ~/.cursor skill symlinks...")
	@rm -rf $(CURSOR_LEGACY)

cursor-agents: ## Symlink Cursor agents (same definitions as Claude Code)
	$(call mkdir_safe,${CURSOR_HOME}/agents)
	$(call pretty_print, "Installing Cursor agents...")
	@for a in $(CLAUDE_AGENTS); do ln -sfn "$(DOTFILES)/ai-stuff/agents/$$a" "${CURSOR_HOME}/agents/$$a"; done

cursor-clean: ## Remove Cursor symlinks (universal skills stay; use ai-clean-agents for those)
	$(call pretty_print, "Removing Cursor symlinks...")
	@for a in $(CLAUDE_AGENTS); do rm -f "${CURSOR_HOME}/agents/$$a"; done
	@rm -rf $(CURSOR_LEGACY)

.PHONY: cursor cursor-agents cursor-clean
