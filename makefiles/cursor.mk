# Cursor IDE configuration setup (agents, skills from repo; personas/templates same as Claude)

CURSOR_HOME := ${HOME}/.cursor

cursor: cursor-dirs cursor-agents cursor-skills cursor-personas cursor-configs cursor-templates ## Install Cursor agents, skills, personas, and configs

cursor-dirs: ## Create Cursor directory structure
	$(call mkdir_safe,${CURSOR_HOME}/agents)
	$(call mkdir_safe,${CURSOR_HOME}/skills)
	$(call mkdir_safe,${CURSOR_HOME}/personas)
	$(call mkdir_safe,${CURSOR_HOME}/config)
	$(call mkdir_safe,${CURSOR_HOME}/templates)

cursor-agents: cursor-dirs ## Symlink Cursor agents (subagent definitions for context: fork)
	$(call pretty_print, "Installing Cursor agents...")
	$(call symlink,ai-stuff/claude/agents/gitboi.md,${CURSOR_HOME}/agents/gitboi.md)
	$(call symlink,ai-stuff/claude/agents/jiragirl.md,${CURSOR_HOME}/agents/jiragirl.md)
	$(call symlink,ai-stuff/claude/agents/mega-dev.md,${CURSOR_HOME}/agents/mega-dev.md)

cursor-skills: cursor-dirs ## Symlink Cursor skills
	$(call pretty_print, "Installing Cursor skills...")
	@# Agent sessions (invoke with /gitboi, /jiragirl, /mega-dev)
	$(call mkdir_safe,${CURSOR_HOME}/skills/gitboi)
	$(call mkdir_safe,${CURSOR_HOME}/skills/jiragirl)
	$(call mkdir_safe,${CURSOR_HOME}/skills/mega-dev)
	$(call symlink,ai-stuff/claude/skills/gitboi/SKILL.md,${CURSOR_HOME}/skills/gitboi/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/jiragirl/SKILL.md,${CURSOR_HOME}/skills/jiragirl/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/mega-dev/SKILL.md,${CURSOR_HOME}/skills/mega-dev/SKILL.md)
	@# Git operations (use agent: gitboi)
	$(call mkdir_safe,${CURSOR_HOME}/skills/commit)
	$(call mkdir_safe,${CURSOR_HOME}/skills/create-pr)
	$(call symlink,ai-stuff/claude/skills/commit/SKILL.md,${CURSOR_HOME}/skills/commit/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/create-pr/SKILL.md,${CURSOR_HOME}/skills/create-pr/SKILL.md)
	@# Jira operations (use agent: jiragirl)
	$(call mkdir_safe,${CURSOR_HOME}/skills/create-story)
	$(call mkdir_safe,${CURSOR_HOME}/skills/dev-story)
	$(call mkdir_safe,${CURSOR_HOME}/skills/get-story)
	$(call symlink,ai-stuff/claude/skills/create-story/SKILL.md,${CURSOR_HOME}/skills/create-story/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/dev-story/SKILL.md,${CURSOR_HOME}/skills/dev-story/SKILL.md)
	$(call symlink,ai-stuff/claude/skills/get-story/SKILL.md,${CURSOR_HOME}/skills/get-story/SKILL.md)

cursor-personas: cursor-dirs ## Symlink Cursor personas (referenced by agents; same sources as Claude)
	$(call pretty_print, "Installing Cursor personas...")
	$(call symlink,ai-stuff/_shared/personas/gitboi.md,${CURSOR_HOME}/personas/gitboi.md)
	$(call symlink,ai-stuff/_shared/personas/jira-girl.md,${CURSOR_HOME}/personas/jira-girl.md)
	$(call symlink,ai-stuff/_shared/personas/mega-dev.md,${CURSOR_HOME}/personas/mega-dev.md)

cursor-configs: cursor-dirs ## Symlink Cursor configs (referenced by agents)
	$(call pretty_print, "Installing Cursor configs...")
	$(call symlink,ai-stuff/_shared/config/jira-config.md,${CURSOR_HOME}/config/jira-config.md)
	$(call symlink,ai-stuff/_shared/config/git-config.md,${CURSOR_HOME}/config/git-config.md)

cursor-templates: cursor-dirs ## Symlink Cursor templates (referenced by skills; same sources as Claude)
	$(call pretty_print, "Installing Cursor templates...")
	$(call symlink,ai-stuff/_shared/templates/property-frontmatter.yaml,${CURSOR_HOME}/templates/property-frontmatter.yaml)
	$(call symlink,ai-stuff/_shared/templates/property-template.md,${CURSOR_HOME}/templates/property-template.md)
	$(call symlink,ai-stuff/_shared/templates/neighborhood-template.md,${CURSOR_HOME}/templates/neighborhood-template.md)

cursor-clean: ## Remove Cursor symlinks
	$(call pretty_print, "Removing Cursor symlinks...")
	@# Agents
	$(call remove_file,${CURSOR_HOME}/agents/gitboi.md)
	$(call remove_file,${CURSOR_HOME}/agents/jiragirl.md)
	$(call remove_file,${CURSOR_HOME}/agents/mega-dev.md)
	@# Skills
	$(call remove_file,${CURSOR_HOME}/skills/gitboi)
	$(call remove_file,${CURSOR_HOME}/skills/jiragirl)
	$(call remove_file,${CURSOR_HOME}/skills/mega-dev)
	$(call remove_file,${CURSOR_HOME}/skills/commit)
	$(call remove_file,${CURSOR_HOME}/skills/create-pr)
	$(call remove_file,${CURSOR_HOME}/skills/create-story)
	$(call remove_file,${CURSOR_HOME}/skills/dev-story)
	$(call remove_file,${CURSOR_HOME}/skills/get-story)
	@# Personas, configs, and templates
	$(call remove_file,${CURSOR_HOME}/personas)
	$(call remove_file,${CURSOR_HOME}/config)
	$(call remove_file,${CURSOR_HOME}/templates)

.PHONY: cursor cursor-dirs cursor-agents cursor-skills cursor-personas cursor-configs cursor-templates cursor-clean
