# High-level targets for setting up environments

bootstrap: brew-bundle tools personal claude cursor codex raycast ## Set up a new Mac with packages, CLIs, shell, editors, and AI configuration

# Setup personal environment
personal: nvim bash zsh personal-git yamllint k9s

# Setup work environment
work: nvim bash zsh work-git yamllint k9s

.PHONY: bootstrap personal work
