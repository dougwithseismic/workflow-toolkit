#!/bin/bash
# Hook: SessionEnd — finalize session row and write markdown summary
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
ENTRIES_DIR="$CLAUDE_PROJECT_DIR/.claude/journal/entries"

# Read JSON from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

if [ ! -f "$DB_PATH" ]; then
  exit 0
fi

# Determine end reason from input
END_REASON=$(echo "$INPUT" | jq -r '.end_reason // "other"')

# Update session with end time and reason
sqlite3 "$DB_PATH" "UPDATE sessions SET ended_at = datetime('now'), end_reason = '$END_REASON' WHERE id = '$SESSION_ID';"

# Query session stats for the summary
STATS=$(sqlite3 -separator '|' "$DB_PATH" "SELECT prompt_count, tool_use_count, subagent_count, compaction_count, started_at, ended_at FROM sessions WHERE id = '$SESSION_ID' LIMIT 1;")

if [ -z "$STATS" ]; then
  exit 0
fi

PROMPT_COUNT=$(echo "$STATS" | cut -d'|' -f1)
TOOL_USE_COUNT=$(echo "$STATS" | cut -d'|' -f2)
SUBAGENT_COUNT=$(echo "$STATS" | cut -d'|' -f3)
COMPACTION_COUNT=$(echo "$STATS" | cut -d'|' -f4)
STARTED_AT=$(echo "$STATS" | cut -d'|' -f5)
ENDED_AT=$(echo "$STATS" | cut -d'|' -f6)

# Query entries for this session
ENTRY_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM entries WHERE session_id = '$SESSION_ID';")
ENTRY_SUMMARIES=$(sqlite3 "$DB_PATH" "SELECT '- ' || summary FROM entries WHERE session_id = '$SESSION_ID' ORDER BY timestamp ASC;")

# Query top tools used
TOP_TOOLS=$(sqlite3 "$DB_PATH" "SELECT tool_name || ' (' || COUNT(*) || 'x)' FROM tool_usage WHERE session_id = '$SESSION_ID' GROUP BY tool_name ORDER BY COUNT(*) DESC LIMIT 5;")

# Write markdown summary
mkdir -p "$ENTRIES_DIR"
FILENAME=$(date -u '+%Y-%m-%d_%H-%M-%S')-session-end.md

cat > "$ENTRIES_DIR/$FILENAME" <<MARKDOWN
# Session Summary: $SESSION_ID

**Started:** $STARTED_AT
**Ended:** $ENDED_AT
**End Reason:** $END_REASON

## Stats

| Metric | Count |
|--------|-------|
| Prompts | $PROMPT_COUNT |
| Tool Uses | $TOOL_USE_COUNT |
| Subagents | $SUBAGENT_COUNT |
| Compactions | $COMPACTION_COUNT |
| Journal Entries | $ENTRY_COUNT |

## Top Tools Used

$TOP_TOOLS

## Journal Entries

$ENTRY_SUMMARIES
MARKDOWN

# Update session summary in DB
SUMMARY="Prompts: $PROMPT_COUNT, Tools: $TOOL_USE_COUNT, Subagents: $SUBAGENT_COUNT, Entries: $ENTRY_COUNT"
sqlite3 "$DB_PATH" "UPDATE sessions SET summary = '$SUMMARY' WHERE id = '$SESSION_ID';"

exit 0
