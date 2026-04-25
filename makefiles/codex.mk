# Codex configuration setup

CODEX_HOME := ${HOME}/.codex
CODEX_SKILLS := \
	add-recipe \
	add-vinyl \
	address-review \
	auto-commit \
	commit \
	create-pr \
	create-story \
	daily-recap \
	dev-story \
	get-story \
	gitboi \
	gitops-geezer \
	jiragirl \
	k8s-debug \
	meeting-note \
	mega-dev \
	quick-note \
	request-viewing \
	save-property-to-vault \
	spike \
	weekly-review

codex: codex-dirs codex-skills ## Install Codex skills from repo

codex-dirs: ## Create Codex directory structure
	$(call mkdir_safe,${CODEX_HOME}/skills)

codex-skills: codex-dirs ## Symlink Codex skills and shared references
	$(call pretty_print, "Installing Codex skills...")
	$(call symlink,ai-stuff/codex/skills/_shared,${CODEX_HOME}/skills/_shared)
	@for skill in ${CODEX_SKILLS}; do \
		$(call pretty_print, "Creating symlink\: $(DOTFILES)/ai-stuff/codex/skills/$$skill \~\> ${CODEX_HOME}/skills/$$skill"); \
		ln -fs $(DOTFILES)/ai-stuff/codex/skills/$$skill ${CODEX_HOME}/skills/$$skill || echo "Failed to create symlink for ai-stuff/codex/skills/$$skill"; \
	done

codex-clean: ## Remove Codex skill symlinks
	$(call pretty_print, "Removing Codex skill symlinks...")
	$(call remove_file,${CODEX_HOME}/skills/_shared)
	@for skill in ${CODEX_SKILLS}; do \
		$(call pretty_print, "Removing file ${CODEX_HOME}/skills/$$skill"); \
		rm -rf ${CODEX_HOME}/skills/$$skill || echo "Failed to remove ${CODEX_HOME}/skills/$$skill"; \
	done

.PHONY: codex codex-dirs codex-skills codex-clean
