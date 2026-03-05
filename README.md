# Workflow Toolkit

A comprehensive developer workflow plugin for [Claude Code](https://claude.ai/code). Adds session journaling, local task tracking, GitHub issue sync/triage, knowledge base distillation, contribution checks, PR preparation, and skill/agent scaffolding.

## Features

### Session Journaling
Automatic SQLite-backed session tracking with hooks that fire on every lifecycle event:
- **SessionStart** — creates a session record
- **Stop** — increments prompt count per response
- **PostToolUse** — logs every tool invocation with file paths
- **SubagentStop** — tracks subagent spawns
- **PreCompact** — snapshots before context compaction
- **SessionEnd** — writes a full session summary (SQLite + timestamped markdown)

### Task Tracking
Local task management with SQLite + per-task markdown folders:
- `/workflow-toolkit:task-create` — create tasks with priority, tags, and linked issues
- `/workflow-toolkit:task-list` — filter by status, priority, or keyword
- `/workflow-toolkit:task-view` — full task details with TASK.md notes
- `/workflow-toolkit:task-start` / `/workflow-toolkit:task-done` — lifecycle shortcuts
- `/workflow-toolkit:task-update` — update any field

### GitHub Issue Tracking
Sync issues from any GitHub repo into a local SQLite database for offline triage:
- `/workflow-toolkit:issues-sync` — pull issues via `gh` CLI (read-only, never posts)
- `/workflow-toolkit:issues-list` — filter by state, labels, priority, tracking status
- `/workflow-toolkit:issues-view` — full issue details with local metadata
- `/workflow-toolkit:issues-triage` — set priority, status, add notes locally

### Knowledge Base
- `/workflow-toolkit:distill-concept` — analyze codebase patterns and generate structured documentation

### Contribution Workflow
- `/workflow-toolkit:contribution-check` — pre-flight validation (lint, types, size, naming, quality)
- `/workflow-toolkit:pr-prepare` — draft PR title + body, stops for user review (never auto-creates)

### Skill/Agent Scaffolding
- `/workflow-toolkit:create-skill` — scaffold a new Claude Code skill with proper structure
- `/workflow-toolkit:create-agent` — scaffold a new Claude Code subagent
- `/workflow-toolkit:skill-and-agent-factory` — unified factory for both

### Agents
- **contribution-guard** — read-only code reviewer against project rules
- **github-issues** — bulk issue operations, investigation, and codebase correlation

## Prerequisites

- [Claude Code](https://claude.ai/code) v1.0.33+
- `sqlite3` CLI (for hooks and skills)
- `jq` (for hook JSON parsing)
- `gh` CLI (for GitHub issue features — must be authenticated)

## Installation

### From GitHub (recommended)

```bash
# Add as a local plugin
claude --plugin-dir /path/to/workflow-toolkit

# Or add to a marketplace
/plugin marketplace add dougwithseismic/workflow-toolkit
/plugin install workflow-toolkit@dougwithseismic
```

### Manual

Clone the repo and point Claude Code at it:

```bash
git clone https://github.com/dougwithseismic/workflow-toolkit.git
claude --plugin-dir ./workflow-toolkit
```

## How It Works

### Data Storage

All data is stored **per-project** at `$CLAUDE_PROJECT_DIR/.claude/journal/`:
- `journal.db` — SQLite database (sessions, entries, tool usage, issues, tasks)
- `entries/` — timestamped markdown session summaries

The database is auto-initialized on the first `SessionStart` hook.

### Plugin Structure

```
workflow-toolkit/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── skills/                  # 17 skills
│   ├── journal-write/
│   ├── journal-read/
│   ├── task-create/
│   ├── task-list/
│   ├── task-view/
│   ├── task-update/
│   ├── task-start/
│   ├── task-done/
│   ├── issues-sync/
│   ├── issues-list/
│   ├── issues-view/
│   ├── issues-triage/
│   ├── distill-concept/
│   ├── create-skill/
│   ├── create-agent/
│   ├── skill-and-agent-factory/
│   ├── contribution-check/
│   ├── pr-prepare/
│   └── db-viewer/
├── agents/                  # 2 agents
│   ├── contribution-guard.md
│   └── github-issues.md
├── hooks/                   # 8 lifecycle hooks
│   ├── hooks.json
│   ├── init-journal-db.sh
│   ├── session-start-hook.sh
│   ├── journal-hook.sh
│   ├── session-end-hook.sh
│   ├── pre-compact-hook.sh
│   ├── tool-use-hook.sh
│   ├── subagent-stop-hook.sh
│   └── task-completed-hook.sh
├── scripts/
│   └── sync-issues.js
└── README.md
```

## Safety Guarantees

- **Never pushes code** or creates PRs without explicit user consent
- **Never posts to GitHub** — issue tracking is read-only (pull only)
- **Never modifies files** during contribution checks — read and report only
- All data stays local to the project directory

## License

MIT
