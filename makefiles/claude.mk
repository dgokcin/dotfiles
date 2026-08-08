# Claude Code configuration setup (tool-specific layer)
#
# Universal skills are installed by makefiles/ai.mk (make ai-claude); shared
# personas/configs/templates live at ~/.config/ai-shared (make ai-shared) —
# agents reference them there, so nothing tool-specific holds content.
# This file only handles what is Claude Code-specific: agents, hook scripts,
# and settings.json.

CLAUDE_HOME := ${HOME}/.claude

CLAUDE_AGENTS := $(notdir $(wildcard $(DOTFILES)/ai-stuff/agents/*.md))

CLAUDE_OUTPUT_STYLES := $(notdir $(wildcard $(DOTFILES)/ai-stuff/output-styles/*.md))

# Pre-ai-shared layout installed by the old claude.mk — pruned on install.
CLAUDE_LEGACY := ${CLAUDE_HOME}/personas ${CLAUDE_HOME}/config ${CLAUDE_HOME}/templates

claude: claude-dirs claude-agents claude-output-styles claude-scripts claude-settings ai-shared ai-claude ## Install Claude Code agents, scripts, settings, and skills
	$(call pretty_print, "Pruning legacy ~/.claude personas/config/templates symlinks...")
	@rm -rf $(CLAUDE_LEGACY)

claude-dirs: ## Create Claude Code directory structure
	$(call mkdir_safe,${CLAUDE_HOME}/agents)
	$(call mkdir_safe,${CLAUDE_HOME}/scripts)
	$(call mkdir_safe,${CLAUDE_HOME}/output-styles)

claude-agents: claude-dirs ## Symlink Claude Code agents (subagent definitions)
	$(call pretty_print, "Installing Claude Code agents...")
	@for a in $(CLAUDE_AGENTS); do ln -sfn "$(DOTFILES)/ai-stuff/agents/$$a" "${CLAUDE_HOME}/agents/$$a"; done

claude-output-styles: claude-dirs ## Symlink Claude Code output styles
	$(call pretty_print, "Installing Claude Code output styles...")
	@for s in $(CLAUDE_OUTPUT_STYLES); do ln -sfn "$(DOTFILES)/ai-stuff/output-styles/$$s" "${CLAUDE_HOME}/output-styles/$$s"; done

claude-scripts: claude-dirs ## Symlink Claude Code scripts (statusline, hooks, etc.)
	$(call pretty_print, "Installing Claude Code scripts...")
	$(call symlink,ai-stuff/claude/scripts/file-suggestion.sh,${CLAUDE_HOME}/scripts/file-suggestion.sh)
	$(call symlink,ai-stuff/claude/scripts/statusline.sh,${CLAUDE_HOME}/scripts/statusline.sh)
	$(call symlink,ai-stuff/claude/scripts/worktree-create.sh,${CLAUDE_HOME}/scripts/worktree-create.sh)
	$(call symlink,ai-stuff/claude/scripts/worktree-remove.sh,${CLAUDE_HOME}/scripts/worktree-remove.sh)
	$(call symlink,ai-stuff/claude/scripts/session-start.sh,${CLAUDE_HOME}/scripts/session-start.sh)
	$(call symlink,ai-stuff/_shared/scripts/auto-approve-tools.sh,${CLAUDE_HOME}/scripts/auto-approve-tools.sh)
	$(call symlink,ai-stuff/claude/scripts/notify.sh,${CLAUDE_HOME}/scripts/notify.sh)
	$(call symlink,ai-stuff/_shared/scripts/focus-iterm.applescript,${CLAUDE_HOME}/scripts/focus-iterm.applescript)
	@chmod +x ${CLAUDE_HOME}/scripts/*.sh

claude-settings: claude-dirs ## Symlink Claude Code settings.json
	$(call pretty_print, "Installing Claude Code settings...")
	$(call symlink,ai-stuff/claude/settings.json,${CLAUDE_HOME}/settings.json)

claude-clean: ai-clean-claude ## Remove Claude Code symlinks
	$(call pretty_print, "Removing Claude Code symlinks...")
	@for a in $(CLAUDE_AGENTS); do rm -f "${CLAUDE_HOME}/agents/$$a"; done
	@for s in $(CLAUDE_OUTPUT_STYLES); do rm -f "${CLAUDE_HOME}/output-styles/$$s"; done
	$(call remove_file,${CLAUDE_HOME}/scripts)
	$(call remove_file,${CLAUDE_HOME}/settings.json)
	@rm -rf $(CLAUDE_LEGACY)

.PHONY: claude claude-dirs claude-agents claude-output-styles claude-scripts claude-settings claude-clean
