# Codex configuration setup (tool-specific layer)
#
# Skills come from the universal installer (makefiles/ai.mk → ~/.codex/skills).
# This file handles what is Codex-specific: lifecycle hooks (hooks.json) and
# the hook scripts they call. Codex's hook protocol matches Claude Code's
# (same stdin payload + output schema), so shared scripts live in
# ai-stuff/_shared/scripts/ and are symlinked into each tool's own dir.

CODEX_HOME := ${HOME}/.codex

codex: ai-codex codex-scripts codex-hooks ## Install Codex skills, hook scripts, and hooks

codex-scripts: ## Symlink Codex hook scripts
	$(call mkdir_safe,${CODEX_HOME}/scripts)
	$(call pretty_print, "Installing Codex hook scripts...")
	$(call symlink,ai-stuff/_shared/scripts/auto-approve-tools.sh,${CODEX_HOME}/scripts/auto-approve-tools.sh)
	$(call symlink,ai-stuff/_shared/scripts/focus-iterm.applescript,${CODEX_HOME}/scripts/focus-iterm.applescript)
	$(call symlink,ai-stuff/codex/scripts/notify-stop.sh,${CODEX_HOME}/scripts/notify-stop.sh)
	@chmod +x $(DOTFILES)/ai-stuff/_shared/scripts/*.sh $(DOTFILES)/ai-stuff/codex/scripts/*.sh

codex-hooks: ## Symlink Codex hooks.json (backs up an unmanaged existing file)
	$(call pretty_print, "Installing Codex hooks...")
	@if [ -f ${CODEX_HOME}/hooks.json ] && [ ! -L ${CODEX_HOME}/hooks.json ]; then \
		mv ${CODEX_HOME}/hooks.json ${CODEX_HOME}/hooks.json.bak; \
		echo "backed up unmanaged hooks.json -> hooks.json.bak"; \
	fi
	$(call symlink,ai-stuff/codex/hooks.json,${CODEX_HOME}/hooks.json)
	@if [ -L ${CODEX_HOME}/settings.json ] && [ ! -e ${CODEX_HOME}/settings.json ]; then \
		rm -f ${CODEX_HOME}/settings.json; \
		echo "removed dead ~/.codex/settings.json symlink"; \
	fi

codex-clean: ai-clean-codex ## Remove Codex symlinks
	$(call pretty_print, "Removing Codex symlinks...")
	$(call remove_file,${CODEX_HOME}/hooks.json)
	$(call remove_file,${CODEX_HOME}/scripts/auto-approve-tools.sh)
	$(call remove_file,${CODEX_HOME}/scripts/focus-iterm.applescript)
	$(call remove_file,${CODEX_HOME}/scripts/notify-stop.sh)

.PHONY: codex codex-scripts codex-hooks codex-clean
