# Claude Code configuration setup

CLAUDE_HOME := ${HOME}/.claude

claude: claude-dirs claude-agents claude-skills claude-personas claude-configs claude-settings ## Install Claude Code agents, skills, personas, and configs

claude-dirs: ## Create Claude Code directory structure
	$(call mkdir_safe,${CLAUDE_HOME}/agents)
	$(call mkdir_safe,${CLAUDE_HOME}/skills)
	$(call mkdir_safe,${CLAUDE_HOME}/personas)
	$(call mkdir_safe,${CLAUDE_HOME}/config)

claude-agents: claude-dirs ## Symlink Claude Code agents (subagent definitions for context: fork)
	$(call pretty_print, "Installing Claude Code agents...")
	$(call symlink,claude/agents/gitboi.md,${CLAUDE_HOME}/agents/gitboi.md)
	$(call symlink,claude/agents/jiragirl.md,${CLAUDE_HOME}/agents/jiragirl.md)
	$(call symlink,claude/agents/mega-dev.md,${CLAUDE_HOME}/agents/mega-dev.md)

claude-skills: claude-dirs ## Symlink Claude Code skills
	$(call pretty_print, "Installing Claude Code skills...")
	@# Agent sessions (invoke with /gitboi, /jiragirl, /mega-dev)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/gitboi)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/jiragirl)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/mega-dev)
	$(call symlink,claude/skills/gitboi/SKILL.md,${CLAUDE_HOME}/skills/gitboi/SKILL.md)
	$(call symlink,claude/skills/jiragirl/SKILL.md,${CLAUDE_HOME}/skills/jiragirl/SKILL.md)
	$(call symlink,claude/skills/mega-dev/SKILL.md,${CLAUDE_HOME}/skills/mega-dev/SKILL.md)
	@# Git operations (use agent: gitboi)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/commit)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/create-pr)
	$(call symlink,claude/skills/commit/SKILL.md,${CLAUDE_HOME}/skills/commit/SKILL.md)
	$(call symlink,claude/skills/create-pr/SKILL.md,${CLAUDE_HOME}/skills/create-pr/SKILL.md)
	@# Jira operations (use agent: jiragirl)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/create-story)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/dev-story)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/get-story)
	$(call symlink,claude/skills/create-story/SKILL.md,${CLAUDE_HOME}/skills/create-story/SKILL.md)
	$(call symlink,claude/skills/dev-story/SKILL.md,${CLAUDE_HOME}/skills/dev-story/SKILL.md)
	$(call symlink,claude/skills/get-story/SKILL.md,${CLAUDE_HOME}/skills/get-story/SKILL.md)

claude-personas: claude-dirs ## Symlink Claude Code personas (referenced by agents)
	$(call pretty_print, "Installing Claude Code personas...")
	$(call symlink,claude/personas/gitboi.md,${CLAUDE_HOME}/personas/gitboi.md)
	$(call symlink,claude/personas/jira-girl.md,${CLAUDE_HOME}/personas/jira-girl.md)
	$(call symlink,claude/personas/mega-dev.md,${CLAUDE_HOME}/personas/mega-dev.md)

claude-configs: claude-dirs ## Symlink Claude Code configs (referenced by agents)
	$(call pretty_print, "Installing Claude Code configs...")
	$(call symlink,claude/config/jira-config.md,${CLAUDE_HOME}/config/jira-config.md)
	$(call symlink,claude/config/git-config.md,${CLAUDE_HOME}/config/git-config.md)

claude-settings: claude-dirs ## Symlink Claude Code settings.json and file-suggestion.sh
	$(call pretty_print, "Installing Claude Code settings...")
	$(call symlink,claude/settings.json,${CLAUDE_HOME}/settings.json)
	$(call symlink,claude/file-suggestion.sh,${CLAUDE_HOME}/file-suggestion.sh)
	@chmod +x ${CLAUDE_HOME}/file-suggestion.sh

claude-clean: ## Remove Claude Code symlinks
	$(call pretty_print, "Removing Claude Code symlinks...")
	@# Agents
	$(call remove_file,${CLAUDE_HOME}/agents/gitboi.md)
	$(call remove_file,${CLAUDE_HOME}/agents/jiragirl.md)
	$(call remove_file,${CLAUDE_HOME}/agents/mega-dev.md)
	@# Skills
	$(call remove_file,${CLAUDE_HOME}/skills/gitboi)
	$(call remove_file,${CLAUDE_HOME}/skills/jiragirl)
	$(call remove_file,${CLAUDE_HOME}/skills/mega-dev)
	$(call remove_file,${CLAUDE_HOME}/skills/commit)
	$(call remove_file,${CLAUDE_HOME}/skills/create-pr)
	$(call remove_file,${CLAUDE_HOME}/skills/create-story)
	$(call remove_file,${CLAUDE_HOME}/skills/dev-story)
	$(call remove_file,${CLAUDE_HOME}/skills/get-story)
	@# Personas and configs
	$(call remove_file,${CLAUDE_HOME}/personas)
	$(call remove_file,${CLAUDE_HOME}/config)
	@# Settings
	$(call remove_file,${CLAUDE_HOME}/settings.json)
	$(call remove_file,${CLAUDE_HOME}/file-suggestion.sh)

.PHONY: claude claude-dirs claude-agents claude-skills claude-personas claude-configs claude-settings claude-clean
