#!/bin/bash

# Resolve the folder where this script lives (so it works from any directory)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo " Claude Code Development Framework Installer"
echo "============================================"
echo ""
echo "This installer copies the framework rules to your"
echo "global Claude Code config folder (~/.claude/)."
echo ""
echo "After install, just run \"claude\" in any project"
echo "folder and the framework will be active automatically."
echo ""
echo "Install location: $HOME/.claude/"
echo ""

read -p "Install the framework to ~/.claude/? (y/n): " PROCEED
if [ "$PROCEED" != "y" ] && [ "$PROCEED" != "Y" ]; then
    echo ""
    echo "Installation cancelled."
    exit 0
fi

echo ""

# Create .claude folder if needed
if [ ! -d "$HOME/.claude" ]; then
    mkdir -p "$HOME/.claude"
    echo "Created .claude folder."
fi

# Install CLAUDE.md
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    echo ""
    echo "Framework rules (CLAUDE.md) are already installed."
    read -p "Overwrite with this version? (y/n): " OVERWRITE_CLAUDE
    if [ "$OVERWRITE_CLAUDE" != "y" ] && [ "$OVERWRITE_CLAUDE" != "Y" ]; then
        echo "Keeping existing CLAUDE.md"
    else
        cp "$SCRIPT_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
        echo "Installed CLAUDE.md"
    fi
else
    cp "$SCRIPT_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    echo "Installed CLAUDE.md"
fi

# Install settings.json
if [ -f "$HOME/.claude/settings.json" ]; then
    echo ""
    echo "Settings file (settings.json) is already installed."
    echo "You may want to manually merge permissions and hooks."
    echo "Saving this version as settings-framework.json for reference."
    cp "$SCRIPT_DIR/settings.json" "$HOME/.claude/settings-framework.json"
    echo "Saved settings-framework.json"
else
    cp "$SCRIPT_DIR/settings.json" "$HOME/.claude/settings.json"
    echo "Installed settings.json"
fi

echo ""
echo "============================================"
echo " Installation complete!"
echo "============================================"
echo ""
echo "What was installed:"
echo "  $HOME/.claude/CLAUDE.md     (framework rules)"
echo "  $HOME/.claude/settings.json (permissions and hooks)"
echo ""
echo "To start using it:"
echo "  1. Open a terminal in any project folder"
echo "  2. Run: claude"
echo "  3. Tell Claude what you want to build"
echo "  4. The framework kicks in automatically"
echo ""
echo "Templates for docs files are in the templates/ folder."
echo ""
