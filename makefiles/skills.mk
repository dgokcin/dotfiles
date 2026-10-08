# Agent skills from ~/codes/skills (github.com/dgokcin/skills).
#
# The vercel-labs `skills` CLI runs the picker and records each pick in
# ~/.agents/.skill-lock.json. It copies skills into ~/.agents/skills and links
# ~/.claude/skills to those copies. skills-link.sh then swaps every copy for a
# symlink into the repo, so edits apply live and skills keep bare names.
#
# Skills read private config from ~/.config/dgokcin-skills, which links to the
# repo's gitignored local/ dir.

SKILLS_REPO := dgokcin/skills
SKILLS_DIR ?= $(HOME)/codes/skills
SKILLS_AGENTS := claude-code codex cursor
SKILLS_CLI := npx -y skills@latest
SKILLS_LINK := $(DOTFILES)/makefiles/scripts/skills-link.sh

skills: skills-repo ## Pick skills from ~/codes/skills interactively and link them live
	@$(SKILLS_CLI) add "$(SKILLS_DIR)" -g -a $(SKILLS_AGENTS)
	@$(SKILLS_LINK) "$(SKILLS_DIR)"

skills-all: skills-repo ## Install every skill from ~/codes/skills without prompting
	@$(SKILLS_CLI) add "$(SKILLS_DIR)" -g -a $(SKILLS_AGENTS) -s '*' -y
	@$(SKILLS_LINK) "$(SKILLS_DIR)"

skills-remove: ## Pick installed skills to remove
	@$(SKILLS_CLI) remove -g
	@$(SKILLS_LINK) "$(SKILLS_DIR)"

skills-list: ## List globally installed skills
	@$(SKILLS_CLI) list -g

skills-repo: ## Clone ~/codes/skills and link its private config
	@[ -d "$(SKILLS_DIR)" ] || git clone "git@github.com:$(SKILLS_REPO).git" "$(SKILLS_DIR)"
	@if [ ! -d "$(SKILLS_DIR)/local" ]; then \
		cp -R "$(SKILLS_DIR)/local.example" "$(SKILLS_DIR)/local"; \
		rm -f "$(SKILLS_DIR)/local/README.md"; \
		echo "created $(SKILLS_DIR)/local from local.example; fill in real values"; \
	fi
	@mkdir -p "$(HOME)/.config"
	@ln -sfn "$(SKILLS_DIR)/local" "$(HOME)/.config/dgokcin-skills"

.PHONY: skills skills-all skills-remove skills-list skills-repo
