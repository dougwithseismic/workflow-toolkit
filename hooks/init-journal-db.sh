#!/bin/bash
# Initialize the journal SQLite database
# Data is stored per-project at $CLAUDE_PROJECT_DIR/.claude/journal/journal.db
DB_PATH="$CLAUDE_PROJECT_DIR/.claude/journal/journal.db"
mkdir -p "$(dirname "$DB_PATH")"

sqlite3 "$DB_PATH" <<'SQL'
CREATE TABLE IF NOT EXISTS entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  session_id TEXT,
  type TEXT NOT NULL DEFAULT 'auto',  -- 'auto' (from hook), 'manual' (from skill), 'task-completed'
  summary TEXT NOT NULL,
  details TEXT,
  files_changed TEXT,  -- JSON array of file paths
  next_steps TEXT
);

CREATE INDEX IF NOT EXISTS idx_entries_timestamp ON entries(timestamp);
CREATE INDEX IF NOT EXISTS idx_entries_session ON entries(session_id);
CREATE INDEX IF NOT EXISTS idx_entries_type ON entries(type);

-- Session tracking
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  started_at TEXT NOT NULL DEFAULT (datetime('now')),
  ended_at TEXT,
  end_reason TEXT,  -- 'clear', 'logout', 'prompt_input_exit', 'other'
  prompt_count INTEGER DEFAULT 0,
  tool_use_count INTEGER DEFAULT 0,
  subagent_count INTEGER DEFAULT 0,
  compaction_count INTEGER DEFAULT 0,
  summary TEXT
);

-- Compaction snapshots
CREATE TABLE IF NOT EXISTS compaction_snapshots (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  session_id TEXT,
  trigger TEXT,  -- 'manual' or 'auto'
  summary TEXT NOT NULL
);

-- Tool usage log (lightweight)
CREATE TABLE IF NOT EXISTS tool_usage (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  session_id TEXT,
  tool_name TEXT NOT NULL,
  file_path TEXT,  -- if applicable
  success INTEGER DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_sessions_started ON sessions(started_at);
CREATE INDEX IF NOT EXISTS idx_compaction_session ON compaction_snapshots(session_id);
CREATE INDEX IF NOT EXISTS idx_tool_usage_session ON tool_usage(session_id);
CREATE INDEX IF NOT EXISTS idx_tool_usage_tool ON tool_usage(tool_name);

-- GitHub issues tracking (synced via gh CLI, never posts to GitHub)
CREATE TABLE IF NOT EXISTS github_issues (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  issue_number INTEGER UNIQUE NOT NULL,
  title TEXT NOT NULL,
  state TEXT NOT NULL DEFAULT 'OPEN',
  labels TEXT,          -- JSON array of label names
  author TEXT,
  assignees TEXT,       -- JSON array of login names
  created_at TEXT,
  updated_at TEXT,
  body TEXT,
  url TEXT,
  comments_count INTEGER DEFAULT 0,
  synced_at TEXT NOT NULL DEFAULT (datetime('now')),
  priority TEXT DEFAULT 'unset',        -- local triage: critical, high, medium, low, unset
  tracking_status TEXT DEFAULT 'new',   -- local tracking: new, triaged, in-progress, resolved, ignored
  notes TEXT                            -- free-form local notes
);

CREATE INDEX IF NOT EXISTS idx_issues_number ON github_issues(issue_number);
CREATE INDEX IF NOT EXISTS idx_issues_state ON github_issues(state);
CREATE INDEX IF NOT EXISTS idx_issues_tracking ON github_issues(tracking_status);
CREATE INDEX IF NOT EXISTS idx_issues_priority ON github_issues(priority);

-- Local task tracking
CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'todo',      -- todo, in-progress, done, blocked
  priority TEXT NOT NULL DEFAULT 'medium',   -- critical, high, medium, low
  tags TEXT,                                 -- JSON array of tag strings
  github_issue INTEGER,                      -- optional link to github_issues.issue_number
  folder_path TEXT,                          -- .claude/tasks/<slug>/
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  started_at TEXT,
  completed_at TEXT,
  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_slug ON tasks(slug);
SQL

echo "Journal DB initialized at $DB_PATH"
