# Shared AI content (configs, templates, scripts) for every AI tool.
#
# Skills live in ~/codes/skills and `make skills` installs them (skills.mk).
# No target in this file touches ~/.claude/skills or ~/.agents/skills.

ai-shared: ## Symlink shared configs/templates/scripts to the tool-agnostic ~/.config/ai-shared
	$(call pretty_print, "Linking $(XDG_CONFIG_HOME)/ai-shared to ai-stuff/_shared")
	@mkdir -p $(XDG_CONFIG_HOME)
	@ln -sfn "$(DOTFILES)/ai-stuff/_shared" "$(XDG_CONFIG_HOME)/ai-shared"

.PHONY: ai-shared
