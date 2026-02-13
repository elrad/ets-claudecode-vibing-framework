# Claude Code Development Framework

A structured way to build projects with Claude Code. It keeps your work organized, saves progress automatically, and makes sure nothing is lost between sessions.

---

## What This Framework Does

When you work with Claude Code, conversations disappear when the session ends or the context gets too large. This framework solves that by saving everything to files that persist forever.

**In short:**
- The spec is the source of truth — code follows the spec, not the other way around
- Claude always makes a plan before writing code
- All decisions, progress, and errors are saved to files
- Every new session picks up exactly where the last one left off
- You get a menu of quick actions you can customize
- Every feature gets tested before moving on
- Files are created only when needed, not all at once

---

## Install

### Windows
1. Unzip this folder
2. Double-click `install-windows.bat`
3. Done

### Mac / Linux
1. Unzip this folder
2. Open a terminal in this folder
3. Run: `chmod +x install-mac-linux.sh && ./install-mac-linux.sh`
4. Done

### Manual Install
1. Copy `CLAUDE.md` to `~/.claude/CLAUDE.md`
2. Copy `settings.json` to `~/.claude/settings.json` (or merge into your existing one)

> **Windows path:** `C:\Users\<YourName>\.claude\`
> **Mac/Linux path:** `~/.claude/`

---

## What Gets Installed

Two files go into your `~/.claude/` folder:

| File | What it does |
|------|-------------|
| `CLAUDE.md` | Rules that tell Claude how to work — plan first, spec is source of truth, save progress, test everything |
| `settings.json` | Auto-allows safe read permissions, adds notification sounds when Claude finishes |

These apply to **every project** automatically.

---

## How to Use It

1. Open a terminal in any project folder
2. Run `claude`
3. Tell Claude what you want to build
4. Claude writes a spec and plan, asks for your approval, then starts building

### Core Principles

- **Spec is source of truth.** The spec describes what you're building. Code follows it. If the code reveals the spec needs changing, Claude asks you first — it never silently drifts.
- **Plan before code.** Nothing gets built without a plan you've approved.
- **Test as you go.** Every feature gets tested. Tests must pass before moving to the next task. The loop is: change → test → fix → verify.
- **You're in control.** Claude doesn't modify the task list, change priorities, or update the spec without your say-so.

---

## Project Files

Claude creates files progressively — only when they're actually needed:

| File | Created when | What it does |
|------|-------------|-------------|
| `docs/SPEC.md` | Project start | Source of truth — what you're building |
| `docs/TODO.md` | Project start | Simple task list — open/done |
| `docs/DECISIONS.md` | First decision | Why things were chosen |
| `docs/ERRORS.md` | First error | Knowledge base: pattern → cause → fix |
| `docs/STRUCTURE.md` | Enough files exist | Map of project files and folders |
| `docs/CHANGELOG.md` | First session ends | What changed each session |
| `docs/MENU.md` | You customize actions | Your saved quick actions |
| `docs/references/` | You provide docs | External reference documents |
| `tests/` | First feature | Acceptance and regression tests |

---

## The Menu

Type **`menu`** at any time to see your available actions and pick one.

### Default actions:
1. **Save progress** — writes all current work to the docs files
2. **Run tests** — runs all test scripts
3. **Run project** — installs, builds, and starts the project

### Running menu items:
- Type `2` to run all tests
- Type `2 login` to run tests only for the login feature

### Customizing the menu:
- `menu add [name]: [description]` — add a new action
- `menu move [number] to [number]` — reorder
- `menu delete [number]` — remove an action

### Editing the framework:
- `rules` — view and edit the framework rules
- `rules add [rule]` — add a new rule
- `rules edit [section]` — change an existing section

---

## Session Memory

### Starting a session
Claude reads the TODO first (to know what's next), then loads relevant parts of the spec and other docs. Shows you a summary of last session.

### During work
- Tasks update as they're completed
- Decisions are logged as they're made
- Errors are saved as reusable patterns
- Claude suggests menu actions when they'd help

### Ending a session
Claude saves everything before the session ends or context runs out. Nothing is lost.

---

## Semantic Memory (Optional)

The framework can optionally include a semantic memory system — a local database that lets Claude find relevant knowledge by **meaning**, not just keywords.

### What it does
- Stores memories (decisions, errors, preferences, patterns, context) in a local database
- Finds relevant memories using semantic search — "authentication timeout issue" finds memories about "login session expiry"
- Works across all projects and sessions
- Runs entirely on your machine — no data leaves your computer

### How to install
The installer asks if you want to set it up. You need:
- **Python 3.10+** installed
- That's it — the installer handles the rest (installs packages, copies the server, registers it with Claude)

### How Claude uses it
- **Session start** — searches for memories related to the current project
- **Before debugging** — checks if a similar error was solved before
- **After solving problems** — saves the solution for next time
- **Decisions** — remembers why things were chosen

### Memory tools available to Claude
| Tool | What it does |
|------|-------------|
| `memory_save` | Store a memory with type, tags, and project |
| `memory_search` | Find memories by meaning |
| `memory_query` | Filter by type, project, or tags |
| `memory_list` | Browse recent memories |
| `memory_delete` | Remove a memory |

### Manual install
If you skipped it during install, you can set it up later:
```bash
pip install chromadb mcp
cp memory-server/server.py ~/.claude/memory/server.py
claude mcp add memory-server -- python ~/.claude/memory/server.py
```

---

## Errors as Knowledge

Unlike a traditional bug log, ERRORS.md is a **knowledge base**. Entries look like:

```
### Module not found after install
**Pattern:** "Cannot find module 'xyz'" after npm install
**Cause:** Package not added to dependencies
**Fix:** Run npm install xyz --save
```

No dates, no narrative. Just: what it looks like, what causes it, what fixes it. Claude checks this file before debugging anything — so it doesn't waste time re-researching solved problems.

---

## Example Workflow

```
You:    "I want to build a todo app with React"
Claude: Creates docs/, writes spec and plan
Claude: "Here's the spec and plan. Approve?"

You:    "Looks good, go"
Claude: Builds step by step, testing each piece, committing as it goes

You:    "menu"
Claude: Shows your action menu — pick one to run

You:    "2"
Claude: Runs all tests, shows results

        ... next day ...

You:    Open Claude Code in the same folder
Claude: "Last session: built the task list and add form.
         Next up: delete and edit features. No open questions."
```

---

## Templates

The `templates/` folder has starter versions of all docs files. You can copy these into a project's `docs/` folder to set it up manually, but you usually don't need to — Claude creates them progressively as needed.

---

## Sound Notifications

The framework includes notification sounds (Windows only by default):
- **3 beeps** when Claude finishes working
- **3 higher beeps** when Claude needs your attention

To change or remove these, edit the `hooks` section in `~/.claude/settings.json`.

For Mac/Linux, replace the PowerShell beep commands with your system's notification tool (e.g. `afplay`, `paplay`, or `tput bel`).

---

## Tips

- **Type `menu` often** — fastest way to run common actions
- **Provide reference docs early** — the more context, the better the output
- **Don't worry about losing progress** — the framework saves automatically
- **Customize the menu** — add actions you repeat so they're one click away
- **Check ERRORS.md before debugging** — the fix might already be there
- **The spec is your anchor** — if something feels wrong, check the spec first

---

## What's in the Box

```
framework-package/
  CLAUDE.md              -- The framework rules (gets installed globally)
  settings.json          -- Permissions and sound notifications
  install-windows.bat    -- One-click installer for Windows
  install-mac-linux.sh   -- One-click installer for Mac/Linux
  README.md              -- This file
  templates/             -- Starter templates for project docs
    SPEC.md
    TODO.md
    DECISIONS.md
    ERRORS.md
    STRUCTURE.md
    CHANGELOG.md
    MENU.md
  memory-server/         -- Semantic memory MCP server (optional)
    server.py
    requirements.txt
```

---

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- A terminal (Command Prompt, PowerShell, Terminal, etc.)
- **Optional:** Python 3.10+ (only needed for semantic memory)
- That's it
