# Dotfiles & Development Environment Configuration

A comprehensive dotfiles repository featuring an advanced Cursor rules system, development environment configurations, and AI-assisted workflows. This repository is designed to provide a consistent, maintainable, and intelligent development environment across different contexts.

## 🌟 Key Features

- **Advanced Cursor Rules System**: Intelligent workflow automation and standardization
- **Modular Configuration**: Separate setups for personal and work environments
- **AI-Assisted Development**: Integrated AI tools and custom prompts
- **Shell & Editor Setup**: Comprehensive ZSH, Neovim, and VSCode configurations
- **Git Workflow**: Standardized commit messages and PR templates

## 📁 Repository Structure

```
.
├── .cursor/           # Cursor rules and AI workflow configurations
├── ai-stuff/          # AI-related configurations and prompts
├── bin/              # Utility scripts and tools
├── docs/             # Documentation and guides
├── makefiles/        # Modular make configurations
├── nvim/             # Neovim configuration
└── various dotfiles  # (.zshrc, .gitconfig, etc.)
```

## 🎯 Cursor Rules System

Our Cursor rules system, inspired by [cursor-auto-rules-agile-workflow](https://github.com/bmadcode/cursor-auto-rules-agile-workflow), provides an intelligent framework for standardizing development practices.

### Rule Categories

- **core-rules**: Core rule format and management, foundational rules for the system
- **documentation**: Documentation standards and formatting rules
- **global-rules**: Global rules that apply across all contexts
- **tool-rules**: Tool-specific rules and configurations
- **workflows**: Workflow templates and process standards

### Rule Structure

Each rule follows a standardized format:

```yaml
---
name: Name of the rule
description: ACTION when TRIGGER to OUTCOME  # Critical for agent-selected rules, blank for others
globs: pattern to match files  # Critical glob pattern for auto rules, blank for others
alwaysApply: true|false  # Determines if rule is applied to every request
---
```

#### Rule Types

- **Agent Selected**: Agent sees description and chooses when to apply
- **Always**: Applied to every chat and cmd-k request
- **Auto Select**: Applied to matching existing files
- **Auto Select+desc**: Better for new files, includes description
- **Manual**: User must reference in chat

## 🚀 Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

2. **Choose Your Setup**

   ```bash
   make personal  # For personal environment
   make work     # For work environment
   ```

3. **Individual Components**

   ```bash
   make zsh      # Configure ZSH
   make nvim     # Setup Neovim
   make vscode   # Configure VSCode
   ```

## 🛠 Components

### Git Configuration

- `base.gitconfig`: Common Git settings
- `work.gitconfig`: Work-specific configurations

### Shell Environment

- `.zshrc`: ZSH configuration with custom plugins
- `.aliases`: Useful command aliases
- `.functions`: Custom shell functions

### Development Tools

- Neovim configuration
- VSCode settings
- Lazygit setup
- Continue AI integration
- Karabiner (macOS)

## 🤖 AI Integration

The repository includes various AI-assisted development tools:

### Cursor Prompts

- PR description generation
- Commit message standardization
- Code explanation
- Project structure analysis
- Infrastructure expertise (Terraform, Docker, GHA)

### AI Tools Configuration

- Continue AI setup
- Custom AI workflows
- Memory bank system

## 📋 Workflow Automation

- Standardized documentation templates
- Automated rule application
- Integrated memory system for AI interactions
- Agile workflow templates

## 🔧 Customization

1. **Shell Customization**
   - Edit `.zshrc` for shell behavior
   - Modify `.aliases` for custom commands

2. **Git Setup**
   - Adjust `base.gitconfig` for common settings
   - Configure `work.gitconfig` for work-specific needs

3. **AI Workflows**
   - Customize prompts in `ai-stuff/cursor/prompts`
   - Modify rule templates in `.cursor/rules`

## 📚 Documentation

- Check `docs/` for detailed guides
- Review `.cursor/rules/*.mdc` for workflow standards

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and follow our commit message conventions (see rule 901-commit-message).

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

> **Note**: This repository is continuously evolving. Check the CHANGELOG.md for recent updates and improvements.
