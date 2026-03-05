---
name: contribution-check
description: Pre-flight checklist for open source contributions. Validates code changes against project rules, PR size limits, commit format, linting, and type-checking. Does NOT push or create PRs — only reports issues.
argument-hint: [--skip-lint|--skip-types|--verbose]
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

# Contribution Pre-Flight Check

Validates your working changes against common open-source contribution guidelines before you push. This skill is **read-only** — it never pushes code, creates PRs, or modifies anything on GitHub.

## Instructions

Run each check below in order. Report results as a checklist with pass/fail status.

### 1. Diff Size Check

```bash
# Count changed lines (excluding lockfiles, generated files, docs)
git diff --stat HEAD | tail -1
git diff --numstat HEAD -- . ':!yarn.lock' ':!package-lock.json' ':!pnpm-lock.yaml' ':!*.generated.*' ':!*.lock' | awk '{ added += $1; removed += $2; files += 1 } END { print files " files, +" added " -" removed " lines" }'
```

**Rules:**
- WARN if >500 lines changed (excluding docs, lockfiles, auto-generated)
- WARN if >10 code files modified
- Suggest splitting if either limit exceeded

### 2. Commit Message Format

```bash
git log --format="%s" -5
```

**Rules:**
- Must follow Conventional Commits: `feat:`, `fix:`, `refactor:`, `chore:`, `test:`, `docs:`, `perf:`, `ci:`
- Must be specific, not generic
- FAIL if any recent commit doesn't follow the format

### 3. Issue Eligibility

If the user specified an issue number (via `$ARGUMENTS` or conversation context):

```bash
gh issue view <NUMBER> --json labels,state
```

**Rules:**
- Features with `needs approval` label: WARN — may need to wait for maintainer approval
- Closed issues: WARN
- Open bugs/security/docs: PASS — typically safe to start

### 4. File Naming Conventions

Scan changed files for naming violations:

```bash
git diff --name-only HEAD
```

**Rules:**
- Check for project-specific naming conventions (look for CONTRIBUTING.md or similar)
- kebab-case for files is a common convention
- WARN on any violations found

### 5. Code Quality Checks

Read each changed file and check for common issues:
- Early returns preferred over deep nesting
- No obvious security issues (hardcoded secrets, SQL injection, etc.)
- No circular references introduced
- No barrel file imports (`index.ts` re-exports) — if the project discourages them
- Appropriate error handling

### 6. Lint Check (unless `--skip-lint`)

Detect the project's linter and run it:
```bash
# Try common linters in order
# biome, eslint, prettier, etc.
```

FAIL if linting reports errors.

### 7. Type Check (unless `--skip-types`)

Detect the project's type checker and run it:
```bash
# Try common type checkers
# tsc, pyright, mypy, etc.
```

FAIL if type errors found.

### 8. Relevant Tests

Check if there are test files related to changed code. WARN if changed source files have no corresponding tests.

### 9. Summary Report

Present a final summary:

```
## Contribution Check Results

| Check                  | Status | Notes                          |
|------------------------|--------|--------------------------------|
| Diff size              | PASS   | 12 files, +234 -45 lines      |
| Commit format          | PASS   | feat: add timezone handling    |
| Issue eligibility      | PASS   | #123 - bug, safe to start     |
| File naming            | PASS   |                                |
| Code quality           | WARN   | 1 potential issue found        |
| Lint                   | PASS   |                                |
| Type check             | PASS   |                                |
| Tests                  | WARN   | 2 files missing test coverage  |

### Action Items
- [ ] Fix identified issues
- [ ] Add tests for uncovered files
```

**IMPORTANT**: This skill NEVER pushes code, creates branches, creates PRs, or modifies anything on GitHub. It only reads and reports.
