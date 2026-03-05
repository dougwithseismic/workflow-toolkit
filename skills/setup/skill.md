---
name: setup
description: Initialize and verify the workflow-toolkit environment. Checks SQLite availability, creates the journal database, verifies directory structure, checks gh CLI auth, and reports readiness. Run this after installing the plugin or when troubleshooting.
argument-hint: [--force]
disable-model-invocation: true
---

# Workflow Toolkit Setup

Verify and initialize the workflow-toolkit environment for the current project.

## Instructions

Run the following checks **in order**. Report each as PASS, FAIL, or SKIP. At the end, show a summary.

If `$ARGUMENTS` contains `--force`, re-initialize the database even if it already exists.

### 1. Check SQLite availability

```bash
sqlite3 --version
```

If this fails, report FAIL and stop — SQLite is required for all features.

### 2. Check project directory

```bash
echo "Project dir: $CLAUDE_PROJECT_DIR"
test -d "$CLAUDE_PROJECT_DIR" && echo "EXISTS" || echo "MISSING"
```

If `$CLAUDE_PROJECT_DIR` is empty or doesn't exist, report FAIL and stop.

### 3. Create directory structure

```bash
mkdir -p "$CLAUDE_PROJECT_DIR/.claude/journal/entries"
mkdir -p "$CLAUDE_PROJECT_DIR/.claude/tasks"
```

Report PASS when directories are created or already exist.

### 4. Initialize the journal database

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
```

- If the database already exists and `--force` was NOT passed, report PASS (already initialized) and show table count:
  ```bash
  sqlite3 "$DB_PATH" "SELECT count(*) FROM sqlite_master WHERE type='table';"
  ```
- If the database does not exist OR `--force` was passed, run the init script:
  ```bash
  bash "${CLAUDE_PLUGIN_ROOT}/hooks/init-journal-db.sh"
  ```
  Then verify tables were created:
  ```bash
  sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
  ```
  Expected tables: `compaction_snapshots`, `entries`, `github_issues`, `sessions`, `tasks`, `tool_usage`

### 5. Verify database schema

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
```

Check all 6 tables exist: `compaction_snapshots`, `entries`, `github_issues`, `sessions`, `tasks`, `tool_usage`. Report PASS if all present, WARN if some missing.

### 6. Check .gitignore

Check if `.claude/journal/journal.db` or `.claude/` is in the project's `.gitignore`:

```bash
grep -q "\.claude" "$CLAUDE_PROJECT_DIR/.gitignore" 2>/dev/null && echo "COVERED" || echo "NOT COVERED"
```

If not covered, report WARN and suggest adding `.claude/journal/` to `.gitignore` to avoid committing the database.

### 7. Check gh CLI (optional)

```bash
gh --version 2>/dev/null
```

If `gh` is not installed, report SKIP — GitHub issue features won't work but everything else will.

If installed, check auth:

```bash
gh auth status 2>&1
```

Report PASS if authenticated, WARN if not (with suggestion to run `gh auth login`).

### 8. Check Node.js (optional)

```bash
node --version 2>/dev/null
```

If not installed, report SKIP — issue sync uses Node.js but it's not required for core features.

## Summary

After all checks, show a formatted summary:

```
Workflow Toolkit Setup
======================
SQLite:          PASS (version X.X.X)
Project dir:     PASS
Directory setup: PASS
Journal DB:      PASS (6 tables, initialized)
Schema:          PASS (all tables present)
.gitignore:      PASS | WARN
gh CLI:          PASS | SKIP | WARN
Node.js:         PASS | SKIP

Status: Ready to use | Action required
```

If everything is PASS or SKIP, show: "Setup complete. Run `/workflow-toolkit:help` for usage guide."

If any FAIL, show what needs to be fixed before the plugin will work.
