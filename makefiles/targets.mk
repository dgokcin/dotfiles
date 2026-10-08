# High-level targets for setting up environments

bootstrap: brew-bundle tools personal claude cursor codex skills raycast ## Set up a new Mac with packages, CLIs, shell, editors, AI configuration, and skills

# Setup personal environment
personal: nvim bash zsh personal-git yamllint k9s

# Setup work environment
work: nvim bash zsh work-git yamllint k9s

.PHONY: bootstrap personal work
