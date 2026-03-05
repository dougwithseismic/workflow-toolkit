---
name: issues-sync
description: Sync GitHub issues from the repo into the local SQLite database for tracking. Supports full CRUD — pull open/closed issues, detect changes, and prune stale entries. Read-only on GitHub (never posts).
argument-hint: [--full|--diff|--prune|--limit 50|--label "bug"]
disable-model-invocation: true
---

# Issues Sync Skill

Full CRUD sync of GitHub issues into the local SQLite database.

## Instructions

1. Parse `$ARGUMENTS` to determine sync mode. The sync script accepts these flags:

   | Flag | Effect |
   |------|--------|
   | _(none)_ | Sync 30 most recent open issues |
   | `--full` | Sync both open AND closed issues (30 each) |
   | `--diff` | Show what changed since last sync (new, state changes, updated) |
   | `--prune` | Remove closed issues that are locally marked 'resolved' or 'ignored' |
   | `--prune-all` | Remove ALL closed issues from local DB |
   | `--limit N` | Override the default 30-issue limit (passed to gh) |
   | `--state closed` | Sync only closed issues (passed to gh) |
   | `--label "bug"` | Filter by label (passed to gh) |

   Flags can be combined: `--full --diff --prune`

2. Run the sync script:

```bash
node "${CLAUDE_PLUGIN_ROOT}/scripts/sync-issues.js" $ARGUMENTS
```

3. After syncing, show a summary. For richer stats, query the DB:

```bash
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
sqlite3 -header -column "$DB_PATH" "
  SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN state = 'OPEN' THEN 1 ELSE 0 END) AS open,
    SUM(CASE WHEN state = 'CLOSED' THEN 1 ELSE 0 END) AS closed,
    SUM(CASE WHEN tracking_status = 'new' THEN 1 ELSE 0 END) AS untriaged,
    SUM(CASE WHEN tracking_status = 'in-progress' THEN 1 ELSE 0 END) AS in_progress
  FROM github_issues;
"
```

## CRUD Operations Summary

| Operation | How |
|-----------|-----|
| **Create** | Auto-inserts new issues from GitHub on every sync |
| **Read** | Use `/workflow-toolkit:issues-list` and `/workflow-toolkit:issues-view` to query local DB |
| **Update** | Re-sync updates GitHub fields; `/workflow-toolkit:issues-triage` updates local metadata |
| **Delete** | `--prune` removes resolved/ignored closed issues; `--prune-all` removes all closed |

**Important**: Read-only on GitHub — only pulls data down, never posts or modifies anything upstream.
