# Workflow Toolkit

**Get up to speed in any codebase, any size.**

A non-opinionated workflow plugin for [Claude Code](https://claude.ai/code) that keeps track of what you're working on and what you need to do next. Session journaling, local task tracking, GitHub issue sync, knowledge base generation, and a handful of lifecycle hooks — all backed by a local SQLite database. Nothing leaves your machine.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet)](https://claude.ai/code)

Built by [Doug Silkstone](https://contra.com/doug_silkstone)

---

## The Problem

You drop into an unfamiliar codebase — maybe it's a monorepo with 200 packages, maybe it's a legacy app with zero documentation. You start exploring, fixing bugs, shipping features. A few sessions later you can't remember what you changed on Tuesday, which issue you were investigating, or what you decided to do next.

Claude Code sessions are ephemeral. Context disappears when the terminal closes. There's no trail of what happened, no way to pick up where you left off, and no structure to keep things moving forward. Multiply that across a team and it gets messy fast.

**Workflow Toolkit gives you that structure** — without imposing opinions about how you work. It sits in the background, records what's happening, and gives you tools to query it, act on it, and build on it.

---

## Why SQLite and Not Just Markdown?

Markdown files are great for reading. They're terrible for querying.

When you need to answer "what did I work on last week?", "which issues are still untriaged?", or "how many tool calls did that refactor take?" — you need structured data. SQLite gives you that. You can filter tasks by priority, search journal entries by keyword, aggregate session stats, and join issues to tasks — all with simple queries.

But we still write markdown too. Every session summary, every task, every journal entry also gets a human-readable `.md` file. You get the best of both: queryable data for Claude, browsable files for you.

The database auto-initializes on your first session. One file at `.claude/journal/journal.db`. No server, no config, no dependencies beyond `sqlite3`.

---

## Quick Start

### Install Claude Code

```bash
# Native installer (recommended — auto-updates, no Node.js required)
curl -fsSL https://claude.ai/install.sh | bash

# Or via npm (requires Node.js 18+)
npm install -g @anthropic-ai/claude-code
```

### Install the Plugin

```bash
# From inside Claude Code
/plugin marketplace add dougwithseismic/workflow-toolkit
/plugin install workflow-toolkit@dougwithseismic
```

Or clone and load directly:

```bash
git clone https://github.com/dougwithseismic/workflow-toolkit.git
claude --plugin-dir ./workflow-toolkit
```

The database initializes automatically on your first session. No config files to edit, no setup steps.

---

## How to Wrangle a Codebase

Here's the workflow. You land in a new project — could be 10 files, could be 10,000. Here's how to start making sense of it and writing consistent code that matches the existing patterns.

### Step 1: Let It Journal

Just start working. The hooks run silently in the background:

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

Every session gets a timestamped markdown file at `.claude/journal/entries/`. Come back next week and run `/workflow-toolkit:journal-read last 5` — instant context on where you left off.

Capture decisions as you make them:

```
> /workflow-toolkit:journal-write Decided to use repository pattern — matches existing UserRepository and OrderRepository
```

### Step 2: Distill What You Learn

This is where it gets powerful. As you explore the codebase, distill the patterns you find:

```
> /workflow-toolkit:distill-concept react-hooks
```

This doesn't just describe what React hooks are — it searches *this specific codebase*, reads real files, and generates a structured knowledge base entry at `knowledge-base/react-hooks.md`:

```markdown
# React Hooks

> Custom hooks for data fetching, authentication, and UI state management.

## Key Locations

| Path                              | Purpose                              |
|-----------------------------------|--------------------------------------|
| `packages/lib/hooks/`             | Shared utility hooks                 |
| `packages/features/bookings/hooks/` | Domain-specific booking hooks      |
| `apps/web/hooks/`                 | App-level hooks                      |

## Patterns

### Data Fetching Hook

Where: `packages/lib/hooks/useFetch.ts:14`

How it works:
Wraps tRPC queries with loading/error state...

Example:
// packages/lib/hooks/useFetch.ts:14
export function useFetch<T>(queryKey: string) { ... }

## Conventions
- All hooks prefixed with `use`
- Domain hooks live in their feature package, not in shared lib
- Never call hooks conditionally (enforced by eslint rule)

## Gotchas
- `useBookingForm` has a hidden dependency on `BookingContext` — will throw if used outside the provider
```

Real code. Real file paths. Real conventions from *this* project, not generic best practices you'd find in a blog post.

**Do this for every major concept as you encounter it:**

```
> /workflow-toolkit:distill-concept api-routers
> /workflow-toolkit:distill-concept database-schema
> /workflow-toolkit:distill-concept auth-flow
> /workflow-toolkit:distill-concept testing-patterns
> /workflow-toolkit:distill-concept error-handling
```

Within a day you've got a `knowledge-base/` folder that any team member (or Claude Code session) can reference to write code that *matches the existing patterns*. No more guessing how things are done in this project.

### Step 3: Track What Needs Doing

Sync the issues from GitHub so you can see the full picture locally:

```
> /workflow-toolkit:issues-sync --full --diff

Synced 47 issues (32 open, 15 closed)

New issues (3):
  #891 WebSocket connection drops after idle timeout
  #889 Dark mode toggle doesn't persist
  #887 Add bulk export for analytics
```

Triage them without leaving the terminal:

```
> /workflow-toolkit:issues-triage 891 priority critical
> /workflow-toolkit:issues-triage 891 pick
> /workflow-toolkit:issues-triage 891 note Likely related to keep-alive config in nginx
```

Create local tasks for your own work:

```
> /workflow-toolkit:task-create Fix login redirect loop --priority high --tags "auth,bug" --issue 456

Created task #7: Fix login redirect loop
  Priority: high | Tags: auth, bug | Issue: #456
  Folder: .claude/tasks/fix-login-redirect-loop/
```

Move them through the lifecycle:

```
> /workflow-toolkit:task-start 7
Started task #7: Fix login redirect loop (priority: high)

> /workflow-toolkit:task-done 7 Root cause was missing session cookie on redirect
Completed task #7: Fix login redirect loop
Duration: 1h 23m
```

See what's active:

```
> /workflow-toolkit:task-list

id  title                        status       priority  issue  created_at
--  ---------------------------  -----------  --------  -----  -------------------
 5  Add rate limiting to API     in-progress  medium    #412   2026-03-04 09:00:00
 3  Write onboarding docs        todo         low              2026-03-03 11:00:00

2 active tasks (1 in-progress, 1 todo)
```

Each task gets its own folder at `.claude/tasks/<slug>/TASK.md` for reproduction steps, working notes, or anything else you want to persist.

### Step 4: Ship It

Check your work before pushing:

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

Auto-detects your project's linter and type checker — works with ESLint, Biome, Prettier, tsc, pyright, whatever.

Draft the PR:

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

It **stops here**. Nothing gets pushed until you explicitly say "go ahead." If the project has a `.github/PULL_REQUEST_TEMPLATE.md`, it uses that template automatically.

### Step 5: Extend the Workflow

Build new skills and agents as you discover needs specific to the project:

```
> /workflow-toolkit:create-skill deploy-preview "Deploy a preview branch to staging"
```

This scaffolds a properly structured `SKILL.md` with YAML frontmatter, argument handling, step-by-step instructions, and validation. It follows Claude Code's plugin conventions so the skill just works.

```
> /workflow-toolkit:create-agent security-scanner "Scan code for OWASP top 10 vulnerabilities"
```

Agents get their own model selection, tool permissions, and system prompts. The scaffolder walks you through the design decisions.

Need both? The factory creates coordinated pairs:

```
> /workflow-toolkit:skill-and-agent-factory both code-review "Quick inline review + thorough isolated analysis"
```

This creates a skill for fast in-context checks and an agent for deep isolated analysis — wired together so the skill can delegate to the agent when you need the thorough version.

---

## GitHub Issue Tracking

This requires the [GitHub CLI](https://cli.github.com/) (`gh`). Install it and authenticate:

```bash
# macOS
brew install gh

# Windows
scoop install gh

# Linux
sudo apt install gh

# Then authenticate
gh auth login
```

Once `gh` is set up, issues sync from whatever repo your current directory belongs to:

```
> /workflow-toolkit:issues-sync --full --diff
```

**This is strictly read-only.** The plugin pulls issue data down into your local database. It never posts comments, creates issues, modifies labels, or touches anything on GitHub. Your triage metadata (priority, status, notes) stays entirely local.

The `github-issues` agent can handle bulk operations:

```
> @github-issues Triage all new issues from the last sync. Categorize by severity and suggest priorities.
```

It reads issue bodies, correlates them with files in the codebase using Grep and Glob, and presents a structured triage report.

---

## Architecture

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
| `SessionStart` | Session begins | Session ID, start time. Auto-creates DB if missing. |
| `Stop` | Each response completes | Prompt count increment |
| `PostToolUse` | Write/Edit/Bash used | Tool name, file path |
| `SubagentStop` | Subagent finishes | Subagent count |
| `PreCompact` | Context compaction | Compaction snapshot |
| `TaskCompleted` | Background task done | Task summary as journal entry |
| `SessionEnd` | Session closes | Full summary (SQLite + markdown file) |

### Database Tables

Six tables in one SQLite file:

| Table | What it stores |
|-------|---------------|
| `sessions` | Per-session metrics (prompts, tool uses, subagents, compactions) |
| `entries` | Journal entries — auto-generated and manual |
| `tool_usage` | Every tool invocation with file paths |
| `compaction_snapshots` | Context compaction events |
| `github_issues` | Synced issues with local triage metadata (priority, status, notes) |
| `tasks` | Local tasks with status, priority, tags, linked issues, timestamps |

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
| `distill-concept` | Generate knowledge base entry from codebase patterns |
| `contribution-check` | Pre-push validation checklist |
| `pr-prepare` | Draft a PR and stop for review |
| `create-skill` | Scaffold a new Claude Code skill |
| `create-agent` | Scaffold a new Claude Code agent |
| `skill-and-agent-factory` | Create coordinated skill + agent pairs |
| `db-viewer` | Open the SQLite database in a GUI |

All invoked as `/workflow-toolkit:<skill-name>`.

## Agents

| Agent | Purpose |
|-------|---------|
| `contribution-guard` | Read-only code reviewer. Checks diffs against project rules. Never modifies anything. |
| `github-issues` | Issue research, bulk triage, and codebase correlation via `gh` CLI. |

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
├── hooks/                       # 8 lifecycle hooks + config
│   ├── hooks.json
│   ├── init-journal-db.sh       # Full database schema
│   ├── session-start-hook.sh
│   ├── journal-hook.sh
│   ├── session-end-hook.sh
│   ├── pre-compact-hook.sh
│   ├── tool-use-hook.sh
│   ├── subagent-stop-hook.sh
│   └── task-completed-hook.sh
├── scripts/
│   └── sync-issues.js           # GitHub issue sync engine (Node.js)
└── README.md
```

---

## Prerequisites

| Dependency | What for | Install |
|------------|----------|---------|
| [Claude Code](https://claude.ai/code) | Everything | `curl -fsSL https://claude.ai/install.sh \| bash` |
| `sqlite3` | Hooks & skills | Most systems have it. `brew install sqlite3` / `scoop install sqlite3` |
| `jq` | Hook JSON parsing | `brew install jq` / `scoop install jq` |
| [`gh`](https://cli.github.com/) | GitHub issue sync (optional) | `brew install gh` / `scoop install gh` + `gh auth login` |

---

## Safety

- **Never pushes code** or creates PRs without your explicit consent
- **Never posts to GitHub** — issue sync is strictly read-only
- **Never modifies files** during contribution checks — read and report only
- **All data stays local** to the project directory
- **No telemetry, no network calls** except `gh` CLI when you manually trigger an issue sync

---

## Contributing

Contributions welcome. Fork it, improve it, open a PR.

If you build something on top of this or extend it for your team's workflow, I'd love to hear about it.

---

## License

Apache 2.0

---

Built by [Doug Silkstone](https://contra.com/doug_silkstone)
