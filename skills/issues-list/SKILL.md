---
name: issues-list
description: List and filter tracked GitHub issues from the local SQLite database. Filter by state, label, priority, tracking status, or search by keyword.
argument-hint: [open|closed|bugs|features|triaged|in-progress|search <keyword>|priority <level>]
disable-model-invocation: true
---

# Issues List Skill

Lists and filters GitHub issues from the local SQLite tracking database.

## Instructions

1. Parse `$ARGUMENTS` to determine the filter:

   | Argument | Query filter |
   |----------|-------------|
   | _(none)_ or `open` | `state = 'OPEN'` |
   | `closed` | `state = 'CLOSED'` |
   | `bugs` | `labels LIKE '%bug%'` |
   | `features` | `labels LIKE '%feature%'` |
   | `new` | `tracking_status = 'new'` (untriaged) |
   | `triaged` | `tracking_status = 'triaged'` |
   | `in-progress` | `tracking_status = 'in-progress'` |
   | `resolved` | `tracking_status = 'resolved'` |
   | `ignored` | `tracking_status = 'ignored'` |
   | `priority <level>` | `priority = '<level>'` (critical, high, medium, low) |
   | `search <keyword>` | `title LIKE '%keyword%' OR body LIKE '%keyword%'` |
   | `all` | No filter — show everything |
   | `stale` | `synced_at < datetime('now', '-7 days')` |

2. Query the SQLite database:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# Example: list open issues
sqlite3 -header -column "$DB_PATH" "
  SELECT issue_number AS '#', title, labels, priority, tracking_status AS status, comments_count AS comments
  FROM github_issues
  WHERE state = 'OPEN'
  ORDER BY issue_number DESC
  LIMIT 30;
"
```

3. Format the output as a readable table. Include:
   - Issue number
   - Title (truncate to ~60 chars if needed)
   - Labels
   - Priority
   - Tracking status
   - Comment count

4. Show a count summary at the bottom (e.g., "Showing 20 of 45 open issues").

5. If the database has no issues, suggest running `/workflow-toolkit:issues-sync` first.
