---
name: issues-triage
description: Update the local tracking metadata for a GitHub issue. Set priority, tracking status, or add notes. Does not modify the issue on GitHub.
argument-hint: <issue-number> <action> [value]
disable-model-invocation: true
---

# Issues Triage Skill

Updates local tracking metadata for GitHub issues in the SQLite database.

## Instructions

1. Parse `$ARGUMENTS` to extract:
   - **Issue number**: First token (required)
   - **Action**: Second token — one of `priority`, `status`, `note`, `ignore`, `pick`
   - **Value**: Remaining tokens (the value to set)

2. Actions:

   | Action | Usage | Effect |
   |--------|-------|--------|
   | `priority` | `/workflow-toolkit:issues-triage 123 priority high` | Sets priority to: critical, high, medium, low, unset |
   | `status` | `/workflow-toolkit:issues-triage 123 status in-progress` | Sets tracking_status to: new, triaged, in-progress, resolved, ignored |
   | `note` | `/workflow-toolkit:issues-triage 123 note Needs repro steps` | Appends to the notes field |
   | `ignore` | `/workflow-toolkit:issues-triage 123 ignore` | Shortcut: sets tracking_status to 'ignored' |
   | `pick` | `/workflow-toolkit:issues-triage 123 pick` | Shortcut: sets tracking_status to 'in-progress' |

3. Execute the update:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"

# priority
sqlite3 "$DB_PATH" "UPDATE github_issues SET priority = '<value>' WHERE issue_number = <NUMBER>;"

# status
sqlite3 "$DB_PATH" "UPDATE github_issues SET tracking_status = '<value>' WHERE issue_number = <NUMBER>;"

# note — append to existing notes with timestamp
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M')
sqlite3 "$DB_PATH" "UPDATE github_issues SET notes = COALESCE(notes || char(10), '') || '[$TIMESTAMP] <value>' WHERE issue_number = <NUMBER>;"

# ignore
sqlite3 "$DB_PATH" "UPDATE github_issues SET tracking_status = 'ignored' WHERE issue_number = <NUMBER>;"

# pick
sqlite3 "$DB_PATH" "UPDATE github_issues SET tracking_status = 'in-progress' WHERE issue_number = <NUMBER>;"
```

4. After updating, display the updated issue row:

```bash
sqlite3 -header -column "$DB_PATH" "
  SELECT issue_number AS '#', title, priority, tracking_status AS status, notes
  FROM github_issues
  WHERE issue_number = <NUMBER>;
"
```

5. Validate:
   - Priority must be one of: critical, high, medium, low, unset
   - Status must be one of: new, triaged, in-progress, resolved, ignored
   - Issue must exist in the DB (suggest `/workflow-toolkit:issues-sync` if not found)
