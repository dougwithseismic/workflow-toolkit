---
name: db-viewer
description: Open the journal SQLite database in a GUI viewer (DB Browser for SQLite, or similar).
disable-model-invocation: true
---

# /db-viewer

Opens the journal database (`$CLAUDE_PROJECT_DIR/.claude/journal/journal.db`) in a SQLite GUI viewer.

## Usage

```
/workflow-toolkit:db-viewer           # Open the journal database
/workflow-toolkit:db-viewer <path>    # Open a specific SQLite database file
```

## Instructions

1. Determine which database to open:
   - If the user provided a `<path>` argument, use that path
   - Otherwise default to `$CLAUDE_PROJECT_DIR/.claude/journal/journal.db`

2. Verify the database file exists using the Read tool (just check existence, don't read content)

3. Attempt to launch a SQLite GUI viewer. Try these in order:
   ```bash
   # Windows (DB Browser for SQLite via scoop)
   start "" "$(which sqlitebrowser 2>/dev/null || echo 'sqlitebrowser')" "<db-path>" &

   # macOS
   open -a "DB Browser for SQLite" "<db-path>" 2>/dev/null

   # Linux
   sqlitebrowser "<db-path>" &
   ```

4. If no GUI viewer is found, fall back to showing the database summary via CLI:
   ```bash
   sqlite3 "<db-path>" ".tables"
   sqlite3 "<db-path>" "SELECT COUNT(*) || ' entries, ' || (SELECT COUNT(*) FROM sessions) || ' sessions, ' || (SELECT COUNT(*) FROM tasks) || ' tasks' FROM entries;"
   ```

5. Confirm to the user what was opened.

## Notes

- The journal database contains tables: `entries`, `sessions`, `compaction_snapshots`, `tool_usage`, `github_issues`, `tasks`
- If the GUI doesn't launch, suggest installing DB Browser for SQLite
