---
name: task-done
description: Mark a task as done. Records completion time. Shortcut for /task-update <id> status done.
argument-hint: <id or slug> [summary of what was done]
disable-model-invocation: true
---

# Task Done Skill

Marks a task as completed and records the completion time.

## Instructions

1. Parse `$ARGUMENTS`:
   - First arg: task ID (numeric) or slug
   - Remaining args (optional): completion summary

2. Look up the task in SQLite:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

sqlite3 -header -column "$DB_PATH" "SELECT id, slug, title, status, priority, started_at FROM tasks WHERE id = <id> OR slug = '<slug>';"
```

3. If the task is already `done`, inform the user.

4. If the task was never started (status is `todo`), set both `started_at` and `completed_at`.

5. Update the task:

```bash
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S')

sqlite3 "$DB_PATH" "UPDATE tasks SET status = 'done', started_at = COALESCE(started_at, '$TIMESTAMP'), completed_at = '$TIMESTAMP', updated_at = '$TIMESTAMP' WHERE id = <id>;"
```

6. If a completion summary was provided, append it to the notes:

```bash
sqlite3 "$DB_PATH" "UPDATE tasks SET notes = COALESCE(notes || char(10), '') || 'Completed: <summary>' WHERE id = <id>;"
```

7. Update the TASK.md file — change status to done, add completed timestamp using the Edit tool.

8. Confirm with:
   - "Completed task #3: Fix booking flow"
   - Show duration if started_at was set (e.g., "Duration: 2h 15m")
   - Suggest `/workflow-toolkit:task-list` to see remaining work
