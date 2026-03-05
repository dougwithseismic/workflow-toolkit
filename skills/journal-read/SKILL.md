---
name: journal-read
description: Read and query journal entries. Shows recent activity, search by keyword, or filter by date. Can read from both SQLite and markdown entries.
argument-hint: [recent|today|search <keyword>|all|last <N>]
disable-model-invocation: true
---

# Journal Read Skill

This skill queries and displays journal entries from the SQLite database.

## Instructions

1. Parse `$ARGUMENTS` to determine the query type:

   - **`recent`** or **no arguments**: Show the last 10 entries
   - **`today`**: Show entries from today
   - **`search <keyword>`**: Search summaries and details for the keyword
   - **`all`**: List all entries (summaries only, for brevity)
   - **`last <N>`**: Show the last N entries

2. Query the SQLite database at `$CLAUDE_PROJECT_DIR/.claude/journal/journal.db` using Bash.

3. Use the following query patterns:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# recent / default — last 10 entries
sqlite3 -header -column "$DB_PATH" "SELECT id, timestamp, type, summary FROM entries ORDER BY timestamp DESC LIMIT 10;"

# today
sqlite3 -header -column "$DB_PATH" "SELECT id, timestamp, type, summary, details FROM entries WHERE date(timestamp) = date('now') ORDER BY timestamp DESC;"

# search <keyword>
sqlite3 -header -column "$DB_PATH" "SELECT id, timestamp, type, summary FROM entries WHERE summary LIKE '%<keyword>%' OR details LIKE '%<keyword>%' ORDER BY timestamp DESC;"

# all
sqlite3 -header -column "$DB_PATH" "SELECT id, timestamp, type, summary FROM entries ORDER BY timestamp DESC;"

# last <N>
sqlite3 -header -column "$DB_PATH" "SELECT id, timestamp, type, summary, details FROM entries ORDER BY timestamp DESC LIMIT <N>;"
```

4. Format the results in a readable way for the user.

5. Also check if there are markdown entries in `$CLAUDE_PROJECT_DIR/.claude/journal/entries/` and mention them if present, so the user knows they can read detailed entries there.

6. If the database does not exist, inform the user and suggest initializing it. The database will be auto-created on the next session start via the SessionStart hook.
