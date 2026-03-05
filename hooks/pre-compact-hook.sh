#!/bin/bash
# Hook: PreCompact — record compaction snapshot
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# Read JSON from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "auto"')

if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# Insert compaction snapshot
sqlite3 "$DB_PATH" "INSERT INTO compaction_snapshots (session_id, trigger, summary) VALUES ('$SESSION_ID', '$TRIGGER', 'Compaction triggered ($TRIGGER)');"

# Increment compaction count in session
sqlite3 "$DB_PATH" "UPDATE sessions SET compaction_count = compaction_count + 1 WHERE id = '$SESSION_ID';"

exit 0
