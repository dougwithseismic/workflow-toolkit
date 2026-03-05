---
name: help
description: Show usage information for any workflow-toolkit skill. Use when the user asks how to use a specific skill, what a skill does, or needs guidance on workflow-toolkit features. Also triggers on "help", "how do I", "what does X do", or "usage" in the context of workflow-toolkit skills.
argument-hint: [skill-name|all]
---

# Workflow Toolkit Help

Show usage information for the requested skill: **$ARGUMENTS**

If no argument is given or `$ARGUMENTS` is "all", show the full overview. If a specific skill name is given, show detailed help for that skill only.

## Overview

Workflow Toolkit is a non-opinionated workflow plugin. It journals sessions automatically, tracks tasks and GitHub issues locally, generates knowledge base docs from codebase patterns, and helps you ship clean contributions.

**You don't need to memorize slash commands.** Just describe what you want in natural language — "what did I work on yesterday?", "create a task for the auth bug", "sync the GitHub issues" — and the right skill will activate automatically.

---

## Skills Reference

### journal-write

**What it does:** Saves a manual journal entry to SQLite and a timestamped markdown file.

**When to use it:** When you want to capture a decision, a discovery, or context that future sessions should know about.

**Examples:**
- "Write a journal entry about the auth refactor"
- "Journal: decided to use repository pattern for data access"
- `/workflow-toolkit:journal-write Migrated user queries to new repository layer`

---

### journal-read

**What it does:** Queries journal entries from SQLite. Supports recent, search, date filtering, and count limits.

**When to use it:** When you're picking up where you left off, or need to recall what happened in past sessions.

**Examples:**
- "What did I work on yesterday?"
- "Show me my last 5 journal entries"
- "Search my journal for anything about authentication"
- `/workflow-toolkit:journal-read search auth`
- `/workflow-toolkit:journal-read last 5`
- `/workflow-toolkit:journal-read today`

---

### task-create

**What it does:** Creates a local task with optional priority, tags, description, and linked GitHub issue. Makes a SQLite row and a task folder with TASK.md.

**When to use it:** When you identify work that needs doing — bugs, features, chores, investigations.

**Examples:**
- "Create a task for fixing the login redirect bug, high priority, link it to issue 456"
- "Add a task: write onboarding docs, low priority, tag it docs"
- `/workflow-toolkit:task-create Fix login redirect --priority high --issue 456 --tags "auth,bug"`

**Flags:** `--priority <critical|high|medium|low>`, `--tags "comma,separated"`, `--issue <number>`, `--desc "description"`

---

### task-list

**What it does:** Lists tasks filtered by status, priority, or keyword search.

**When to use it:** When you want to see what's on your plate.

**Examples:**
- "What tasks do I have?"
- "Show me all high priority tasks"
- "List done tasks"
- `/workflow-toolkit:task-list` (shows active by default)
- `/workflow-toolkit:task-list all`
- `/workflow-toolkit:task-list priority high`

---

### task-view

**What it does:** Shows full details for a single task including its TASK.md working notes.

**When to use it:** When you need the full context on a specific task before starting work.

**Examples:**
- "Show me task 7"
- "What's the detail on the auth bug task?"
- `/workflow-toolkit:task-view 7`
- `/workflow-toolkit:task-view fix-login-redirect`

---

### task-update

**What it does:** Updates a single field on a task (status, priority, tags, notes, description, title, or linked issue).

**When to use it:** When you need to change something about a task that isn't just starting or finishing it.

**Examples:**
- "Change task 5 priority to critical"
- "Add a note to task 3: blocked on API team response"
- `/workflow-toolkit:task-update 5 priority critical`
- `/workflow-toolkit:task-update 3 notes Blocked on API team`

---

### task-start

**What it does:** Marks a task as in-progress and records the start time. Shortcut for updating status.

**When to use it:** When you begin working on a task.

**Examples:**
- "Start working on task 7"
- "I'm picking up the auth bug"
- `/workflow-toolkit:task-start 7`

---

### task-done

**What it does:** Marks a task as complete with timestamp. Optionally records a completion summary.

**When to use it:** When you finish a task.

**Examples:**
- "Task 7 is done, root cause was the missing session cookie"
- "Mark the auth bug as complete"
- `/workflow-toolkit:task-done 7 Fixed by setting cookie before redirect`

---

### issues-sync

**What it does:** Pulls GitHub issues from the current repo into the local SQLite database via `gh` CLI. Supports open, closed, filtered, and diff modes.

**When to use it:** When you want to pull down the latest issues for offline triage. Requires `gh` CLI.

**Examples:**
- "Sync the GitHub issues"
- "Pull down all issues including closed ones and show me what changed"
- `/workflow-toolkit:issues-sync`
- `/workflow-toolkit:issues-sync --full --diff`
- `/workflow-toolkit:issues-sync --label "bug"`

**Flags:** `--full` (open + closed), `--diff` (show changes), `--prune` (clean resolved), `--label "x"`, `--limit N`

---

### issues-list

**What it does:** Filters and displays synced GitHub issues from the local database.

**When to use it:** When you want to browse issues without leaving the terminal.

**Examples:**
- "Show me open bugs"
- "What issues are still untriaged?"
- "Search issues for websocket"
- `/workflow-toolkit:issues-list bugs`
- `/workflow-toolkit:issues-list new`
- `/workflow-toolkit:issues-list search websocket`
- `/workflow-toolkit:issues-list priority critical`

---

### issues-view

**What it does:** Shows full details for a single GitHub issue including body, labels, and local triage metadata.

**When to use it:** When you need the full context on an issue before investigating or picking it up.

**Examples:**
- "Show me issue 891"
- "What's the detail on the websocket bug?"
- `/workflow-toolkit:issues-view 891`
- `/workflow-toolkit:issues-view 891 --refresh` (fetches fresh data from GitHub)

---

### issues-triage

**What it does:** Updates local tracking metadata on a synced issue — priority, status, or notes. Never modifies anything on GitHub.

**When to use it:** When you want to prioritize, pick up, ignore, or annotate an issue locally.

**Examples:**
- "Set issue 891 to critical priority"
- "Pick up issue 891"
- "Ignore issue 850, it's a duplicate"
- "Add a note to issue 891: probably related to nginx config"
- `/workflow-toolkit:issues-triage 891 priority critical`
- `/workflow-toolkit:issues-triage 891 pick`
- `/workflow-toolkit:issues-triage 850 ignore`
- `/workflow-toolkit:issues-triage 891 note Related to nginx keep-alive config`

---

### distill-concept

**What it does:** Analyzes how a concept is used across the codebase and generates a structured knowledge base entry with real file paths, code snippets, conventions, and gotchas.

**When to use it:** When you want to understand how something works in this specific project — not generic best practices, but actual patterns from the code. Great for onboarding, building shared understanding, or documenting tribal knowledge.

**Examples:**
- "Distill how React hooks are used in this project"
- "Generate a knowledge base entry for the auth flow"
- "Document the testing patterns in this codebase"
- `/workflow-toolkit:distill-concept react-hooks`
- `/workflow-toolkit:distill-concept api-routers`
- `/workflow-toolkit:distill-concept error-handling`

**Output:** Writes to `knowledge-base/<concept-name>.md`. Uses a template with sections for key locations, patterns, conventions, dependencies, and gotchas.

**Pro tip:** Do this for 5-6 core concepts on day one of a new codebase. Within an hour you've got a reference that any future session can use to write consistent code.

---

### contribution-check

**What it does:** Pre-flight validation of your changes before pushing. Checks diff size, commit format, file naming, code quality, linting, type checking, and test coverage. Auto-detects your project's tooling.

**When to use it:** Before pushing a branch or opening a PR. Catches common issues early.

**Examples:**
- "Check my changes before I push"
- "Run the contribution checks"
- "Validate my work"
- `/workflow-toolkit:contribution-check`
- `/workflow-toolkit:contribution-check --skip-lint`

**Important:** This is read-only. It never pushes code, creates PRs, or modifies anything.

---

### pr-prepare

**What it does:** Generates a complete PR title, body, and checklist, then stops and presents it for your review. Uses the project's PR template if one exists.

**When to use it:** When you're ready to open a PR and want a well-formatted draft.

**Examples:**
- "Prepare a PR for issue 456"
- "Draft a PR for my current changes"
- `/workflow-toolkit:pr-prepare 456`
- `/workflow-toolkit:pr-prepare`

**Important:** This stops after showing the draft. Nothing gets pushed until you explicitly say "go ahead."

---

### create-skill

**What it does:** Scaffolds a new Claude Code skill with proper YAML frontmatter, argument handling, and best-practice structure.

**When to use it:** When you want to create a reusable workflow or command specific to your project.

**Examples:**
- "Create a skill for deploying preview branches"
- "Make a new skill called run-migrations that handles database migrations"
- `/workflow-toolkit:create-skill deploy-preview "Deploy a preview branch to staging"`

---

### create-agent

**What it does:** Scaffolds a new Claude Code subagent with model selection, tool permissions, and system prompt.

**When to use it:** When you need an isolated agent with specific capabilities — code review, security scanning, research, etc.

**Examples:**
- "Create an agent for security scanning"
- "Make a code review agent that uses sonnet"
- `/workflow-toolkit:create-agent security-scanner "Scan for OWASP top 10 vulnerabilities"`

---

### skill-and-agent-factory

**What it does:** Creates skills, agents, or coordinated pairs. Determines the right architecture (skill-only, agent-only, or both working together) based on the use case.

**When to use it:** When you're not sure whether you need a skill or an agent, or when you need both working together.

**Examples:**
- "Build a code review extension with a quick mode and a thorough mode"
- `/workflow-toolkit:skill-and-agent-factory both code-review "Quick inline + deep isolated analysis"`

---

### db-viewer

**What it does:** Opens the journal SQLite database in a GUI viewer (DB Browser for SQLite or similar).

**When to use it:** When you want to browse the raw data, run custom queries, or inspect the schema.

**Examples:**
- "Open the database"
- "Show me the journal DB in a viewer"
- `/workflow-toolkit:db-viewer`
