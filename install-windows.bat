@echo off
setlocal enabledelayedexpansion

:: Resolve the folder where this script lives (so it works from any directory)
set "SCRIPT_DIR=%~dp0"

echo ============================================
echo  Claude Code Development Framework Installer
echo ============================================
echo.
echo This installer copies the framework rules to your
echo global Claude Code config folder (~/.claude/).
echo.
echo After install, just run "claude" in any project
echo folder and the framework will be active automatically.
echo.
echo Install location: %USERPROFILE%\.claude\
echo.

set /p PROCEED="Install the framework to %USERPROFILE%\.claude\? (y/n): "
if /i not "!PROCEED!"=="y" (
    echo.
    echo Installation cancelled.
    pause
    exit /b
)

echo.

:: Create .claude folder if needed
if not exist "%USERPROFILE%\.claude" (
    mkdir "%USERPROFILE%\.claude"
    echo Created .claude folder.
)

:: Install CLAUDE.md
if exist "%USERPROFILE%\.claude\CLAUDE.md" (
    echo.
    echo Framework rules (CLAUDE.md) are already installed.
    set /p OVERWRITE_CLAUDE="Overwrite with this version? (y/n): "
    if /i not "!OVERWRITE_CLAUDE!"=="y" (
        echo Keeping existing CLAUDE.md
        goto settings
    )
)
copy /y "%SCRIPT_DIR%CLAUDE.md" "%USERPROFILE%\.claude\CLAUDE.md" >nul
echo Installed CLAUDE.md

:settings
:: Install settings.json
if exist "%USERPROFILE%\.claude\settings.json" (
    echo.
    echo Settings file (settings.json) is already installed.
    echo You may want to manually merge permissions and hooks.
    echo Saving this version as settings-framework.json for reference.
    copy /y "%SCRIPT_DIR%settings.json" "%USERPROFILE%\.claude\settings-framework.json" >nul
    echo Saved settings-framework.json
) else (
    copy /y "%SCRIPT_DIR%settings.json" "%USERPROFILE%\.claude\settings.json" >nul
    echo Installed settings.json
)

echo.
echo ============================================
echo  Core installation complete!
echo ============================================
echo.

:: --- Optional: Semantic Memory ---
echo.
echo --- Optional: Semantic Memory ---
echo.
echo The framework can include a semantic memory system that
echo lets Claude remember things across sessions using meaning-based
echo search (not just keywords). Requires Python 3.10+.
echo.
set /p INSTALL_MEMORY="Install semantic memory? (y/n): "
if /i not "!INSTALL_MEMORY!"=="y" goto done

echo.
echo Checking for Python...

:: Try python first, then python3
set "PYTHON_CMD="
where python >nul 2>&1
if !errorlevel! equ 0 (
    set "PYTHON_CMD=python"
) else (
    where python3 >nul 2>&1
    if !errorlevel! equ 0 (
        set "PYTHON_CMD=python3"
    )
)

if "!PYTHON_CMD!"=="" (
    echo Python not found. Please install Python 3.10+ and try again.
    echo You can install it from https://www.python.org/downloads/
    echo Skipping memory setup.
    goto done
)

:: Check Python version (need 3.10+)
for /f "tokens=2 delims= " %%v in ('!PYTHON_CMD! --version 2^>^&1') do set "PY_VERSION=%%v"
echo Found Python %PY_VERSION%

echo.
echo Installing Python packages (chromadb, mcp)...
echo This may take a minute...
!PYTHON_CMD! -m pip install chromadb>=1.0.0 mcp>=1.0.0 --quiet
if !errorlevel! neq 0 (
    echo.
    echo Failed to install Python packages.
    echo You can try manually: !PYTHON_CMD! -m pip install chromadb mcp
    echo Skipping memory setup.
    goto done
)
echo Packages installed.

:: Copy server to ~/.claude/memory/
echo.
echo Setting up memory server...
if not exist "%USERPROFILE%\.claude\memory" mkdir "%USERPROFILE%\.claude\memory"
copy /y "%SCRIPT_DIR%memory-server\server.py" "%USERPROFILE%\.claude\memory\server.py" >nul
echo Copied server to %USERPROFILE%\.claude\memory\server.py

:: Register MCP server with Claude Code
echo.
echo Registering memory server with Claude Code...
where claude >nul 2>&1
if !errorlevel! neq 0 (
    echo Claude CLI not found in PATH. You can register manually:
    echo   claude mcp add memory-server -- !PYTHON_CMD! "%USERPROFILE%\.claude\memory\server.py"
    goto done
)

claude mcp add-json memory-server "{\"type\":\"stdio\",\"command\":\"!PYTHON_CMD!\",\"args\":[\"%USERPROFILE%\\.claude\\memory\\server.py\"]}" --scope user 2>nul
if !errorlevel! neq 0 (
    :: Fallback to claude mcp add
    claude mcp add memory-server --scope user -- !PYTHON_CMD! "%USERPROFILE%\.claude\memory\server.py" 2>nul
)
echo Memory server registered.
echo.
echo Semantic memory installed! Claude can now use memory_save,
echo memory_search, and other memory tools across all projects.

:done
echo.
echo ============================================
echo  Installation complete!
echo ============================================
echo.
echo What was installed:
echo   %USERPROFILE%\.claude\CLAUDE.md    (framework rules)
echo   %USERPROFILE%\.claude\settings.json (permissions and hooks)
if /i "!INSTALL_MEMORY!"=="y" (
    echo   %USERPROFILE%\.claude\memory\     (semantic memory server)
)
echo.
echo To start using it:
echo   1. Open a terminal in any project folder
echo   2. Run: claude
echo   3. Tell Claude what you want to build
echo   4. The framework kicks in automatically
echo.
echo Templates for docs files are in the templates/ folder.
echo.
pause
