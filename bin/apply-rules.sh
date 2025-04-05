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

EOL
fi

# Create .cursor directory structure if it doesn't exist
echo "📁 Creating .cursor directory structure..."
mkdir -p "$TARGET_DIR/.cursor/rules"/{core-rules,documentation,global-rules,tool-rules,workflows}
mkdir -p "$TARGET_DIR/.cursor/templates"

# Function to copy files with optional override
copy_files() {
    local src_dir="$1"
    local dest_dir="$2"
    local file_pattern="$3"

    for src_file in $src_dir/$file_pattern; do
        if [ -f "$src_file" ]; then
            local rel_path=${src_file#$src_dir/}
            local dest_file="$dest_dir/$rel_path"
            local dest_subdir=$(dirname "$dest_file")

            # Create subdirectory if it doesn't exist
            mkdir -p "$dest_subdir"

            if [ -f "$dest_file" ]; then
                if [ "$FORCE_MODE" = true ]; then
                    # Check if files are different
                    if ! cmp -s "$dest_file" "$src_file"; then
                        while true; do
                            read -p "Override existing file $rel_path? (y/N/d to show diff) " confirm
                            case $confirm in
                                [Yy]* )
                                    cp "$src_file" "$dest_file"
                                    echo "✔️ Updated: $rel_path"
                                    break
                                    ;;
                                [Nn]* | "" )
                                    echo "⏭️ Skipped: $rel_path"
                                    break
                                    ;;
                                [Dd]* )
                                    echo "📊 Showing diff for $rel_path:"
                                    echo -e "\033[1;37m$(diff -u "$dest_file" "$src_file" | sed -e 's/^-/\x1b[1;31m-/;s/^+/\x1b[1;32m+/;s/^@/\x1b[1;36m@/')\033[0m"
                                    echo "----------------------------------------"
                                    ;;
                                * )
                                    echo "Please answer y, n (or enter), or d for diff"
                                    ;;
                            esac
                        done
                    else
                        echo "⏭️ Skipped: $rel_path (files are identical)"
                    fi
                else
                    echo "⏭️ Skipped existing file: $rel_path"
                fi
            else
                cp "$src_file" "$dest_file"
                echo "✔️ Created: $rel_path"
            fi
        fi
    done
}

# Copy rules and templates
echo "📦 Copying rules and templates..."
copy_files "$DOTFILES_DIR/.cursor/rules" "$TARGET_DIR/.cursor/rules" "**/*.mdc"
copy_files "$DOTFILES_DIR/.cursor/templates" "$TARGET_DIR/.cursor/templates" "*.mdc"

# Copy mcp.example.json to ~/.cursor if it exists
echo "📦 Copying MCP configuration..."
copy_files "$DOTFILES_DIR/.cursor" "$HOME/.cursor" "mcp.example.json"

# Output the workflow documentation wo creating a file
cat << 'EOL'
# Cursor Workflow Rules

This project has been updated to use the auto rule generator from [cursor-auto-rules-agile-workflow](https://github.com/bmadcode/cursor-auto-rules-agile-workflow).

> **Note**: This script can be safely re-run at any time to update the template rules to their latest versions. It will not impact or overwrite any custom rules you've created.

## Core Features

- Automated rule generation
- Standardized documentation formats
- AI behavior control and optimization
- Agile workflow integration

## Workflow Integration

The core workflow rules are automatically installed in:
- `.cursor/rules/` - Contains all rule files organized by category
- `.cursor/templates/` - Contains document templates for PRD, Architecture, and Stories

These rules are automatically applied when working with corresponding file types.

## Getting Started

1. Review the templates in `.cursor/templates/`
2. Start with creating a PRD using the template
3. Follow the agile workflow steps!

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

echo "✨ Deployment Complete!"
echo "📁 Core rules: $TARGET_DIR/.cursor/rules/"
echo "📄 Templates: $TARGET_DIR/.cursor/templates/"
echo "🔒 Updated .gitignore"
echo "⚙️ Copied MCP configuration to ~/.cursor/mcp.json"
echo "Next steps:"
echo "1. Start with creating a PRD using the template"
echo "2. Follow the agile workflow steps"