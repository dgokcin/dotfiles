# Claude Code configuration setup

CLAUDE_HOME := ${HOME}/.claude

claude: claude-dirs claude-agents claude-skills claude-personas claude-configs ## Install Claude Code agents, skills, and configs

claude-dirs: ## Create Claude Code directory structure
	$(call mkdir_safe,${CLAUDE_HOME}/agents)
	$(call mkdir_safe,${CLAUDE_HOME}/skills)

claude-agents: claude-dirs ## Symlink Claude Code agents
	$(call pretty_print, "Installing Claude Code agents...")
	$(call symlink,claude/agents/mega-dev.md,${CLAUDE_HOME}/agents/mega-dev.md)
	@# Keep existing agents if you want to maintain them separately
	@# Or symlink them from here too:
	@# $(call symlink,claude/agents/gitboi.md,${CLAUDE_HOME}/agents/gitboi.md)
	@# $(call symlink,claude/agents/jiragirl.md,${CLAUDE_HOME}/agents/jiragirl.md)

claude-skills: claude-dirs ## Symlink Claude Code skills
	$(call pretty_print, "Installing Claude Code skills...")
	$(call mkdir_safe,${CLAUDE_HOME}/skills/commit)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/create-pr)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/create-story)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/dev-story)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/get-story)
	$(call symlink,claude/skills/commit/SKILL.md,${CLAUDE_HOME}/skills/commit/SKILL.md)
	$(call symlink,claude/skills/create-pr/SKILL.md,${CLAUDE_HOME}/skills/create-pr/SKILL.md)
	$(call symlink,claude/skills/create-story/SKILL.md,${CLAUDE_HOME}/skills/create-story/SKILL.md)
	$(call symlink,claude/skills/dev-story/SKILL.md,${CLAUDE_HOME}/skills/dev-story/SKILL.md)
	$(call symlink,claude/skills/get-story/SKILL.md,${CLAUDE_HOME}/skills/get-story/SKILL.md)

claude-personas: claude-dirs ## Symlink Claude Code personas (referenced by skills)
	$(call pretty_print, "Installing Claude Code personas...")
	$(call mkdir_safe,${CLAUDE_HOME}/personas)
	$(call symlink,claude/personas/gitboi.md,${CLAUDE_HOME}/personas/gitboi.md)
	$(call symlink,claude/personas/jira-girl.md,${CLAUDE_HOME}/personas/jira-girl.md)
	$(call symlink,claude/personas/mega-dev.md,${CLAUDE_HOME}/personas/mega-dev.md)

claude-configs: claude-dirs ## Symlink Claude Code configs (referenced by skills)
	$(call pretty_print, "Installing Claude Code configs...")
	$(call mkdir_safe,${CLAUDE_HOME}/config)
	$(call symlink,claude/config/jira-config.md,${CLAUDE_HOME}/config/jira-config.md)
	$(call symlink,claude/config/git-config.md,${CLAUDE_HOME}/config/git-config.md)

claude-clean: ## Remove Claude Code symlinks
	$(call pretty_print, "Removing Claude Code symlinks...")
	$(call remove_file,${CLAUDE_HOME}/agents/mega-dev.md)
	$(call remove_file,${CLAUDE_HOME}/skills/commit)
	$(call remove_file,${CLAUDE_HOME}/skills/create-pr)
	$(call remove_file,${CLAUDE_HOME}/skills/create-story)
	$(call remove_file,${CLAUDE_HOME}/skills/dev-story)
	$(call remove_file,${CLAUDE_HOME}/skills/get-story)
	$(call remove_file,${CLAUDE_HOME}/personas)
	$(call remove_file,${CLAUDE_HOME}/config)

.PHONY: claude claude-dirs claude-agents claude-skills claude-personas claude-configs claude-clean
