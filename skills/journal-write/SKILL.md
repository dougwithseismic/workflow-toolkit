---
name: journal-write
description: Write a journal entry documenting what was done in this session. Records what changed, why, and next steps. Saves to both SQLite and a timestamped markdown file.
argument-hint: [optional summary of what was done]
disable-model-invocation: true
---

# Journal Write Skill

This skill writes a structured journal entry documenting the current session's work.

## Instructions

1. If `$ARGUMENTS` is provided, use it as a starting point for the summary. Otherwise, reflect on what was done in the current conversation.

2. Compose a structured journal entry with these sections:
   - **Summary**: A one-line description of the session's work
   - **What Was Done**: Bullet points of actions taken
   - **Why**: The reasoning or motivation behind the changes
   - **Files Changed**: List of files modified with brief descriptions
   - **Next Steps**: Any follow-up work identified (if applicable)

3. Generate a timestamp using `date -u '+%Y-%m-%d %H:%M:%S'` for the entry, and `date -u '+%Y-%m-%d_%H-%M-%S'` for the filename.

4. Insert the entry into SQLite using Bash:

```bash
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S')
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

sqlite3 "$DB_PATH" "INSERT INTO entries (timestamp, type, summary, details, files_changed, next_steps) VALUES ('$TIMESTAMP', 'manual', '<SUMMARY>', '<DETAILS>', '<FILES_JSON>', '<NEXT_STEPS>');"
```

5. Also write a markdown file to `$CLAUDE_PROJECT_DIR/.claude/journal/entries/YYYY-MM-DD_HH-MM-SS.md` with this format:

```markdown
# Journal Entry: YYYY-MM-DD HH:MM:SS

## Summary
<one line>

## What Was Done
- <bullet points>

## Why
<reasoning>

## Files Changed
- `path/to/file.ts` — description

## Next Steps
- <bullet points if any>
```

6. Confirm the entry was saved by showing the summary and file path.
