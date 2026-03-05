# Workflow Toolkit

**Get up to speed in any codebase, any size.**

A non-opinionated workflow plugin for [Claude Code](https://claude.ai/code) that keeps track of what you're working on and what you need to do next. Session journaling, local task tracking, GitHub issue sync, and a handful of lifecycle hooks — all backed by a local SQLite database. Nothing leaves your machine.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v1.0.33+-blueviolet)](https://claude.ai/code)

Built by [Doug Silkstone](https://contra.com/doug_silkstone)

---

## The Problem

You drop into an unfamiliar codebase. You start exploring, fixing bugs, shipping features. A few sessions later, you can't remember what you changed on Tuesday, which issue you were investigating, or what you decided to do next.

Claude Code sessions are ephemeral. Context disappears when the terminal closes. There's no trail of what happened, no way to pick up where you left off, and no structure to keep things moving forward.

**Workflow Toolkit gives you that structure** — without imposing opinions about how you work.

---

## Quick Start

```bash
# Install from the marketplace
/plugin marketplace add dougwithseismic/workflow-toolkit
/plugin install workflow-toolkit@dougwithseismic

# Or load directly for testing
claude --plugin-dir /path/to/workflow-toolkit
```

The database initializes automatically on your first session. No config files to edit, no setup steps.

---

## What It Does

### 1. Journals Your Sessions (automatic)

Lifecycle hooks fire silently in the background, recording every session to SQLite. When a session ends, you get a full summary:

```
Session Summary: abc123

Started: 2026-03-05 14:00:00
Ended:   2026-03-05 15:45:00

| Metric          | Count |
|-----------------|-------|
| Prompts         | 47    |
| Tool Uses       | 183   |
| Subagents       | 3     |
| Compactions     | 1     |
| Journal Entries | 2     |

Top Tools Used:
Edit (52x)  Read (41x)  Bash (38x)  Grep (27x)  Glob (25x)
```

Each session also writes a timestamped markdown file to `.claude/journal/entries/` so you can browse history outside Claude Code.

**Write manual entries when you want to capture decisions or context:**

```
> /workflow-toolkit:journal-write Decided to use repository pattern for data access layer
```

**Search your history:**

```
> /workflow-toolkit:journal-read search repository

id  timestamp            type    summary
--  -------------------  ------  ------------------------------------------------
14  2026-03-05 15:30:00  manual  Decided to use repository pattern for data access
 9  2026-03-04 10:15:00  auto    Refactored user queries into UserRepository
```

You come back next week and run `/workflow-toolkit:journal-read last 5` — instant context on where you left off.

---

### 2. Tracks Your Tasks

Local task management that lives alongside your code. Create tasks, link them to GitHub issues, move them through a simple lifecycle.

```
> /workflow-toolkit:task-create Fix login redirect loop --priority high --tags "auth,bug" --issue 456

Created task #7: Fix login redirect loop
  Priority: high | Tags: auth, bug | Issue: #456
  Folder: .claude/tasks/fix-login-redirect-loop/
```

```
> /workflow-toolkit:task-start 7
Started task #7: Fix login redirect loop (priority: high)

> /workflow-toolkit:task-done 7 Root cause was missing session cookie on redirect
Completed task #7: Fix login redirect loop
Duration: 1h 23m
```

```
> /workflow-toolkit:task-list

id  title                        status       priority  issue  created_at
--  ---------------------------  -----------  --------  -----  -------------------
 5  Add rate limiting to API     in-progress  medium    #412   2026-03-04 09:00:00
 3  Write onboarding docs        todo         low              2026-03-03 11:00:00

2 active tasks (1 in-progress, 1 todo)
```

Each task gets a folder at `.claude/tasks/<slug>/TASK.md` — use it for reproduction steps, working notes, anything you want to persist.

---

### 3. Syncs GitHub Issues Locally

Pull issues from any GitHub repo into your local database. Filter, prioritize, and annotate them without touching GitHub.

```
> /workflow-toolkit:issues-sync --full --diff

Synced 47 issues (32 open, 15 closed)

New issues (3):
  #891 WebSocket connection drops after idle timeout
  #889 Dark mode toggle doesn't persist
  #887 Add bulk export for analytics

State changes (1):
  #845 OPEN -> CLOSED: Fix memory leak in event listener
```

```
> /workflow-toolkit:issues-list bugs

#    title                                      priority  status
---  -----------------------------------------  --------  -----------
891  WebSocket connection drops after idle       unset     new
889  Dark mode toggle doesn't persist            high      triaged
872  CSV export truncates at 1000 rows           medium    in-progress
```

```
> /workflow-toolkit:issues-triage 891 priority critical
> /workflow-toolkit:issues-triage 891 pick
> /workflow-toolkit:issues-triage 891 note Likely related to keep-alive config in nginx
```

The `github-issues` agent handles bulk operations — ask it to triage everything from the last sync, find duplicates, or correlate issues with files in the codebase.

**Strictly read-only.** Pulls data down, never posts or modifies anything on GitHub.

---

### 4. Checks Your Work Before You Push

Run pre-flight checks before pushing. Validates diff size, commit format, linting, types, and basic code quality.

```
> /workflow-toolkit:contribution-check

| Check         | Status | Notes                          |
|---------------|--------|--------------------------------|
| Diff size     | PASS   | 8 files, +187 -42 lines       |
| Commit format | PASS   | fix: handle timezone edge case |
| File naming   | PASS   |                                |
| Code quality  | WARN   | 1 potential issue found        |
| Lint          | PASS   |                                |
| Type check    | PASS   |                                |
| Tests         | WARN   | 2 files missing test coverage  |

Action Items:
- [ ] Add tests for src/utils/timezone.ts
- [ ] Review nested conditional at src/handlers/booking.ts:142
```

Auto-detects your project's linter and type checker. Works with any stack.

---

### 5. Drafts Your PRs

Generates a complete PR with title, body, and checklist — then **stops and waits for you**.

```
> /workflow-toolkit:pr-prepare 456

PR Ready for Review

Title: fix: resolve login redirect loop caused by missing session cookie
Base: main <- fix/login-redirect-loop

Body:
## What does this PR do?
Fixes the infinite redirect loop on login by ensuring the session cookie
is set before the redirect fires...

---

Next steps (requires your approval):
1. Push branch: git push -u origin fix/login-redirect-loop
2. Create PR: gh pr create --draft --title "..." --body "..."
```

Nothing gets pushed until you explicitly say "go ahead." If the project has a `.github/PULL_REQUEST_TEMPLATE.md`, it uses that template automatically.

---

### 6. Builds Your Knowledge Base

Turn implicit codebase knowledge into structured reference docs.

```
> /workflow-toolkit:distill-concept react-hooks
```

Searches the codebase, reads representative files, identifies patterns, and generates a structured doc at `knowledge-base/react-hooks.md` with real code snippets, actual file paths, conventions, and gotchas. Not generic best practices — patterns from *this* codebase.

---

### 7. Scaffolds More Extensions

Build new Claude Code skills and agents from within Claude Code.

```
> /workflow-toolkit:create-skill deploy-preview "Deploy a preview branch to staging"
> /workflow-toolkit:create-agent security-scanner "Scan for OWASP top 10 vulnerabilities"
```

Generates properly structured files with YAML frontmatter and best-practice patterns. The factory skill (`/workflow-toolkit:skill-and-agent-factory`) can create coordinated skill-agent pairs that work together.

---

## How It Works

```
Claude Code Lifecycle Events
        |
        v
  Hooks (bash scripts)           <- silent, automatic
        |
        v
  SQLite Database                <- .claude/journal/journal.db
        |
        v
  Skills (query & act)           <- you invoke these
  Markdown Files                 <- human-readable summaries
```

### What the Hooks Capture

| Hook | Fires when | Records |
|------|-----------|---------|
| `SessionStart` | Session begins | Session ID, start time |
| `Stop` | Each response completes | Prompt count increment |
| `PostToolUse` | Write/Edit/Bash used | Tool name, file path |
| `SubagentStop` | Subagent finishes | Subagent count |
| `PreCompact` | Context compaction | Compaction snapshot |
| `TaskCompleted` | Background task done | Task summary as journal entry |
| `SessionEnd` | Session closes | Full summary (SQLite + markdown) |

### Database Tables

| Table | What it stores |
|-------|---------------|
| `sessions` | Per-session metrics (prompts, tool uses, subagents, compactions) |
| `entries` | Journal entries — auto-generated and manual |
| `tool_usage` | Every tool invocation with file paths |
| `compaction_snapshots` | Context compaction events |
| `github_issues` | Synced issues with local triage metadata |
| `tasks` | Local tasks with status, priority, and timestamps |

All data lives at `$CLAUDE_PROJECT_DIR/.claude/journal/`. Per-project, local-only.

---

## All Skills

| Skill | What it does |
|-------|-------------|
| `journal-write` | Write a manual journal entry |
| `journal-read` | Query journal history (recent, search, by date) |
| `task-create` | Create a task with priority, tags, linked issue |
| `task-list` | List/filter tasks by status or priority |
| `task-view` | Full task details with TASK.md notes |
| `task-update` | Update any task field |
| `task-start` | Mark a task as in-progress |
| `task-done` | Mark a task as complete |
| `issues-sync` | Sync GitHub issues into local DB |
| `issues-list` | Filter/search synced issues |
| `issues-view` | Full issue details with local metadata |
| `issues-triage` | Set priority, status, or add notes |
| `distill-concept` | Generate knowledge base from codebase patterns |
| `contribution-check` | Pre-push validation checklist |
| `pr-prepare` | Draft a PR and stop for review |
| `create-skill` | Scaffold a new Claude Code skill |
| `create-agent` | Scaffold a new Claude Code agent |
| `skill-and-agent-factory` | Create coordinated skill + agent pairs |
| `db-viewer` | Open the SQLite database in a GUI |

All skills are invoked as `/workflow-toolkit:<skill-name>`.

## Agents

| Agent | Purpose |
|-------|---------|
| `contribution-guard` | Read-only code reviewer. Checks diffs against project rules. Never modifies anything. |
| `github-issues` | Issue research, bulk triage, and codebase correlation. |

---

## Plugin Structure

```
workflow-toolkit/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/                      # 19 skills (each a folder with SKILL.md)
├── agents/                      # 2 specialized agents
│   ├── contribution-guard.md
│   └── github-issues.md
├── hooks/                       # 8 lifecycle hooks
│   ├── hooks.json               # Hook configuration
│   ├── init-journal-db.sh       # Database schema & init
│   ├── session-start-hook.sh
│   ├── journal-hook.sh
│   ├── session-end-hook.sh
│   ├── pre-compact-hook.sh
│   ├── tool-use-hook.sh
│   ├── subagent-stop-hook.sh
│   └── task-completed-hook.sh
├── scripts/
│   └── sync-issues.js           # GitHub issue sync engine
└── README.md
```

---

## Prerequisites

| Dependency | What for | Install |
|------------|----------|---------|
| [Claude Code](https://claude.ai/code) v1.0.33+ | Everything | `npm i -g @anthropic-ai/claude-code` |
| `sqlite3` | Hooks & skills | Most systems have it. `brew install sqlite3` / `scoop install sqlite3` |
| `jq` | Hook JSON parsing | `brew install jq` / `scoop install jq` |
| `gh` | GitHub issue sync | `brew install gh` / `scoop install gh` + `gh auth login` |

---

## Safety

- **Never pushes code** or creates PRs without your explicit consent
- **Never posts to GitHub** — issue sync is strictly read-only
- **Never modifies files** during checks — read and report only
- **All data stays local** to the project directory
- **No telemetry, no network calls** except `gh` CLI when you manually sync issues

---

## Contributing

Contributions welcome. Fork it, improve it, open a PR.

---

## License

MIT

---

Built by [Doug Silkstone](https://contra.com/doug_silkstone)
