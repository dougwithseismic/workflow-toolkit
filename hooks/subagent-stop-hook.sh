#!/bin/bash
# Hook: SubagentStop — increment subagent count
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# Read JSON from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# Increment subagent count in session
sqlite3 "$DB_PATH" "UPDATE sessions SET subagent_count = subagent_count + 1 WHERE id = '$SESSION_ID';"

exit 0
