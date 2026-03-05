---
name: task-start
description: Mark a task as in-progress. Shortcut for /task-update <id> status in-progress.
argument-hint: <id or slug>
disable-model-invocation: true
---

# Task Start Skill

Marks a task as in-progress and records the start time.

## Instructions

1. Parse `$ARGUMENTS` — accept a numeric ID or slug.

2. Look up the task in SQLite to verify it exists and get its current status:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

sqlite3 -header -column "$DB_PATH" "SELECT id, slug, title, status, priority FROM tasks WHERE id = <id> OR slug = '<slug>';"
```

3. If the task is already `in-progress`, inform the user it's already started.

4. If the task is `done`, warn that it's already completed and ask if they want to reopen it.

5. Update the task:

```bash
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S')

sqlite3 "$DB_PATH" "UPDATE tasks SET status = 'in-progress', started_at = COALESCE(started_at, '$TIMESTAMP'), updated_at = '$TIMESTAMP' WHERE id = <id>;"
```

6. Update the TASK.md file in the task folder — change `**Status:** todo` to `**Status:** in-progress` and add a `**Started:** <timestamp>` line using the Edit tool.

7. Confirm with a message like:
   - "Started task #3: Fix booking flow (priority: high)"
   - Show the task folder path for adding working notes
