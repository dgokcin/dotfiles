#!/bin/bash

# Check if target directory is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide the target project directory"
    echo "Usage: ./apply-rules.sh <target-project-directory> [-f|--force]"
    exit 1
fi

# Parse arguments
TARGET_DIR="$1"
FORCE_MODE=false
if [ "$2" = "-f" ] || [ "$2" = "--force" ]; then
    FORCE_MODE=true
fi

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "📁 Creating new project directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"

    # Initialize readme for new project
    cat > "$TARGET_DIR/README.md" << 'EOL'
# New Project

This project has been initialized with agile workflow support and auto rule generation configured from [cursor-auto-rules-agile-workflow](https://github.com/bmadcode/cursor-auto-rules-agile-workflow).

For workflow documentation, see [Workflow Rules](docs/workflow-rules.md).
EOL
fi

# Create .cursor/rules directory if it doesn't exist
mkdir -p "$TARGET_DIR/.cursor/rules"

# Copy core rule files with optional override
echo "📦 Copying core rule files..."
for rule_file in $DOTFILES_DIR/.cursor/rules/*.mdc; do
    filename=$(basename "$rule_file")
    target_path="$TARGET_DIR/.cursor/rules/$filename"

    if [ -f "$target_path" ]; then
        if [ "$FORCE_MODE" = true ]; then
            # Check if files are different
            if ! cmp -s "$target_path" "$rule_file"; then
                while true; do
                    read -p "Override existing file $filename? (y/N/d to show diff) " confirm
                    case $confirm in
                        [Yy]* )
                            cp "$rule_file" "$target_path"
                            echo "✔️ Updated: $filename"
                            break
                            ;;
                        [Nn]* | "" )
                            echo "⏭️ Skipped: $filename"
                            break
                            ;;
                        [Dd]* )
                            echo "📊 Showing diff for $filename:"
                            diff -u "$target_path" "$rule_file"
                            echo "----------------------------------------"
                            ;;
                        * )
                            echo "Please answer y, n (or enter), or d for diff"
                            ;;
                    esac
                done
            else
                echo "⏭️ Skipped: $filename (files are identical)"
            fi
        else
            echo "⏭️ Skipped existing file: $filename"
        fi
    else
        cp "$rule_file" "$target_path"
        echo "✔️ Created: $filename"
    fi
done

# Create docs directory if it doesn't exist
mkdir -p "$TARGET_DIR/docs"

# Create workflow documentation
cat > "$TARGET_DIR/docs/workflow-rules.md" << 'EOL'
# Cursor Workflow Rules

This project has been updated to use the auto rule generator from [cursor-auto-rules-agile-workflow](https://github.com/bmadcode/cursor-auto-rules-agile-workflow).

> **Note**: This script can be safely re-run at any time to update the template rules to their latest versions. It will not impact or overwrite any custom rules you've created.

## Core Features

- Automated rule generation
- Standardized documentation formats
- AI behavior control and optimization
- Flexible workflow integration options

## Workflow Integration Options

### 1. Automatic Rule Application (Recommended)
The core workflow rules are automatically installed in `.cursor/rules/`:
- `901-prd.mdc` - Product Requirements Document standards
- `902-arch.mdc` - Architecture documentation standards
- `903-story.mdc` - User story standards
- `801-workflow-agile.mdc` - Complete Agile workflow (optional)

These rules are automatically applied when working with corresponding file types.

### 2. Notepad-Based Workflow
For a more flexible approach, use the templates in `xnotes/`:
1. Enable Notepads in Cursor options
2. Create a new notepad (e.g., "agile")
3. Copy contents from `xnotes/workflow-agile.md`
4. Use \`@notepad-name\` in conversations

> 💡 **Tip:** The Notepad approach is ideal for:
> - Initial project setup
> - Story implementation
> - Focused development sessions
> - Reducing context overhead

## Getting Started

1. Review the templates in \`xnotes/\`
2. Choose your preferred workflow approach
3. Start using the AI with confidence!

EOL

# Update .gitignore if needed
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q "\.cursor/rules/_\*\.mdc" "$TARGET_DIR/.gitignore"; then
        echo -e "\n# Private individual user cursor rules\n.cursor/rules/_*.mdc" >> "$TARGET_DIR/.gitignore"
    fi
else
    echo -e "# Private individual user cursor rules\n.cursor/rules/_*.mdc" > "$TARGET_DIR/.gitignore"
fi

# Create .ai, .ai/arch, .ai/lessons directories
echo "🤖 Creating AI directories..."
mkdir -p "$TARGET_DIR/.ai"/{arch,lessons}

# Create xnotes directory and copy templates
echo "📝 Setting up Notepad templates..."
mkdir -p "$TARGET_DIR/xnotes"
cp -r $DOTFILES_DIR/xnotes/* "$TARGET_DIR/xnotes/"

# Update .cursorignore if needed
if [ -f "$TARGET_DIR/.cursorignore" ]; then
    if ! grep -q "^xnotes/" "$TARGET_DIR/.cursorignore"; then
        echo -e "\n# Project notes and templates\nxnotes/" >> "$TARGET_DIR/.cursorignore"
    fi
else
    echo -e "# Project notes and templates\nxnotes/" > "$TARGET_DIR/.cursorignore"
fi

echo "✨ Deployment Complete!"
echo "📁 Core rules: $TARGET_DIR/.cursor/rules/"
echo "📝 Notepad templates: $TARGET_DIR/xnotes/"
echo "📄 Documentation: $TARGET_DIR/docs/workflow-rules.md"
echo "🔒 Updated .gitignore and .cursorignore"
echo ""
echo "Next steps:"
echo "1. Review the documentation in docs/workflow-rules.md"
echo "2. Choose your preferred workflow approach"
echo "3. Enable Cursor Notepads if using the flexible workflow option"
echo "4. To start a new project, use xnotes/project-idea-prompt.md as a template"
echo "   to craft your initial message to the AI agent"