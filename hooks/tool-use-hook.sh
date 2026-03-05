#!/bin/bash
# Hook: PostToolUse — log tool usage
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# Read JSON from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# Extract file path for Write/Edit tools
FILE_PATH=""
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
fi

# Insert tool usage record
sqlite3 "$DB_PATH" "INSERT INTO tool_usage (session_id, tool_name, file_path) VALUES ('$SESSION_ID', '$TOOL_NAME', '$FILE_PATH');"

# Increment tool_use_count in session
sqlite3 "$DB_PATH" "UPDATE sessions SET tool_use_count = tool_use_count + 1 WHERE id = '$SESSION_ID';"

exit 0
