# Targets shared by local `make` and the Dotfiles GitHub Actions workflow.
#
# Linux CI:  make lint, make test, make test-bootstrap, make install-ci + verify-install
# macOS CI:  make cursor-user-config (Darwin Library path) + make brew-health
#
#   make lint            actionlint + shellcheck + yamllint + JSON
#   make test            skill metadata + statusline fixtures
#   make test-bootstrap  bootstrap dependency and installer contract
#   make install-ci      symlink install (set HOME / XDG_CONFIG_HOME first)
#   make verify-install  assert those symlinks point back at this repo
#   make brew-health     Brewfile formulae/casks still resolve

YAML_LINT_PATHS := .github FUNDING.yml other/k9s other/lazygit nvim/.markdownlint.yaml ai-stuff

lint: lint-actions lint-shell lint-yaml lint-json ## Lint workflows, scripts, YAML, and JSON

lint-actions:
	@command -v actionlint >/dev/null || { echo "lint-actions: install actionlint (brew install actionlint)"; exit 1; }
	@actionlint

lint-shell:
	@command -v shellcheck >/dev/null || { echo "lint-shell: install shellcheck (brew install shellcheck)"; exit 1; }
	@$(DOTFILES)/makefiles/scripts/lint-shell.sh

lint-yaml:
	@command -v yamllint >/dev/null || { echo "lint-yaml: install yamllint (brew install yamllint)"; exit 1; }
	@yamllint -c $(DOTFILES)/other/yamllint/config $(YAML_LINT_PATHS)

lint-json:
	@$(DOTFILES)/makefiles/scripts/lint-json.sh

test: ai-check test-statusline ## Skill lint + statusline fixture tests

test-statusline:
	@$(DOTFILES)/ai-stuff/claude/scripts/statusline-test.sh

test-bootstrap: ## Verify bootstrap contains preferred installers without executing them
	@$(DOTFILES)/makefiles/scripts/test-bootstrap.sh

# Same symlink surface as personal/work + the AI tool layers, without brew
# installs. CI (and local dry-runs) must set HOME / XDG_CONFIG_HOME first.
install-ci: nvim bash zsh setup-git k9s claude-dotfiles cursor codex-dotfiles ## Isolated symlink install for CI

verify-install: ## Assert install-ci symlinks point at this repo
	@$(DOTFILES)/makefiles/scripts/verify-install.sh

brew-health: ## Fail if Brewfile taps/formulae/casks are missing (stale ones fail when FAIL_STALE=1)
	@$(DOTFILES)/makefiles/scripts/brew-health.sh

.PHONY: lint lint-actions lint-shell lint-yaml lint-json test test-statusline test-bootstrap install-ci verify-install brew-health
