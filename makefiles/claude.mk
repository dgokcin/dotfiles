# Claude Code configuration setup (tool-specific layer)
#
# Universal skills are installed by makefiles/ai.mk (make ai-claude).
# This file only handles what is Claude Code-specific: agents, personas,
# configs, templates (referenced by agents via @~/.claude/... includes),
# hook scripts, and settings.json.

CLAUDE_HOME := ${HOME}/.claude

CLAUDE_AGENTS := $(notdir $(wildcard $(DOTFILES)/ai-stuff/agents/*.md))

claude: claude-dirs claude-agents claude-personas claude-configs claude-templates claude-scripts claude-settings ai-claude ## Install Claude Code agents, personas, configs, scripts, settings, and skills

claude-dirs: ## Create Claude Code directory structure
	$(call mkdir_safe,${CLAUDE_HOME}/agents)
	$(call mkdir_safe,${CLAUDE_HOME}/personas)
	$(call mkdir_safe,${CLAUDE_HOME}/config)
	$(call mkdir_safe,${CLAUDE_HOME}/scripts)
	$(call mkdir_safe,${CLAUDE_HOME}/templates)

claude-agents: claude-dirs ## Symlink Claude Code agents (subagent definitions)
	$(call pretty_print, "Installing Claude Code agents...")
	@for a in $(CLAUDE_AGENTS); do ln -sfn "$(DOTFILES)/ai-stuff/agents/$$a" "${CLAUDE_HOME}/agents/$$a"; done

claude-personas: claude-dirs ## Symlink personas (referenced by agents)
	$(call pretty_print, "Installing Claude Code personas...")
	$(call symlink,ai-stuff/_shared/personas/gitboi.md,${CLAUDE_HOME}/personas/gitboi.md)
	$(call symlink,ai-stuff/_shared/personas/jira-girl.md,${CLAUDE_HOME}/personas/jira-girl.md)
	$(call symlink,ai-stuff/_shared/personas/mega-dev.md,${CLAUDE_HOME}/personas/mega-dev.md)
	$(call symlink,ai-stuff/_shared/personas/_gitops-geezer.md,${CLAUDE_HOME}/personas/_gitops-geezer.md)

claude-configs: claude-dirs ## Symlink configs (referenced by agents)
	$(call pretty_print, "Installing Claude Code configs...")
	$(call symlink,ai-stuff/_shared/config/jira-config.md,${CLAUDE_HOME}/config/jira-config.md)
	$(call symlink,ai-stuff/_shared/config/git-config.md,${CLAUDE_HOME}/config/git-config.md)
	$(call symlink,ai-stuff/_shared/config/house-search-config.md,${CLAUDE_HOME}/config/house-search-config.md)
	$(call symlink,ai-stuff/_shared/config/_house-search-private.md,${CLAUDE_HOME}/config/_house-search-private.md)
	$(call symlink,ai-stuff/_shared/config/gitops-config.md,${CLAUDE_HOME}/config/gitops-config.md)
	$(call symlink,ai-stuff/_shared/config/.clusters.json,${CLAUDE_HOME}/config/.clusters.json)

claude-templates: claude-dirs ## Symlink templates (referenced by agents and settings)
	$(call pretty_print, "Installing Claude Code templates...")
	$(call symlink,ai-stuff/_shared/templates/property-frontmatter.yaml,${CLAUDE_HOME}/templates/property-frontmatter.yaml)
	$(call symlink,ai-stuff/_shared/templates/property-template.md,${CLAUDE_HOME}/templates/property-template.md)
	$(call symlink,ai-stuff/_shared/templates/neighborhood-template.md,${CLAUDE_HOME}/templates/neighborhood-template.md)
	$(call symlink,ai-stuff/_shared/templates/daily-recap-output.md,${CLAUDE_HOME}/templates/daily-recap-output.md)

claude-scripts: claude-dirs ## Symlink Claude Code scripts (statusline, hooks, etc.)
	$(call pretty_print, "Installing Claude Code scripts...")
	$(call symlink,ai-stuff/claude/scripts/file-suggestion.sh,${CLAUDE_HOME}/scripts/file-suggestion.sh)
	$(call symlink,ai-stuff/claude/scripts/statusline.sh,${CLAUDE_HOME}/scripts/statusline.sh)
	$(call symlink,ai-stuff/claude/scripts/worktree-create.sh,${CLAUDE_HOME}/scripts/worktree-create.sh)
	$(call symlink,ai-stuff/claude/scripts/worktree-remove.sh,${CLAUDE_HOME}/scripts/worktree-remove.sh)
	$(call symlink,ai-stuff/claude/scripts/session-start.sh,${CLAUDE_HOME}/scripts/session-start.sh)
	$(call symlink,ai-stuff/claude/scripts/auto-approve-tools.sh,${CLAUDE_HOME}/scripts/auto-approve-tools.sh)
	$(call symlink,ai-stuff/claude/scripts/notify.sh,${CLAUDE_HOME}/scripts/notify.sh)
	$(call symlink,ai-stuff/claude/scripts/focus-iterm.applescript,${CLAUDE_HOME}/scripts/focus-iterm.applescript)
	$(call symlink,ai-stuff/claude/scripts/pr-status.sh,${CLAUDE_HOME}/scripts/pr-status.sh)
	$(call symlink,ai-stuff/claude/scripts/worktree-cleanup-scan.sh,${CLAUDE_HOME}/scripts/worktree-cleanup-scan.sh)
	$(call symlink,ai-stuff/claude/scripts/worktree-cleanup-remove.sh,${CLAUDE_HOME}/scripts/worktree-cleanup-remove.sh)
	@chmod +x ${CLAUDE_HOME}/scripts/*.sh

claude-settings: claude-dirs ## Symlink Claude Code settings.json
	$(call pretty_print, "Installing Claude Code settings...")
	$(call symlink,ai-stuff/claude/settings.json,${CLAUDE_HOME}/settings.json)

claude-clean: ai-clean-claude ## Remove Claude Code symlinks
	$(call pretty_print, "Removing Claude Code symlinks...")
	@for a in $(CLAUDE_AGENTS); do rm -f "${CLAUDE_HOME}/agents/$$a"; done
	$(call remove_file,${CLAUDE_HOME}/personas)
	$(call remove_file,${CLAUDE_HOME}/config)
	$(call remove_file,${CLAUDE_HOME}/templates)
	$(call remove_file,${CLAUDE_HOME}/scripts)
	$(call remove_file,${CLAUDE_HOME}/settings.json)

.PHONY: claude claude-dirs claude-agents claude-personas claude-configs claude-templates claude-scripts claude-settings claude-clean
