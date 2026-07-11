# Universal AI skills installer (Agent Skills standard — agentskills.io)
#
# Skills are authored ONCE in ai-stuff/skills/ (one directory per skill:
# SKILL.md + references/ + scripts/) and symlinked verbatim into every tool's
# skills directory. Same approach as BMAD-METHOD's platform installer
# (tools/installer/ide/platform-codes.yaml), minus the copy step.
#
# Tool registry — one entry per tool. Many tools read the cross-tool standard
# directory ~/.agents/skills (Cursor, Gemini CLI, Windsurf, Warp, GitHub
# Copilot, Roo, OpenHands, ...) — covered by the pseudo-tool "agents".
# Adding a tool with its own directory = 2 lines:
#   AI_TOOLS += cline
#   ai_skills_dir_cline := ${HOME}/.cline/skills

AI_TOOLS := claude codex agents

ai_skills_dir_claude := ${HOME}/.claude/skills
ai_skills_dir_codex  := ${HOME}/.codex/skills
ai_skills_dir_agents := ${HOME}/.agents/skills

# Every entry in ai-stuff/skills/: skill dirs + the _shared symlink that makes
# each skill's relative ../_shared/... references resolve when installed.
# Dot-dirs (.archived) are excluded by the wildcard.
AI_SKILLS := $(notdir $(wildcard $(DOTFILES)/ai-stuff/skills/*))

# Names that used to be installed but no longer exist as skills — pruned on
# every install so stale symlinks don't linger (BMAD's removals.txt pattern).
AI_LEGACY_SKILLS := add-recipe add-vinyl gitboi gitops-geezer meeting-note quick-note request-viewing weekly-review

ai: ai-shared $(addprefix ai-,$(AI_TOOLS)) ## Install universal skills into every registered AI tool

ai-shared: ## Symlink shared personas/configs/templates to the tool-agnostic ~/.config/ai-shared
	$(call pretty_print, "Linking $(XDG_CONFIG_HOME)/ai-shared to ai-stuff/_shared")
	@mkdir -p $(XDG_CONFIG_HOME)
	@ln -sfn "$(DOTFILES)/ai-stuff/_shared" "$(XDG_CONFIG_HOME)/ai-shared"

$(addprefix ai-,$(AI_TOOLS)): ai-%:
	$(call pretty_print, "Installing $(words $(AI_SKILLS)) skills into $(ai_skills_dir_$*)")
	@mkdir -p $(ai_skills_dir_$*)
	@for s in $(AI_SKILLS) $(AI_LEGACY_SKILLS); do rm -rf "$(ai_skills_dir_$*)/$$s"; done
	@for s in $(AI_SKILLS); do ln -sfn "$(DOTFILES)/ai-stuff/skills/$$s" "$(ai_skills_dir_$*)/$$s"; done

ai-list: ## List universal skills and registered AI tools
	@echo "Skills ($(words $(AI_SKILLS))): $(AI_SKILLS)"
	@echo "Tools:"
	@$(foreach t,$(AI_TOOLS),echo "  $(t) -> $(ai_skills_dir_$(t))";)

ai-clean: $(addprefix ai-clean-,$(AI_TOOLS)) ## Remove universal skills from every registered AI tool

$(addprefix ai-clean-,$(AI_TOOLS)): ai-clean-%:
	$(call pretty_print, "Removing skills from $(ai_skills_dir_$*)")
	@for s in $(AI_SKILLS) $(AI_LEGACY_SKILLS); do rm -rf "$(ai_skills_dir_$*)/$$s"; done

.PHONY: ai ai-shared ai-list ai-clean $(addprefix ai-,$(AI_TOOLS)) $(addprefix ai-clean-,$(AI_TOOLS))
