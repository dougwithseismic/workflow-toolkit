---
name: task-create
description: Create a new task with a title and optional description, priority, tags, and linked GitHub issue. Creates a task folder and inserts into SQLite.
argument-hint: <title> [--desc "description"] [--priority high] [--issue 123] [--tags "tag1,tag2"]
disable-model-invocation: true
---

# Task Create Skill

Creates a new local task for tracking work.

## Instructions

1. Parse `$ARGUMENTS`:
   - The first unquoted/unflagged text is the **title** (required)
   - `--desc "..."` — optional description
   - `--priority <level>` — critical, high, medium, low (default: medium)
   - `--issue <number>` — optional GitHub issue number to link
   - `--tags "tag1,tag2"` — optional comma-separated tags

2. Generate a slug from the title: lowercase, replace spaces/special chars with hyphens, truncate to 50 chars. Example: "Fix booking flow" -> "fix-booking-flow"

3. Create the task folder:

```bash
SLUG="<generated-slug>"
TASK_DIR="$CLAUDE_PROJECT_DIR/.claude/tasks/$SLUG"
mkdir -p "$TASK_DIR"
```

4. Create a `TASK.md` in the folder with the task details:

```markdown
# <Title>

**Status:** todo
**Priority:** <priority>
**Created:** <timestamp>
**Tags:** <tags or "none">
**GitHub Issue:** <#number or "none">

## Description
<description or "No description provided.">

## Notes
<!-- Add working notes here -->
```

5. Insert into SQLite:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S')

sqlite3 "$DB_PATH" "INSERT INTO tasks (slug, title, description, status, priority, tags, github_issue, folder_path, created_at, updated_at) VALUES ('<slug>', '<title_escaped>', '<desc_escaped>', 'todo', '<priority>', '<tags_json>', <issue_or_null>, '.claude/tasks/<slug>/', '$TIMESTAMP', '$TIMESTAMP');"
```

6. Confirm by showing:
   - Task ID (from `last_insert_rowid()`)
   - Title, priority, status
   - Folder path
   - Suggest using `/workflow-toolkit:task-start <id>` when ready to begin
