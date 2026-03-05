---
name: pr-prepare
description: Prepares a pull request description. Generates the title, body, and checklist — then STOPS and presents everything for user review. Does NOT create the PR or push code without explicit user consent.
argument-hint: <issue-number> [--draft]
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

# PR Preparation Skill

Drafts a complete pull request, then **stops for your review**. Nothing is pushed or created without your explicit say-so.

## Instructions

### 1. Gather Context

```bash
# Current branch and diff from main
git branch --show-current
git log main..HEAD --oneline
git diff --stat main...HEAD
git diff main...HEAD -- . ':!yarn.lock' ':!package-lock.json' ':!pnpm-lock.yaml' ':!*.generated.*'
```

If `$ARGUMENTS` contains an issue number, fetch the issue:

```bash
gh issue view <NUMBER> --json title,body,labels,state
```

### 2. Generate PR Title

**Rules:**
- Must follow Conventional Commits: `feat:`, `fix:`, `refactor:`, `chore:`, etc.
- Under 70 characters
- Be specific about what changed and why
- Examples:
  - `fix: handle timezone edge case in booking creation`
  - `refactor: migrate webhooks page to new components`
  - `feat: add upgrade banners for teams`

### 3. Generate PR Body

Look for a PR template at `.github/PULL_REQUEST_TEMPLATE.md`. If one exists, use it. Otherwise, use this default structure:

```markdown
## What does this PR do?

<Summary of changes — what and why, not just what files changed>

- Fixes #<NUMBER> (if applicable)

## How should this be tested?

<Step-by-step testing instructions>

## Checklist

- [ ] I have self-reviewed the code
- [ ] I have updated documentation if needed
- [ ] I confirm automated tests are in place
- [ ] My PR is appropriately sized (<500 lines, <10 files)
```

### 4. Size Validation

```bash
git diff --numstat main...HEAD -- . ':!yarn.lock' ':!package-lock.json' ':!pnpm-lock.yaml' ':!*.generated.*' ':!*.lock' | awk '{ added += $1; removed += $2; files += 1 } END { print files, added, removed }'
```

If >500 lines or >10 files, suggest how to split:
- Database/schema changes separate from app logic
- Frontend and backend in separate PRs
- Refactoring separate from new features

### 5. Present for Review — STOP HERE

Display the complete PR draft to the user:

```
## PR Ready for Review

**Title:** fix: handle timezone edge case in booking creation

**Base:** main <- your-branch-name

**Body:**
<the full PR body from step 3>

---

### Pre-push checklist
- [ ] Linting passes
- [ ] Type checking passes
- [ ] Relevant tests pass
- [ ] Branch is up to date with main

### Next steps (requires your approval):
1. Push branch: `git push -u origin <branch-name>`
2. Create PR: `gh pr create --draft --title "..." --body "..."`
```

**CRITICAL**: Do NOT execute the "Next steps" commands. Only show them. Wait for the user to explicitly ask you to push and/or create the PR.

### 6. Only On Explicit User Consent

If the user explicitly says to proceed (e.g., "go ahead", "create the PR", "push it"):
- Create PR in **draft mode** by default
- Use `--draft` flag unless user specifically says "ready for review"
- Show the PR URL after creation

**NEVER auto-push or auto-create PRs. The user must explicitly consent each time.**
