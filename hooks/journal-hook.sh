#!/bin/bash
# Journal hook - fires on Stop (per response) to increment prompt count
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# Read JSON input from stdin
INPUT=$(cat)

# Extract session_id
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Only log if DB exists
if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# Increment prompt count for this session
sqlite3 "$DB_PATH" "UPDATE sessions SET prompt_count = prompt_count + 1 WHERE id = '$SESSION_ID';"

exit 0
