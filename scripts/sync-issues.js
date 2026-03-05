#!/usr/bin/env node
/**
 * Syncs GitHub issues into the local SQLite journal database.
 *
 * Usage:
 *   node sync-issues.js [options]
 *
 * Built-in flags (must come before gh flags):
 *   --full          Sync both open AND closed (recent 30 each)
 *   --diff          Show what changed since last sync
 *   --prune         Remove local issues that are closed on GitHub and tracked as 'resolved' or 'ignored'
 *   --prune-all     Remove ALL closed issues from local DB
 *
 * All other flags are passed through to `gh issue list`.
 *
 * Environment:
 *   DB_PATH - path to journal.db (defaults to $CLAUDE_PROJECT_DIR/.claude/journal/journal.db)
 */

const { execSync } = require("child_process");
const path = require("path");

const DB_PATH =
  process.env.DB_PATH ||
  path.resolve(
    process.env.CLAUDE_PROJECT_DIR || process.cwd(),
    ".claude",
    "journal",
    "journal.db"
  );

// Parse our custom flags vs gh passthrough flags
const args = process.argv.slice(2);
let doFull = false;
let doDiff = false;
let doPrune = false;
let doPruneAll = false;
const ghArgs = [];

for (const arg of args) {
  if (arg === "--full") doFull = true;
  else if (arg === "--diff") doDiff = true;
  else if (arg === "--prune") doPrune = true;
  else if (arg === "--prune-all") doPruneAll = true;
  else ghArgs.push(arg);
}

const ghExtra = ghArgs.join(" ");

// Helper: run gh issue list with given flags
function fetchIssues(stateFlag) {
  const cmd = `gh issue list --limit 30 --state ${stateFlag} --json number,title,state,labels,author,assignees,createdAt,updatedAt,body,url,comments ${ghExtra}`;
  try {
    const raw = execSync(cmd, {
      encoding: "utf-8",
      maxBuffer: 10 * 1024 * 1024,
    });
    return JSON.parse(raw);
  } catch (err) {
    console.error(
      `Failed to fetch ${stateFlag} issues from GitHub. Is gh authenticated?`
    );
    console.error(err.message);
    process.exit(1);
  }
}

// Helper: query sqlite
function sqlQuery(sql) {
  try {
    return execSync(`sqlite3 "${DB_PATH}"`, {
      input: sql,
      encoding: "utf-8",
    }).trim();
  } catch (err) {
    console.error("SQLite error:", err.message);
    return "";
  }
}

// Collect snapshot of current state for diff
let beforeState = {};
if (doDiff) {
  const rows = sqlQuery(
    "SELECT issue_number, state, title, updated_at FROM github_issues;"
  );
  if (rows) {
    for (const row of rows.split("\n")) {
      const [num, state, title, updated] = row.split("|");
      beforeState[num] = { state, title, updated };
    }
  }
}

// Fetch issues
let issues = fetchIssues("open");
if (doFull) {
  const closed = fetchIssues("closed");
  issues = issues.concat(closed);
}

if (!issues.length) {
  console.log("No issues found matching the query.");
  process.exit(0);
}

const syncedAt = new Date().toISOString().replace("T", " ").slice(0, 19);
const esc = (s) => (s || "").replace(/'/g, "''");

// Build upsert transaction
const sqlStatements = ["BEGIN TRANSACTION;"];

for (const issue of issues) {
  const labels = JSON.stringify((issue.labels || []).map((l) => l.name));
  const assignees = JSON.stringify(
    (issue.assignees || []).map((a) => a.login)
  );
  const author = (issue.author || {}).login || "";
  const commentsCount = (issue.comments || []).length;

  sqlStatements.push(`
    INSERT INTO github_issues (issue_number, title, state, labels, author, assignees, created_at, updated_at, body, url, comments_count, synced_at)
    VALUES (${issue.number}, '${esc(issue.title)}', '${issue.state}', '${esc(labels)}', '${esc(author)}', '${esc(assignees)}', '${esc(issue.createdAt)}', '${esc(issue.updatedAt)}', '${esc(issue.body)}', '${esc(issue.url)}', ${commentsCount}, '${syncedAt}')
    ON CONFLICT(issue_number) DO UPDATE SET
      title=excluded.title,
      state=excluded.state,
      labels=excluded.labels,
      author=excluded.author,
      assignees=excluded.assignees,
      updated_at=excluded.updated_at,
      body=excluded.body,
      url=excluded.url,
      comments_count=excluded.comments_count,
      synced_at=excluded.synced_at;
  `);
}

sqlStatements.push("COMMIT;");
sqlQuery(sqlStatements.join("\n"));

// Count results
const openCount = issues.filter((i) => i.state === "OPEN").length;
const closedCount = issues.filter((i) => i.state === "CLOSED").length;
console.log(
  `Synced ${issues.length} issues (${openCount} open, ${closedCount} closed)`
);

// Diff reporting
if (doDiff) {
  const newIssues = [];
  const stateChanges = [];
  const updated = [];

  for (const issue of issues) {
    const num = String(issue.number);
    const before = beforeState[num];
    if (!before) {
      newIssues.push(`  #${num} ${issue.title}`);
    } else {
      if (before.state !== issue.state) {
        stateChanges.push(
          `  #${num} ${before.state} -> ${issue.state}: ${issue.title}`
        );
      } else if (before.updated !== issue.updatedAt) {
        updated.push(`  #${num} ${issue.title}`);
      }
    }
  }

  if (newIssues.length) {
    console.log(`\nNew issues (${newIssues.length}):`);
    console.log(newIssues.join("\n"));
  }
  if (stateChanges.length) {
    console.log(`\nState changes (${stateChanges.length}):`);
    console.log(stateChanges.join("\n"));
  }
  if (updated.length) {
    console.log(`\nUpdated (${updated.length}):`);
    console.log(updated.join("\n"));
  }
  if (!newIssues.length && !stateChanges.length && !updated.length) {
    console.log("\nNo changes detected since last sync.");
  }
}

// Prune
if (doPrune) {
  const result = sqlQuery(
    "DELETE FROM github_issues WHERE state = 'CLOSED' AND tracking_status IN ('resolved', 'ignored'); SELECT changes();"
  );
  console.log(`\nPruned ${result || 0} closed+resolved/ignored issues.`);
}

if (doPruneAll) {
  const result = sqlQuery(
    "DELETE FROM github_issues WHERE state = 'CLOSED'; SELECT changes();"
  );
  console.log(`\nPruned ${result || 0} closed issues.`);
}
