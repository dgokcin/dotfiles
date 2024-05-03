# This Makefile is used to configure the development environment for both my personal and work contexts.
# It includes modular .mk files for different setups and defines common operations as macros.

DOTFILES := $(shell pwd)
UNAME := $(shell uname)
KERNEL_NAME := $(shell uname -s)
MACHINE := $(shell uname -m)
XDG_CONFIG_HOME ?= $(HOME)/.config

# Modularize the setup for different editors and environments
include makefiles/editors.mk
include makefiles/environments.mk
include makefiles/gitconfigs.mk
include makefiles/shell.mk
include makefiles/tools.mk
include makefiles/utils.mk
include makefiles/targets.mk

# Define reusable macros for common operations
define symlink
	@$(call pretty_print, "Creating symlink\: $(DOTFILES)/$(1) \~\> $(2)")
	@ln -fs $(DOTFILES)/$(1) $(2) || echo "Failed to create symlink for $(1)"
endef

define mkdir_safe
	@$(call pretty_print, "Creating directory $(1)")
	@mkdir -p $(1) || echo "Failed to create directory $(1)"
endef

define remove_file
	@$(call pretty_print, "Removing file $(1)")
	@rm -rf $(1) || echo "Failed to remove $(1)"
endef

# Check if the package is installed, if not, install it
# During installation echo the package name
define install_with_brew
	@brew list $(1) &>/dev/null || (echo "Installing $(1)" && brew install $(1))
endef

# Define a pretty_print macro that handles multiline output and prints in green
define pretty_print
	echo "$1" | while IFS= read -r line; do echo "\033[0;32m$$line\033[0m"; done
endef



# Default goal
.DEFAULT_GOAL := personal

help: ## Display all available targets
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?##"} /^[a-zA-Z0-9_-]+:.*?##/ {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' makefiles/*.mk | sort
