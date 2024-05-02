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
	ln -fs $(DOTFILES)/$(1) $(2)
endef

define mkdir_safe
	mkdir -p $(1)
endef

define remove_file
	rm -rf $(1)
endef


# Default goal
.DEFAULT_GOAL := personal

# Help target for listing all available targets
help:
	@echo "Available targets:"
	@echo "  personal    : Setup personal environment"
	@echo "  work        : Setup work environment"
	@echo "  clean       : Clean up all configurations"

# Phony targets to ensure Make doesn't get confused by filenames
.PHONY: help personal work clean
