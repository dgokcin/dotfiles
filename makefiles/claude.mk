# Claude Code configuration setup

CLAUDE_HOME := ${HOME}/.claude

claude: claude-dirs claude-agents claude-skills claude-personas claude-configs claude-templates claude-scripts claude-settings ## Install Claude Code agents, skills, personas, and configs

claude-dirs: ## Create Claude Code directory structure
	$(call mkdir_safe,${CLAUDE_HOME}/agents)
	$(call mkdir_safe,${CLAUDE_HOME}/skills)
	$(call mkdir_safe,${CLAUDE_HOME}/personas)
	$(call mkdir_safe,${CLAUDE_HOME}/config)
	$(call mkdir_safe,${CLAUDE_HOME}/scripts)
	$(call mkdir_safe,${CLAUDE_HOME}/templates)

claude-agents: claude-dirs ## Symlink Claude Code agents (subagent definitions for context: fork)
	$(call pretty_print, "Installing Claude Code agents...")
	$(call symlink,ai-stuff/claude/agents/gitboi.md,${CLAUDE_HOME}/agents/gitboi.md)
	$(call symlink,ai-stuff/claude/agents/jiragirl.md,${CLAUDE_HOME}/agents/jiragirl.md)
	$(call symlink,ai-stuff/claude/agents/mega-dev.md,${CLAUDE_HOME}/agents/mega-dev.md)
	$(call symlink,ai-stuff/claude/agents/steve-square-meter.md,${CLAUDE_HOME}/agents/steve-square-meter.md)
	$(call symlink,ai-stuff/claude/agents/gitops-geezer.md,${CLAUDE_HOME}/agents/gitops-geezer.md)

claude-skills: claude-dirs ## Symlink Claude Code skills
	$(call pretty_print, "Installing Claude Code skills...")
	@# Agent sessions (invoke with /gitboi, /jiragirl, /mega-dev)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/gitboi)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/jiragirl)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/mega-dev)
	$(call symlink,ai-stuff/claude/skills/gitboi/SKILL.md,${CLAUDE_HOME}/skills/gitboi/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/jiragirl/SKILL.md,${CLAUDE_HOME}/skills/jiragirl/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/mega-dev/SKILL.md,${CLAUDE_HOME}/skills/mega-dev/SKILL.md)
	@# GitOps operations (use agent: gitops-geezer)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/gitops-geezer)
	$(call symlink,ai-stuff/claude/skills/gitops-geezer/SKILL.md,${CLAUDE_HOME}/skills/gitops-geezer/SKILL.md)
	@# Git operations (use agent: gitboi)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/commit)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/auto-commit)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/create-pr)
	$(call symlink,ai-stuff/claude/skills/commit/SKILL.md,${CLAUDE_HOME}/skills/commit/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/auto-commit/SKILL.md,${CLAUDE_HOME}/skills/auto-commit/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/create-pr/SKILL.md,${CLAUDE_HOME}/skills/create-pr/SKILL.md)
	@# Jira operations (use agent: jiragirl)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/create-story)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/dev-story)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/get-story)
	$(call symlink,ai-stuff/claude/skills/create-story/SKILL.md,${CLAUDE_HOME}/skills/create-story/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/dev-story/SKILL.md,${CLAUDE_HOME}/skills/dev-story/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/get-story/SKILL.md,${CLAUDE_HOME}/skills/get-story/SKILL.md)
	@# House search operations (use agent: steve-square-meter)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/save-property-to-vault)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/request-viewing)
	$(call symlink,ai-stuff/claude/skills/save-property-to-vault/SKILL.md,${CLAUDE_HOME}/skills/save-property-to-vault/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/request-viewing/SKILL.md,${CLAUDE_HOME}/skills/request-viewing/SKILL.md)
	@# Obsidian vault operations
	$(call mkdir_safe,${CLAUDE_HOME}/skills/meeting-note)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/spike)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/add-recipe)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/add-vinyl)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/weekly-review)
	$(call mkdir_safe,${CLAUDE_HOME}/skills/quick-note)
	$(call symlink,ai-stuff/claude/skills/meeting-note/SKILL.md,${CLAUDE_HOME}/skills/meeting-note/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/spike/SKILL.md,${CLAUDE_HOME}/skills/spike/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/add-recipe/SKILL.md,${CLAUDE_HOME}/skills/add-recipe/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/add-vinyl/SKILL.md,${CLAUDE_HOME}/skills/add-vinyl/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/weekly-review/SKILL.md,${CLAUDE_HOME}/skills/weekly-review/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/quick-note/SKILL.md,${CLAUDE_HOME}/skills/quick-note/SKILL.md)

claude-personas: claude-dirs ## Symlink Claude Code personas (referenced by agents)
	$(call pretty_print, "Installing Claude Code personas...")
	$(call symlink,ai-stuff/claude/personas/gitboi.md,${CLAUDE_HOME}/personas/gitboi.md)
	$(call symlink,ai-stuff/claude/personas/jira-girl.md,${CLAUDE_HOME}/personas/jira-girl.md)
	$(call symlink,ai-stuff/claude/personas/mega-dev.md,${CLAUDE_HOME}/personas/mega-dev.md)
	$(call symlink,ai-stuff/claude/personas/_gitops-geezer.md,${CLAUDE_HOME}/personas/_gitops-geezer.md)

claude-configs: claude-dirs ## Symlink Claude Code configs (referenced by agents)
	$(call pretty_print, "Installing Claude Code configs...")
	$(call symlink,ai-stuff/claude/config/jira-config.md,${CLAUDE_HOME}/config/jira-config.md)
	$(call symlink,ai-stuff/claude/config/git-config.md,${CLAUDE_HOME}/config/git-config.md)
	$(call symlink,ai-stuff/claude/config/house-search-config.md,${CLAUDE_HOME}/config/house-search-config.md)
	$(call symlink,ai-stuff/claude/config/_house-search-private.md,${CLAUDE_HOME}/config/_house-search-private.md)
	$(call symlink,ai-stuff/claude/config/gitops-config.md,${CLAUDE_HOME}/config/gitops-config.md)

claude-templates: claude-dirs ## Symlink Claude Code templates (referenced by skills)
	$(call pretty_print, "Installing Claude Code templates...")
	$(call symlink,ai-stuff/claude/templates/property-frontmatter.yaml,${CLAUDE_HOME}/templates/property-frontmatter.yaml)
	$(call symlink,ai-stuff/claude/templates/property-template.md,${CLAUDE_HOME}/templates/property-template.md)
	$(call symlink,ai-stuff/claude/templates/neighborhood-template.md,${CLAUDE_HOME}/templates/neighborhood-template.md)

claude-scripts: claude-dirs ## Symlink Claude Code scripts (statusline, file-suggestion, etc.)
	$(call pretty_print, "Installing Claude Code scripts...")
	$(call symlink,ai-stuff/claude/scripts/file-suggestion.sh,${CLAUDE_HOME}/scripts/file-suggestion.sh)
	$(call symlink,ai-stuff/claude/scripts/statusline.sh,${CLAUDE_HOME}/scripts/statusline.sh)
	@chmod +x ${CLAUDE_HOME}/scripts/*.sh

claude-settings: claude-dirs ## Symlink Claude Code settings.json
	$(call pretty_print, "Installing Claude Code settings...")
	$(call symlink,ai-stuff/claude/settings.json,${CLAUDE_HOME}/settings.json)

claude-clean: ## Remove Claude Code symlinks
	$(call pretty_print, "Removing Claude Code symlinks...")
	@# Agents
	$(call remove_file,${CLAUDE_HOME}/agents/gitboi.md)
	$(call remove_file,${CLAUDE_HOME}/agents/jiragirl.md)
	$(call remove_file,${CLAUDE_HOME}/agents/mega-dev.md)
	$(call remove_file,${CLAUDE_HOME}/agents/steve-square-meter.md)
	$(call remove_file,${CLAUDE_HOME}/agents/gitops-geezer.md)
	@# Skills
	$(call remove_file,${CLAUDE_HOME}/skills/gitboi)
	$(call remove_file,${CLAUDE_HOME}/skills/jiragirl)
	$(call remove_file,${CLAUDE_HOME}/skills/mega-dev)
	$(call remove_file,${CLAUDE_HOME}/skills/commit)
	$(call remove_file,${CLAUDE_HOME}/skills/auto-commit)
	$(call remove_file,${CLAUDE_HOME}/skills/create-pr)
	$(call remove_file,${CLAUDE_HOME}/skills/create-story)
	$(call remove_file,${CLAUDE_HOME}/skills/dev-story)
	$(call remove_file,${CLAUDE_HOME}/skills/get-story)
	$(call remove_file,${CLAUDE_HOME}/skills/save-property-to-vault)
	$(call remove_file,${CLAUDE_HOME}/skills/request-viewing)
	$(call remove_file,${CLAUDE_HOME}/skills/meeting-note)
	$(call remove_file,${CLAUDE_HOME}/skills/spike)
	$(call remove_file,${CLAUDE_HOME}/skills/add-recipe)
	$(call remove_file,${CLAUDE_HOME}/skills/add-vinyl)
	$(call remove_file,${CLAUDE_HOME}/skills/weekly-review)
	$(call remove_file,${CLAUDE_HOME}/skills/quick-note)
	$(call remove_file,${CLAUDE_HOME}/skills/gitops-geezer)
	@# Personas, configs, and templates
	$(call remove_file,${CLAUDE_HOME}/personas)
	$(call remove_file,${CLAUDE_HOME}/config)
	$(call remove_file,${CLAUDE_HOME}/templates)
	@# Scripts
	$(call remove_file,${CLAUDE_HOME}/scripts)
	@# Settings
	$(call remove_file,${CLAUDE_HOME}/settings.json)

.PHONY: claude claude-dirs claude-agents claude-skills claude-personas claude-configs claude-templates claude-scripts claude-settings claude-clean
