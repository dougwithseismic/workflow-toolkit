---
name: task-update
description: Update a task's field (status, priority, tags, notes, description). Updates both SQLite and the task's TASK.md file.
argument-hint: <id or slug> <field> <value>
disable-model-invocation: true
---

# Task Update Skill

Updates a specific field on a task.

## Instructions

1. Parse `$ARGUMENTS`:
   - First arg: task ID (numeric) or slug (string)
   - Second arg: field name — one of: `status`, `priority`, `tags`, `notes`, `description`, `title`, `issue`
   - Remaining args: the new value

2. Validate the field and value:
   - `status`: must be one of `todo`, `in-progress`, `done`, `blocked`
   - `priority`: must be one of `critical`, `high`, `medium`, `low`
   - `tags`: comma-separated string, stored as JSON array
   - `notes`: free-form text (appended, not replaced)
   - `description`: free-form text (replaced)
   - `title`: new title string
   - `issue`: GitHub issue number or `none` to unlink

3. Update SQLite:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S')

# For status changes, also update started_at / completed_at
sqlite3 "$DB_PATH" "UPDATE tasks SET <field> = '<value>', updated_at = '$TIMESTAMP' WHERE id = <id>;"

# If status = 'in-progress', set started_at if null
sqlite3 "$DB_PATH" "UPDATE tasks SET started_at = '$TIMESTAMP' WHERE id = <id> AND started_at IS NULL AND status = 'in-progress';"

# If status = 'done', set completed_at
sqlite3 "$DB_PATH" "UPDATE tasks SET completed_at = '$TIMESTAMP' WHERE id = <id> AND status = 'done';"
```

4. If the task has a `folder_path`, also update the `TASK.md` frontmatter to reflect the change using the Edit tool.

5. For `notes`, append to the Notes section in TASK.md rather than replacing.

6. Confirm the update by showing the updated field value and timestamp.
