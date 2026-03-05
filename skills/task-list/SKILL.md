---
name: task-list
description: List and filter local tasks from SQLite. Filter by status, priority, or search by keyword.
argument-hint: [todo|in-progress|done|blocked|all|priority <level>|search <keyword>]
disable-model-invocation: true
---

# Task List Skill

Lists and filters tasks from the local SQLite database.

## Instructions

1. Parse `$ARGUMENTS` to determine the filter:

   | Argument | Query filter |
   |----------|-------------|
   | _(none)_ or `active` | `status IN ('todo', 'in-progress', 'blocked')` |
   | `todo` | `status = 'todo'` |
   | `in-progress` | `status = 'in-progress'` |
   | `done` | `status = 'done'` |
   | `blocked` | `status = 'blocked'` |
   | `all` | No filter |
   | `priority <level>` | `priority = '<level>'` |
   | `search <keyword>` | `title LIKE '%keyword%' OR description LIKE '%keyword%'` |

2. Query the SQLite database:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

sqlite3 -header -column "$DB_PATH" "
  SELECT id, title, status, priority, tags,
         CASE WHEN github_issue IS NOT NULL THEN '#' || github_issue ELSE '' END AS issue,
         created_at
  FROM tasks
  WHERE status IN ('todo', 'in-progress', 'blocked')
  ORDER BY
    CASE priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 WHEN 'low' THEN 4 END,
    CASE status WHEN 'in-progress' THEN 1 WHEN 'blocked' THEN 2 WHEN 'todo' THEN 3 WHEN 'done' THEN 4 END,
    created_at DESC
  LIMIT 30;
"
```

3. Format as a readable table. Truncate title to ~50 chars if needed.

4. Show a count summary at the bottom (e.g., "3 active tasks (1 in-progress, 2 todo)").

5. If no tasks exist, suggest using `/workflow-toolkit:task-create <title>` to add one.
