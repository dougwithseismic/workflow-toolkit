# Workflow Toolkit

**A structured development workflow plugin for [Claude Code](https://claude.ai/code).**

Session journaling. Task tracking. GitHub issue triage. Contribution checks. PR preparation. Knowledge base generation. All backed by SQLite, all running locally, all from your terminal.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v1.0.33+-blueviolet)](https://claude.ai/code)

Built by [Doug Silkstone](https://contra.com/doug_silkstone)

---

## Why This Exists

Claude Code is powerful, but sessions are ephemeral. You lose context when you close the terminal. You can't see what you did yesterday. You can't track what's in progress across sessions.

**Workflow Toolkit fixes that.** It hooks into Claude Code's lifecycle events and silently records everything to a local SQLite database. Then it gives you skills to query, manage, and act on that data.

The result: a structured, observable, repeatable development workflow that persists across sessions.

---

## Quick Start

```bash
# Install from GitHub
/plugin marketplace add dougwithseismic/workflow-toolkit
/plugin install workflow-toolkit@dougwithseismic

# Or load directly for testing
claude --plugin-dir /path/to/workflow-toolkit
```

That's it. The database initializes automatically on your first session.

---

## What You Get

### Session Journaling (automatic)

Every session is tracked automatically via lifecycle hooks. No action required from you.

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
Edit (52x)
Read (41x)
Bash (38x)
Grep (27x)
Glob (25x)
```

Each session also gets a timestamped markdown file at `.claude/journal/entries/` for human-readable browsing.

**Write manual entries when you want to capture context:**

```
> /workflow-toolkit:journal-write Refactored the auth module to use repository pattern
```

```
> /workflow-toolkit:journal-read search auth

id  timestamp            type    summary
--  -------------------  ------  ----------------------------------------
14  2026-03-05 15:30:00  manual  Refactored auth module to repository pattern
 9  2026-03-04 10:15:00  auto    Updated auth middleware error handling
```

---

### Task Tracking

Local task management that lives alongside your code. SQLite for querying, markdown files for notes.

**Create a task:**
```
> /workflow-toolkit:task-create Fix login redirect loop --priority high --tags "auth,bug" --issue 456
```
```
Created task #7: Fix login redirect loop
  Priority: high
  Tags: auth, bug
  Issue: #456
  Folder: .claude/tasks/fix-login-redirect-loop/
```

**Track progress:**
```
> /workflow-toolkit:task-start 7

Started task #7: Fix login redirect loop (priority: high)

> /workflow-toolkit:task-done 7 Traced to missing session cookie on redirect

Completed task #7: Fix login redirect loop
Duration: 1h 23m
```

**See what's active:**
```
> /workflow-toolkit:task-list

id  title                        status       priority  tags        issue  created_at
--  ---------------------------  -----------  --------  ----------  -----  -------------------
 7  Fix login redirect loop      done         high      auth,bug    #456   2026-03-05 14:00:00
 5  Add rate limiting to API     in-progress  medium    api         #412   2026-03-04 09:00:00
 3  Write onboarding docs        todo         low       docs               2026-03-03 11:00:00

2 active tasks (1 in-progress, 1 todo)
```

Each task gets its own folder at `.claude/tasks/<slug>/TASK.md` where you can keep working notes, reproduction steps, or anything else.

---

### GitHub Issue Tracking

Sync issues from any GitHub repo into your local database. Triage offline. Never posts anything back to GitHub.

**Sync issues:**
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

**Filter and search:**
```
> /workflow-toolkit:issues-list bugs

#    title                                      labels       priority  status
---  -----------------------------------------  -----------  --------  ------
891  WebSocket connection drops after idle       bug          unset     new
889  Dark mode toggle doesn't persist            bug,ui       high      triaged
872  CSV export truncates at 1000 rows           bug,data     medium    in-progress
```

**Triage locally:**
```
> /workflow-toolkit:issues-triage 891 priority critical
> /workflow-toolkit:issues-triage 891 pick
> /workflow-toolkit:issues-triage 891 note Likely related to keep-alive config in nginx
```

**Investigate with the agent:**

The `github-issues` agent can handle bulk operations:
```
> @github-issues Triage all new issues from the last sync. Categorize by severity and suggest priorities.
```

---

### Contribution Workflow

Pre-flight checks before you push. PR drafting that stops for your review.

**Run contribution checks:**
```
> /workflow-toolkit:contribution-check

## Contribution Check Results

| Check                  | Status | Notes                          |
|------------------------|--------|--------------------------------|
| Diff size              | PASS   | 8 files, +187 -42 lines       |
| Commit format          | PASS   | fix: handle timezone edge case |
| File naming            | PASS   |                                |
| Code quality           | WARN   | 1 potential issue found        |
| Lint                   | PASS   |                                |
| Type check             | PASS   |                                |
| Tests                  | WARN   | 2 files missing test coverage  |

### Action Items
- [ ] Add tests for src/utils/timezone.ts
- [ ] Review nested conditional at src/handlers/booking.ts:142
```

**Prepare a PR:**
```
> /workflow-toolkit:pr-prepare 456

## PR Ready for Review

Title: fix: resolve login redirect loop caused by missing session cookie

Base: main <- fix/login-redirect-loop

Body:
## What does this PR do?
Fixes the infinite redirect loop on login by ensuring the session cookie
is set before the redirect fires...

---

### Next steps (requires your approval):
1. Push branch: `git push -u origin fix/login-redirect-loop`
2. Create PR: `gh pr create --draft --title "..." --body "..."`
```

It **stops here**. Nothing gets pushed until you explicitly say "go ahead."

---

### Knowledge Base Generation

Turn implicit codebase knowledge into structured reference docs.

```
> /workflow-toolkit:distill-concept react-hooks
```

Analyzes the codebase, finds real patterns across multiple files, and generates a structured markdown doc at `knowledge-base/react-hooks.md` with actual code snippets, file paths, conventions, and gotchas.

---

### Skill & Agent Scaffolding

Build more Claude Code extensions from within Claude Code.

```
> /workflow-toolkit:create-skill deploy-preview "Deploy a preview branch to staging"
> /workflow-toolkit:create-agent security-scanner "Scan code for OWASP top 10 vulnerabilities"
> /workflow-toolkit:skill-and-agent-factory both code-review "Quick inline review + thorough isolated analysis"
```

Each generates properly structured files with YAML frontmatter, best-practice patterns, and validation.

---

## Architecture

### How Data Flows

```
Claude Code Lifecycle Events
        |
        v
  Hooks (bash scripts)
        |
        v
  SQLite Database (.claude/journal/journal.db)
        |
        v
  Skills (query & display)    Markdown Files (human-readable)
```

### What the Hooks Capture

| Hook | Event | What it records |
|------|-------|-----------------|
| `SessionStart` | New session begins | Session ID, start time |
| `Stop` | Each response completes | Prompt count increment |
| `PostToolUse` | Any Write/Edit/Bash call | Tool name, file path |
| `SubagentStop` | Subagent finishes | Subagent count increment |
| `PreCompact` | Context window compaction | Compaction snapshot |
| `TaskCompleted` | Background task finishes | Task summary as journal entry |
| `SessionEnd` | Session closes | End time, reason, full summary markdown |

### Database Schema

Six tables in a single SQLite file:

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `sessions` | Per-session metrics | prompts, tool uses, subagents, compactions |
| `entries` | Journal entries (auto + manual) | timestamp, type, summary, details |
| `tool_usage` | Every tool invocation | tool name, file path, session |
| `compaction_snapshots` | Context compaction events | trigger type, session |
| `github_issues` | Synced GitHub issues + local triage | state, labels, priority, tracking status, notes |
| `tasks` | Local task tracking | status, priority, tags, linked issue, timestamps |

### Data Storage

All data is stored **per-project** at `$CLAUDE_PROJECT_DIR/.claude/journal/`. Nothing leaves your machine. Nothing is shared unless you commit the journal folder (which you probably shouldn't).

The database auto-initializes on first `SessionStart`. No setup required.

---

## Plugin Structure

```
workflow-toolkit/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/                      # 17 skills
│   ├── journal-write/           # Write manual journal entries
│   ├── journal-read/            # Query journal history
│   ├── task-create/             # Create tracked tasks
│   ├── task-list/               # List/filter tasks
│   ├── task-view/               # Full task details
│   ├── task-update/             # Update task fields
│   ├── task-start/              # Mark task in-progress
│   ├── task-done/               # Mark task complete
│   ├── issues-sync/             # Sync GitHub issues locally
│   ├── issues-list/             # Filter/search issues
│   ├── issues-view/             # Full issue details
│   ├── issues-triage/           # Set priority/status/notes
│   ├── distill-concept/         # Generate knowledge base entries
│   ├── create-skill/            # Scaffold new skills
│   ├── create-agent/            # Scaffold new agents
│   ├── skill-and-agent-factory/ # Unified extension factory
│   ├── contribution-check/      # Pre-push validation
│   ├── pr-prepare/              # Draft PRs for review
│   └── db-viewer/               # Open DB in GUI viewer
├── agents/                      # 2 specialized agents
│   ├── contribution-guard.md    # Read-only code reviewer
│   └── github-issues.md         # Issue research & bulk ops
├── hooks/                       # 8 lifecycle hooks
│   ├── hooks.json               # Hook configuration
│   ├── init-journal-db.sh       # Database schema & init
│   ├── session-start-hook.sh    # Record session start
│   ├── journal-hook.sh          # Increment prompt count
│   ├── session-end-hook.sh      # Write session summary
│   ├── pre-compact-hook.sh      # Record compaction
│   ├── tool-use-hook.sh         # Log tool invocations
│   ├── subagent-stop-hook.sh    # Track subagent usage
│   └── task-completed-hook.sh   # Record task completions
├── scripts/
│   └── sync-issues.js           # GitHub issue sync engine
├── .gitignore
└── README.md
```

---

## Prerequisites

| Dependency | Required for | Install |
|------------|-------------|---------|
| [Claude Code](https://claude.ai/code) v1.0.33+ | Everything | `npm i -g @anthropic-ai/claude-code` |
| `sqlite3` | Hooks, skills | Most systems have it. `brew install sqlite3` / `scoop install sqlite3` |
| `jq` | Hook JSON parsing | `brew install jq` / `scoop install jq` |
| `gh` | GitHub issue features | `brew install gh` / `scoop install gh`, then `gh auth login` |

---

## Safety Guarantees

This plugin is designed to be safe by default:

- **Never pushes code** or creates PRs without your explicit consent
- **Never posts to GitHub** — issue tracking is strictly read-only (pull only)
- **Never modifies your files** during contribution checks — read and report only
- **All data stays local** to your project directory
- **No network calls** except `gh` CLI for issue sync (which you trigger manually)
- **No secrets or credentials** are stored or transmitted

---

## Contributing

Contributions welcome. Fork it, make your changes, open a PR.

If you build something cool with this plugin, I'd love to hear about it.

---

## License

MIT

---

Built by [Doug Silkstone](https://contra.com/doug_silkstone)
