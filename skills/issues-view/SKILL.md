---
name: issues-view
description: View detailed information about a specific GitHub issue. Shows the full body, comments, labels, and local tracking metadata. Can fetch fresh data from GitHub or read from local DB.
argument-hint: <issue-number> [--refresh]
disable-model-invocation: true
---

# Issues View Skill

Displays detailed information about a specific GitHub issue.

## Instructions

1. Parse `$ARGUMENTS`:
   - **First token**: The issue number (required)
   - **`--refresh`**: If present, fetch fresh data from GitHub before displaying

2. If `--refresh` is specified (or the issue isn't in the local DB), fetch from GitHub:

```bash
gh issue view <NUMBER> --json number,title,state,labels,author,assignees,createdAt,updatedAt,body,url,comments
```

Then upsert the result into the local DB (same logic as `/workflow-toolkit:issues-sync`).

3. Query the local database for the issue:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
sqlite3 -header -column "$DB_PATH" "
  SELECT issue_number, title, state, labels, author, assignees,
         created_at, updated_at, comments_count, priority,
         tracking_status, notes, synced_at
  FROM github_issues
  WHERE issue_number = <NUMBER>;
"
```

4. Also fetch and display the issue body:

```bash
sqlite3 "$DB_PATH" "SELECT body FROM github_issues WHERE issue_number = <NUMBER>;"
```

5. If `--refresh` was used or the user wants comments, fetch them live:

```bash
gh issue view <NUMBER> --comments
```

6. Present the information in a structured format:

```
## Issue #<NUMBER>: <Title>

**State:** OPEN | **Author:** @username | **Created:** date
**Labels:** bug, feature | **Assignees:** @user1, @user2
**Comments:** N | **Last synced:** datetime

### Tracking
**Priority:** high | **Status:** in-progress
**Notes:** <user notes if any>

### Description
<full body text>

### Recent Comments (if fetched)
- @user (date): comment text
```

7. If the issue is not found locally or on GitHub, inform the user.
