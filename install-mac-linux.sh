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
echo " Core installation complete!"
echo "============================================"

# --- Optional: Semantic Memory ---
echo ""
echo "--- Optional: Semantic Memory ---"
echo ""
echo "The framework can include a semantic memory system that"
echo "lets Claude remember things across sessions using meaning-based"
echo "search (not just keywords). Requires Python 3.10+."
echo ""
read -p "Install semantic memory? (y/n): " INSTALL_MEMORY
MEMORY_INSTALLED=false

if [ "$INSTALL_MEMORY" = "y" ] || [ "$INSTALL_MEMORY" = "Y" ]; then
    echo ""
    echo "Checking for Python..."

    # Detect python command
    PYTHON_CMD=""
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        PYTHON_CMD="python"
    fi

    if [ -z "$PYTHON_CMD" ]; then
        echo "Python not found. Please install Python 3.10+ and try again."
        echo "Skipping memory setup."
    else
        PY_VERSION=$($PYTHON_CMD --version 2>&1)
        echo "Found $PY_VERSION"

        echo ""
        echo "Installing Python packages (chromadb, mcp)..."
        echo "This may take a minute..."
        if $PYTHON_CMD -m pip install "chromadb>=1.0.0" "mcp>=1.0.0" --quiet 2>/dev/null; then
            echo "Packages installed."

            # Copy server to ~/.claude/memory/
            echo ""
            echo "Setting up memory server..."
            mkdir -p "$HOME/.claude/memory"
            cp "$SCRIPT_DIR/memory-server/server.py" "$HOME/.claude/memory/server.py"
            echo "Copied server to $HOME/.claude/memory/server.py"

            # Register MCP server with Claude Code
            echo ""
            echo "Registering memory server with Claude Code..."
            if command -v claude &>/dev/null; then
                # Get absolute path to python
                PYTHON_PATH=$(command -v $PYTHON_CMD)
                claude mcp add-json memory-server "{\"type\":\"stdio\",\"command\":\"$PYTHON_PATH\",\"args\":[\"$HOME/.claude/memory/server.py\"]}" --scope user 2>/dev/null || \
                    claude mcp add memory-server --scope user -- "$PYTHON_PATH" "$HOME/.claude/memory/server.py" 2>/dev/null
                echo "Memory server registered."
                MEMORY_INSTALLED=true
                echo ""
                echo "Semantic memory installed! Claude can now use memory_save,"
                echo "memory_search, and other memory tools across all projects."
            else
                echo "Claude CLI not found in PATH. You can register manually:"
                echo "  claude mcp add memory-server -- $PYTHON_CMD $HOME/.claude/memory/server.py"
            fi
        else
            echo ""
            echo "Failed to install Python packages."
            echo "You can try manually: $PYTHON_CMD -m pip install chromadb mcp"
            echo "Skipping memory setup."
        fi
    fi
fi

echo ""
echo "============================================"
echo " Installation complete!"
echo "============================================"
echo ""
echo "What was installed:"
echo "  $HOME/.claude/CLAUDE.md     (framework rules)"
echo "  $HOME/.claude/settings.json (permissions and hooks)"
if [ "$MEMORY_INSTALLED" = true ]; then
    echo "  $HOME/.claude/memory/       (semantic memory server)"
fi
echo ""
echo "To start using it:"
echo "  1. Open a terminal in any project folder"
echo "  2. Run: claude"
echo "  3. Tell Claude what you want to build"
echo "  4. The framework kicks in automatically"
echo ""
echo "Templates for docs files are in the templates/ folder."
echo ""
