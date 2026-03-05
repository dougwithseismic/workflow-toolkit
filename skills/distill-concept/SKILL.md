---
name: distill-concept
description: Distills a codebase concept into a structured knowledge base entry. Analyzes patterns, conventions, and real examples from the code to create reference documentation. Use when you need to understand how something works in this project (e.g., React hooks, API routers, database models, testing patterns).
argument-hint: <concept> e.g. "react-hooks", "api-routers", "database-schema", "auth-flow"
disable-model-invocation: true
context: fork
agent: Explore
---

# Distill Codebase Concept: **$ARGUMENTS**

## Template

Read the template at [template.md](${CLAUDE_SKILL_DIR}/template.md). This is the structure you must follow for the output file. Copy it and fill in every `{{placeholder}}` with real data from the codebase.

## Process

1. **Parse** `$ARGUMENTS` into a kebab-case concept name
2. **Search** the codebase with Glob and Grep to find all relevant files
3. **Read** representative examples — the best 5-10 files showing the pattern
4. **Identify** conventions, variations, and non-obvious details
5. **Copy** the template and fill in every placeholder with real data
6. **Write** the result to `knowledge-base/<concept-name>.md`

## Quality Rules

- Every file path must actually exist — verify with Glob/Read
- Code snippets must be real code copied from actual files, not fabricated
- Use `file.ts:line` format for references
- Patterns must be confirmed across multiple files, not one-offs
- Capture THIS project's approach, not generic best practices
- Add/remove pattern sections as needed — template sections are repeatable
- Keep it scannable: tables and bullet lists over prose

## Output

Write to `knowledge-base/<concept-name>.md`, then report: file path, brief summary, pattern count, and suggestions for related concepts to distill next.
