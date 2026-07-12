# Cursor configuration setup (tool-specific layer)
#
# Cursor reads skills from the cross-tool standard directory ~/.agents/skills
# (installed by makefiles/ai.mk via make ai-agents). This file handles the
# Cursor-specific pieces: agents, lifecycle hooks (hooks.json), CLI settings
# (cli-config.json), and the hook scripts they call. It also prunes the legacy
# ~/.cursor layout that predates the universal skills setup.
#
# Cursor's hook protocol differs from Claude Code's (tool-specific events,
# {"permission": ...} output), so the shared allowlist is reused via a small
# adapter (ai-stuff/cursor/scripts/auto-approve-cursor.sh) rather than called
# directly. See ai-stuff/cursor/README.md.

CURSOR_HOME := ${HOME}/.cursor

# Old per-tool skill/persona/config/template symlinks installed by the
# pre-universal cursor.mk — pruned on install.
CURSOR_LEGACY := $(addprefix ${CURSOR_HOME}/skills/,gitboi jiragirl mega-dev commit create-pr create-story dev-story get-story) \
	${CURSOR_HOME}/personas ${CURSOR_HOME}/config ${CURSOR_HOME}/templates

cursor: cursor-agents cursor-scripts cursor-hooks cursor-config ai-agents ## Install Cursor agents, hook scripts, config, hooks + universal skills (~/.agents/skills)
	$(call pretty_print, "Pruning legacy ~/.cursor skill symlinks...")
	@rm -rf $(CURSOR_LEGACY)

cursor-agents: ## Symlink Cursor agents (same definitions as Claude Code)
	$(call mkdir_safe,${CURSOR_HOME}/agents)
	$(call pretty_print, "Installing Cursor agents...")
	@for a in $(CLAUDE_AGENTS); do ln -sfn "$(DOTFILES)/ai-stuff/agents/$$a" "${CURSOR_HOME}/agents/$$a"; done

cursor-scripts: ## Symlink Cursor hook scripts (shared allowlist + Cursor adapters)
	$(call mkdir_safe,${CURSOR_HOME}/scripts)
	$(call pretty_print, "Installing Cursor hook scripts...")
	$(call symlink,ai-stuff/_shared/scripts/auto-approve-tools.sh,${CURSOR_HOME}/scripts/auto-approve-tools.sh)
	$(call symlink,ai-stuff/_shared/scripts/focus-iterm.applescript,${CURSOR_HOME}/scripts/focus-iterm.applescript)
	$(call symlink,ai-stuff/cursor/scripts/auto-approve-cursor.sh,${CURSOR_HOME}/scripts/auto-approve-cursor.sh)
	$(call symlink,ai-stuff/cursor/scripts/session-start-context.sh,${CURSOR_HOME}/scripts/session-start-context.sh)
	$(call symlink,ai-stuff/cursor/scripts/notify-stop.sh,${CURSOR_HOME}/scripts/notify-stop.sh)
	@chmod +x $(DOTFILES)/ai-stuff/_shared/scripts/*.sh $(DOTFILES)/ai-stuff/cursor/scripts/*.sh

cursor-hooks: ## Symlink Cursor hooks.json (backs up an unmanaged existing file)
	$(call pretty_print, "Installing Cursor hooks...")
	@if [ -f ${CURSOR_HOME}/hooks.json ] && [ ! -L ${CURSOR_HOME}/hooks.json ]; then \
		mv ${CURSOR_HOME}/hooks.json ${CURSOR_HOME}/hooks.json.bak; \
		echo "backed up unmanaged hooks.json -> hooks.json.bak"; \
	fi
	$(call symlink,ai-stuff/cursor/hooks.json,${CURSOR_HOME}/hooks.json)

cursor-config: ## Symlink Cursor CLI configuration
	$(call pretty_print, "Installing Cursor CLI configuration...")
	$(call symlink,ai-stuff/cursor/cli-config.json,${CURSOR_HOME}/cli-config.json)

cursor-clean: ## Remove Cursor symlinks (universal skills stay; use ai-clean-agents for those)
	$(call pretty_print, "Removing Cursor symlinks...")
	@for a in $(CLAUDE_AGENTS); do rm -f "${CURSOR_HOME}/agents/$$a"; done
	$(call remove_file,${CURSOR_HOME}/hooks.json)
	$(call remove_file,${CURSOR_HOME}/cli-config.json)
	$(call remove_file,${CURSOR_HOME}/scripts/auto-approve-tools.sh)
	$(call remove_file,${CURSOR_HOME}/scripts/focus-iterm.applescript)
	$(call remove_file,${CURSOR_HOME}/scripts/auto-approve-cursor.sh)
	$(call remove_file,${CURSOR_HOME}/scripts/session-start-context.sh)
	$(call remove_file,${CURSOR_HOME}/scripts/notify-stop.sh)
	@rm -rf $(CURSOR_LEGACY)

.PHONY: cursor cursor-agents cursor-scripts cursor-hooks cursor-config cursor-clean
