# dotfiles

This repository contains my personal dotfiles and configuration scripts for setting up development environments across different contexts (personal and work).

## Table of Contents

- [dotfiles](#dotfiles)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Components](#components)
    - [Git Configuration](#git-configuration)
    - [Shell Configuration](#shell-configuration)
    - [Editors](#editors)
    - [Tools](#tools)
  - [AI-Stuff Directory](#ai-stuff-directory)
  - [Cursor Rules and Workflows](#cursor-rules-and-workflows)
    - [Core Rule Templates](#core-rule-templates)
    - [Workflow Automation](#workflow-automation)
    - [Key Features](#key-features)
    - [Configuration](#configuration)
  - [Customization](#customization)

## Overview

This dotfiles repository is designed to provide a modular and flexible setup for both personal and work environments. It uses a Makefile-based system to manage various configurations and tools, allowing for easy installation and customization.

Key features:

- Modular configuration for different editors and environments
- Separate Git configurations for personal and work setups
- Shell configuration with Oh My Zsh and custom plugins
- Various development tools and utilities
- AI-assisted development tools and prompts

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```bash

2. Run the appropriate make command for your setup:

   ```bash
   make personal  # For personal setup
   make work      # For work setup
   ```

## Usage

The repository uses a Makefile to manage different aspects of the setup. Here are some common commands:

- `make help`: Display all available targets
- `make personal`: Set up personal environment
- `make work`: Set up work environment
- `make personal-git`: Configure Git for personal use
- `make work-git`: Configure Git for work use
- `make zsh`: Set up Zsh configuration
- `make nvim`: Set up Neovim configuration
- `make vscode`: Set up Visual Studio Code configuration

For a full list of available commands, run `make help`.

## Components

### Git Configuration

- `base.gitconfig`: Common Git configuration
- `work.gitconfig`: Work-specific Git settings

### Shell Configuration

- `.zshrc`: Zsh configuration file
- Oh My Zsh with custom plugins

### Editors

- Neovim configuration
- Visual Studio Code settings

### Tools

- Lazygit
- Yamllint
- Continue AI
- Karabiner (for macOS)

## AI-Stuff Directory

The `ai-stuff` directory contains various AI-assisted development tools and prompts:

- `cursor/prompts`: Custom prompts for AI-powered coding assistants
  - `create-pr`: Prompt for generating pull request descriptions
  - `create-commit`: System prompt for generating standardized Git commit messages
  - `explain-project`: Prompt for explaining project structure and approach
  - `create-issue`: Prompt for creating well-structured GitHub issues
  - `create-summary`: Prompt for summarizing content
  - `explain-code`: Prompt for explaining code snippets or configurations
  - `terraform-expert`: Prompt for Terraform and Terragrunt expertise
  - `gha-expert`: Prompt for GitHub Actions expertise
  - `containerization-expert`: Prompt for Docker-related queries
- `continue`: Configuration for the Continue AI tool
- `fabric`: Additional AI-related scripts or configurations

These AI-assisted tools and prompts are designed to enhance your development workflow by providing intelligent suggestions, explanations, and automations.

## Cursor Rules and Workflows

> This section is adapted from [bmadcode's cursor-auto-rules-agile-workflow](https://github.com/bmadcode/cursor-auto-rules-agile-workflow) repository and [Meh-S-Eze's best practices guide](https://forum.cursor.com/t/my-best-practices-for-mdc-rules-and-troubleshooting/50526/3) on the Cursor forum. Credit to the original authors for their excellent work on Cursor rules implementation and best practices.

The repository includes a comprehensive set of Cursor rules and workflow templates to standardize development practices with my flavor of customizations.

### Core Rule Templates

- Located in `.cursor/rules/*.mdc`
- Implements standardized formats for:
  - Product Requirements Documents (PRD)
  - Architecture Documentation
  - Story Templates
  - Documentation Standards

### Workflow Automation

- `bin/apply-rules.sh`: Automation script for rule deployment
- `docs/workflow-rules.md`: Detailed documentation of workflow rules
- `xnotes/*`: Workflow templates for various development scenarios

### Key Features

- Standardized cursor rule format for consistency
- Integrated memory bank system for AI interactions
- Agile workflow templates and documentation
- Documentation standards for PRDs, architecture, and stories

### Configuration

- `.cursorignore`: Configured to exclude workflow templates (xnotes)
- `.gitignore`: Set up to protect private rules
- `.path`: Includes DOTFILES_DIR configuration

## Customization

You can customize the setup by modifying the relevant configuration files:

- Edit `.zshrc` for shell customizations
- Modify Git configs in `base.gitconfig`, or `work.gitconfig`
- Adjust editor settings in their respective configuration files
- Customize AI prompts in the `ai-stuff/cursor/prompts` directory
