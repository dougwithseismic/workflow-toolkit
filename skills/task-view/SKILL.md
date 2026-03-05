---
name: task-view
description: View full details of a specific task by ID or slug, including its TASK.md contents.
argument-hint: <id or slug>
disable-model-invocation: true
---

# Task View Skill

Shows full details for a single task.

## Instructions

1. Parse `$ARGUMENTS` — accept either a numeric ID or a slug string.

2. Query the task from SQLite:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# If numeric
sqlite3 -header -column "$DB_PATH" "SELECT * FROM tasks WHERE id = <id>;"

# If slug
sqlite3 -header -column "$DB_PATH" "SELECT * FROM tasks WHERE slug = '<slug>';"
```

3. If the task has a `folder_path`, read the `TASK.md` file from that folder using the Read tool to show any working notes.

4. Display the task details in a formatted view:
   - ID, title, slug
   - Status, priority
   - Description
   - Tags
   - Linked GitHub issue (if any)
   - Created, updated, started, completed timestamps
   - Notes from SQLite
   - Contents of TASK.md (working notes section)

5. Show available actions:
   - `/workflow-toolkit:task-start <id>` — if status is todo
   - `/workflow-toolkit:task-done <id>` — if status is in-progress
   - `/workflow-toolkit:task-update <id> status blocked` — if stuck
   - `/workflow-toolkit:task-update <id> notes "..."` — to add notes

6. If the task is not found, show an error and suggest `/workflow-toolkit:task-list all`.
