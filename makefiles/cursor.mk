# Cursor configuration setup (tool-specific layer)
#
# Cursor reads skills from ~/.agents/skills, which `make skills` fills. This
# file handles the Cursor-specific pieces: agents, lifecycle hooks (hooks.json),
# CLI settings, editor settings, keybindings, and hook scripts. It also prunes
# the legacy ~/.cursor persona/config/template layout.
#
# Cursor's hook protocol differs from Claude Code's (tool-specific events,
# {"permission": ...} output), so the shared allowlist is reused via a small
# adapter (ai-stuff/cursor/scripts/auto-approve-cursor.sh) rather than called
# directly. See ai-stuff/cursor/README.md.

CURSOR_HOME := ${HOME}/.cursor

ifeq ($(UNAME),Darwin)
CURSOR_USER_HOME := ${HOME}/Library/Application Support/Cursor/User
else
CURSOR_USER_HOME := ${XDG_CONFIG_HOME}/Cursor/User
endif

# Old persona/config/template symlinks, pruned on install.
CURSOR_LEGACY := ${CURSOR_HOME}/personas ${CURSOR_HOME}/config ${CURSOR_HOME}/templates \
	$(addprefix ${CURSOR_HOME}/agents/,gitboi.md jiragirl.md mega-dev.md)

cursor: cursor-agents cursor-scripts cursor-hooks cursor-config cursor-user-config ## Install Cursor agents, hooks, settings, and keybindings
	$(call pretty_print, "Pruning legacy ~/.cursor symlinks...")
	@rm -rf $(CURSOR_LEGACY)

cursor-agents: ## Symlink Cursor agents (same definitions as Claude Code)
	$(call mkdir_safe,${CURSOR_HOME}/agents)
	$(call pretty_print, "Installing Cursor agents...")
	@for a in $(CLAUDE_AGENTS); do ln -sfn "$(DOTFILES)/ai-stuff/agents/$$a" "${CURSOR_HOME}/agents/$$a"; done

cursor-scripts: ## Symlink Cursor hook scripts (shared allowlist + Cursor adapters)
	$(call mkdir_safe,${CURSOR_HOME}/scripts)
	$(call pretty_print, "Installing Cursor hook scripts...")
	$(call symlink,ai-stuff/_shared/scripts/auto-approve-tools.sh,${CURSOR_HOME}/scripts/auto-approve-tools.sh)
	$(call symlink,ai-stuff/cursor/scripts/auto-approve-cursor.sh,${CURSOR_HOME}/scripts/auto-approve-cursor.sh)
	$(call symlink,ai-stuff/cursor/scripts/session-start-context.sh,${CURSOR_HOME}/scripts/session-start-context.sh)
	@rm -f ${CURSOR_HOME}/scripts/focus-iterm.applescript ${CURSOR_HOME}/scripts/notify-stop.sh
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

cursor-user-config: ## Symlink Cursor editor settings and keybindings
	$(call pretty_print, "Installing Cursor editor settings and keybindings...")
	@mkdir -p "$(CURSOR_USER_HOME)"
	@for f in settings.json keybindings.json; do \
		target="$(CURSOR_USER_HOME)/$$f"; \
		if [ -f "$$target" ] && [ ! -L "$$target" ]; then \
			mv "$$target" "$$target.bak"; \
			echo "backed up unmanaged $$f -> $$f.bak"; \
		fi; \
		ln -sfn "$(DOTFILES)/ai-stuff/cursor/$$f" "$$target"; \
	done

cursor-clean: ## Remove Cursor symlinks (skills are managed by `make skills`)
	$(call pretty_print, "Removing Cursor symlinks...")
	@for a in $(CLAUDE_AGENTS); do rm -f "${CURSOR_HOME}/agents/$$a"; done
	$(call remove_file,${CURSOR_HOME}/hooks.json)
	$(call remove_file,${CURSOR_HOME}/cli-config.json)
	$(call remove_file,${CURSOR_HOME}/scripts/auto-approve-tools.sh)
	$(call remove_file,${CURSOR_HOME}/scripts/auto-approve-cursor.sh)
	$(call remove_file,${CURSOR_HOME}/scripts/session-start-context.sh)
	@for f in settings.json keybindings.json; do \
		target="$(CURSOR_USER_HOME)/$$f"; \
		[ ! -L "$$target" ] || rm -f "$$target"; \
	done
	@rm -rf $(CURSOR_LEGACY)

.PHONY: cursor cursor-agents cursor-scripts cursor-hooks cursor-config cursor-user-config cursor-clean
