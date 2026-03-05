#!/bin/bash
# Hook: SessionStart — initialize DB if needed and insert a new session row
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# Auto-initialize DB if it doesn't exist
if [ ! -f "$DB_PATH" ]; then
  bash "$SCRIPT_DIR/init-journal-db.sh"
fi

# Read JSON from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# Insert or ignore (in case of resume with existing session)
sqlite3 "$DB_PATH" "INSERT OR IGNORE INTO sessions (id, started_at) VALUES ('$SESSION_ID', datetime('now'));"

exit 0
