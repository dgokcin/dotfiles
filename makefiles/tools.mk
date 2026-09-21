# Tool installation and configuration

VOLTA_HOME ?= $(HOME)/.volta
VOLTA := $(VOLTA_HOME)/bin/volta
VOLTA_PACKAGES := corepack @google/gemini-cli @bman654/clodex \
	@agentclientprotocol/claude-agent-acp @zed-industries/codex-acp

ifeq ($(UNAME),Darwin)
PNPM_HOME ?= $(HOME)/Library/pnpm
else
PNPM_HOME ?= $(HOME)/.local/share/pnpm
endif

tools: node npm-tools yarn pnpm bun opencode-cli codex-cli claude-cli ## Install preferred runtimes and CLI tools
	@$(DOTFILES)/makefiles/scripts/verify-tool-owners.sh

volta: ## Install Volta with its official installer
	@if [ ! -x "$(VOLTA)" ]; then \
		tmp=$$(mktemp); \
		trap 'rm -f "$$tmp"' EXIT HUP INT TERM; \
		curl -fsSL https://get.volta.sh -o "$$tmp"; \
		bash "$$tmp" --skip-setup; \
	else \
		echo "Volta already installed at $(VOLTA)"; \
	fi

node: volta ## Install the latest Node.js LTS through Volta
	@"$(VOLTA)" install node

npm-tools: node ## Install npm-backed global CLIs through Volta
	@"$(VOLTA)" install $(VOLTA_PACKAGES)

yarn: npm-tools ## Install project-selected Yarn through Corepack
	@"$(VOLTA_HOME)/bin/corepack" enable yarn --install-directory "$(VOLTA_HOME)/bin"

pnpm: ## Install the native pnpm CLI with its official installer
	@if [ ! -x "$(PNPM_HOME)/pnpm" ] && [ ! -x "$(PNPM_HOME)/bin/pnpm" ]; then \
		installer=$$(mktemp); \
		shell_env=$$(mktemp); \
		trap 'rm -f "$$installer" "$$shell_env"' EXIT HUP INT TERM; \
		curl -fsSL https://get.pnpm.io/install.sh -o "$$installer"; \
		PNPM_HOME="$(PNPM_HOME)" ENV="$$shell_env" SHELL="$$(command -v zsh || command -v bash)" bash "$$installer"; \
	else \
		echo "pnpm already installed under $(PNPM_HOME)"; \
	fi

bun: ## Install Bun with its official installer
	@if [ ! -x "$(HOME)/.bun/bin/bun" ]; then \
		installer=$$(mktemp); \
		installer_home=$$(mktemp -d); \
		trap 'rm -f "$$installer"; rm -rf "$$installer_home"' EXIT HUP INT TERM; \
		curl -fsSL https://bun.com/install -o "$$installer"; \
		HOME="$$installer_home" BUN_INSTALL="$(HOME)/.bun" bash "$$installer"; \
	else \
		echo "Bun already installed at $(HOME)/.bun/bin/bun"; \
	fi

opencode-cli: ## Install OpenCode with its official installer
	@if [ ! -x "$(HOME)/.opencode/bin/opencode" ]; then \
		installer=$$(mktemp); \
		trap 'rm -f "$$installer"' EXIT HUP INT TERM; \
		curl -fsSL https://opencode.ai/install -o "$$installer"; \
		OPENCODE_INSTALL_DIR="$(HOME)/.opencode/bin" bash "$$installer" --no-modify-path; \
	else \
		echo "OpenCode already installed at $(HOME)/.opencode/bin/opencode"; \
	fi

verify-tool-owners: ## Verify every managed CLI resolves through its preferred installer
	@$(DOTFILES)/makefiles/scripts/verify-tool-owners.sh

lazygit: ## Install and configure lazygit in the user's config directory
	$(call install_with_brew,lazygit)
	$(call mkdir_safe,${XDG_CONFIG_HOME}/lazygit)
	$(call symlink,other/lazygit/config.yml,${XDG_CONFIG_HOME}/lazygit/config.yml)

yamllint: ## Set up yamllint with custom configuration in the config directory
	$(call install_with_brew,yamllint)
	$(call mkdir_safe,${HOME}/.config/yamllint)
	$(call symlink,other/yamllint/config,${XDG_CONFIG_HOME}/yamllint/config)

yq: ## Install yq (YAML processor used by makefiles/scripts/skill-meta.sh)
	$(call install_with_brew,yq)

k9s: ## Symlink k9s aliases
	$(call mkdir_safe,${XDG_CONFIG_HOME}/k9s)
	$(call symlink,other/k9s/aliases.yaml,${XDG_CONFIG_HOME}/k9s/aliases.yaml)

tmux: ## Install tmux and symlink config (fixes TERM/escape-sequence bleed with vim)
	$(call install_with_brew,tmux)
	$(call symlink,other/tmux/tmux.conf,${HOME}/.tmux.conf)

brew-trust: ## Trust the third-party taps the Brewfile declares
	@command -v brew >/dev/null || { echo "Homebrew is required"; exit 1; }
	@$(DOTFILES)/makefiles/scripts/brew-trust.sh

brew-bundle: brew-trust ## Install packages and applications from Brewfile
	@command -v brew >/dev/null || { echo "Homebrew is required"; exit 1; }
	@HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file="$(DOTFILES)/Brewfile"

brew-bundle-check: brew-trust ## Check packages and applications from Brewfile
	@command -v brew >/dev/null || { echo "Homebrew is required"; exit 1; }
	@brew bundle check --file="$(DOTFILES)/Brewfile"

.PHONY: tools volta node npm-tools yarn pnpm bun opencode-cli verify-tool-owners \
	lazygit yamllint yq k9s tmux brew-trust brew-bundle brew-bundle-check
