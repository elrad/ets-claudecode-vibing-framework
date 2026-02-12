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
echo  Installation complete!
echo ============================================
echo.
echo What was installed:
echo   %USERPROFILE%\.claude\CLAUDE.md    (framework rules)
echo   %USERPROFILE%\.claude\settings.json (permissions and hooks)
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
