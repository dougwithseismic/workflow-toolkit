#!/bin/bash
# Hook: TaskCompleted — record task completion as journal entry
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# Read JSON from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TASK_SUMMARY=$(echo "$INPUT" | jq -r '.task_summary // .summary // "Task completed"')

if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# Escape single quotes for SQL
TASK_SUMMARY_ESCAPED=$(echo "$TASK_SUMMARY" | sed "s/'/''/g")

# Insert entry with type task-completed
sqlite3 "$DB_PATH" "INSERT INTO entries (session_id, type, summary) VALUES ('$SESSION_ID', 'task-completed', '$TASK_SUMMARY_ESCAPED');"

exit 0
