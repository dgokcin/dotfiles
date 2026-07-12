# Codex configuration setup (tool-specific layer)
#
# Skills: Codex reads only the cross-tool standard dir ~/.agents/skills —
# installed by ai.mk's "agents" pseudo-tool. Codex does NOT read
# ~/.codex/skills (that dir is pruned on install). This file handles what is
# Codex-specific: lifecycle hooks (hooks.json), the hook scripts they call,
# the global AGENTS.md, and the managed block of config.toml. Codex's hook
# system (~v0.114+) adopted Claude Code's protocol (same stdin payload +
# output schema), so shared scripts live in ai-stuff/_shared/scripts/ and are
# symlinked into each tool's own dir.

CODEX_HOME := ${HOME}/.codex

codex: ai-agents codex-scripts codex-hooks codex-agents-md codex-config ## Install Codex skills, hooks, AGENTS.md, and managed config
# Codex reads ~/.agents/skills — kill our old symlinks in ~/.codex/skills but
# keep .system, the dir where Codex caches its own built-in skills.
	$(call pretty_print, "Pruning dead skill symlinks in ~/.codex/skills")
	@[ -d ${CODEX_HOME}/skills ] && find ${CODEX_HOME}/skills -maxdepth 1 -type l -delete || true

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

codex-agents-md: ## Symlink global AGENTS.md
	$(call pretty_print, "Installing Codex AGENTS.md...")
	$(call symlink,ai-stuff/codex/AGENTS.md,${CODEX_HOME}/AGENTS.md)

codex-config: ## Sync dotfiles-managed block into ~/.codex/config.toml (machine state untouched)
	$(call pretty_print, "Syncing managed block of ~/.codex/config.toml...")
	@bash $(DOTFILES)/ai-stuff/codex/scripts/sync-config.sh

codex-clean: ## Remove Codex symlinks (skills live in ~/.agents/skills — use ai-clean)
	$(call pretty_print, "Removing Codex symlinks...")
	$(call remove_file,${CODEX_HOME}/hooks.json)
	$(call remove_file,${CODEX_HOME}/AGENTS.md)
	$(call remove_file,${CODEX_HOME}/scripts/auto-approve-tools.sh)
	$(call remove_file,${CODEX_HOME}/scripts/focus-iterm.applescript)
	$(call remove_file,${CODEX_HOME}/scripts/notify-stop.sh)

.PHONY: codex codex-scripts codex-hooks codex-agents-md codex-config codex-clean
