---
name: create-skill
description: Creates a new Claude Code custom skill (slash command). Guides you through designing, writing, and placing the SKILL.md file with proper frontmatter, arguments, and best practices.
argument-hint: <skill-name> <brief description of what the skill should do>
disable-model-invocation: true
---

# Create a New Claude Code Skill

You are creating a new custom skill based on the user's request: **$ARGUMENTS**

Follow the steps below precisely to produce a production-quality skill.

## Step 1: Parse the Request

Extract from `$ARGUMENTS`:
- **Skill name**: The first token (use kebab-case, lowercase, max 64 chars). If the user did not provide one, derive a concise name from the description.
- **Purpose**: Everything after the name describes what the skill should do.

## Step 2: Determine Scope and Placement

Ask yourself (do not prompt the user unless truly ambiguous):

| Scope | Path | When to choose |
|-------|------|----------------|
| Project | `.claude/skills/<skill-name>/SKILL.md` | Skill is specific to this codebase and should be shared with the team via version control. |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | Skill is useful across all of the user's projects but not team-shared. |

Default to **project scope** (`.claude/skills/<skill-name>/SKILL.md`) unless the user explicitly says "personal" or "global".

## Step 3: Design the Frontmatter

Compose YAML frontmatter between `---` markers. Use only the fields that apply:

```yaml
---
name: <skill-name>
description: <Clear, specific description of what the skill does and when to use it. Claude uses this to decide when to load the skill automatically.>
argument-hint: <optional hint shown during autocomplete, e.g. [filename] [format]>
disable-model-invocation: <set to true only if the skill has side effects or should only be triggered manually>
allowed-tools: <optional comma-separated list of tools to restrict what Claude can use, e.g. Read, Grep, Glob>
context: <set to "fork" only if the skill should run in an isolated subagent>
agent: <if context is fork, specify agent type: Explore, Plan, general-purpose, or a custom agent name>
model: <optional: sonnet, opus, haiku, or inherit>
---
```

### Frontmatter Guidelines

- **`description`** is the most important field. Write it so Claude can match it to natural language queries. Include trigger phrases and keywords.
- **`disable-model-invocation: true`** for skills with side effects (deploy, commit, send messages) or skills the user wants full manual control over.
- **`user-invocable: false`** for background knowledge skills that Claude should load automatically but users should not invoke directly.
- **`allowed-tools`** to enforce constraints (e.g., read-only skills should use `Read, Grep, Glob`).
- **`context: fork`** when the skill should run in isolation and not pollute the main conversation context. Pair with `agent` to choose the execution environment.
- Omit fields you do not need. Only `description` is recommended; all others are optional.

## Step 4: Write the Skill Content

After the frontmatter, write the markdown body. This is the prompt Claude receives when the skill is invoked.

### Content Patterns

**Reference skills** (conventions, style guides):
```markdown
When writing API endpoints:
- Use RESTful naming conventions
- Return consistent error formats with { error: string, code: number }
- Include request validation using zod schemas
```

**Task skills** (step-by-step workflows):
```markdown
Deploy the application:
1. Run the test suite: `npm test`
2. Build the application: `npm run build`
3. Push to the deployment target
4. Verify the deployment succeeded
```

**Parameterized skills** (using arguments):
```markdown
Fix GitHub issue $ARGUMENTS following our coding standards.
1. Read the issue description using `gh issue view $ARGUMENTS`
2. Understand the requirements
3. Implement the fix
4. Write tests
5. Create a commit
```

### Content Best Practices

1. **Use `$ARGUMENTS`** for dynamic input. If `$ARGUMENTS` is absent, user input is appended automatically.
2. **Use `$ARGUMENTS[N]` or `$N`** for positional arguments: `$0` for first, `$1` for second, etc.
3. **Use `${CLAUDE_SKILL_DIR}`** to reference files bundled with the skill.
4. **Use `` !`command` `` syntax** to inject dynamic context from shell commands (e.g., `` !`git branch --show-current` ``).
5. Keep `SKILL.md` under **500 lines**. Move detailed reference material to separate files in the skill directory.
6. Write clear, numbered steps for task-oriented skills.
7. Include examples of expected output format when relevant.
8. Specify constraints and edge cases Claude should handle.
9. For complex skills, add supporting files (templates, examples, scripts) in the skill directory and reference them from SKILL.md.

### Supporting Files and Templates

Skills can include supporting files in their directory:

```
<skill-name>/
  SKILL.md           # Main instructions (required)
  template.md        # Template with {{placeholders}} for Claude to fill in
  examples/
    sample.md        # Example output
  scripts/
    helper.sh        # Utility script
```

Reference them from SKILL.md using `${CLAUDE_SKILL_DIR}`:
```markdown
## Template
Read the template at [template.md](${CLAUDE_SKILL_DIR}/template.md) and fill in every {{placeholder}}.
```

## Step 5: Write the File

1. Create the skill directory: `mkdir -p <scope-path>/<skill-name>`
2. Write `SKILL.md` to `<scope-path>/<skill-name>/SKILL.md`
3. Create any supporting files referenced in the skill content

## Step 6: Validate

After writing the file, verify:
- [ ] File name uses kebab-case
- [ ] YAML frontmatter is valid (proper `---` delimiters, correct field names)
- [ ] `description` is specific and includes trigger keywords
- [ ] `$ARGUMENTS` is used if the skill accepts input
- [ ] Instructions are clear, numbered for tasks, and under 500 lines
- [ ] No barrel files are created
- [ ] Supporting files (if any) are referenced from SKILL.md

## Step 7: Report

Tell the user:
1. The file path where the skill was created
2. How to invoke it: `/skill-name` or by asking naturally (if model-invocable)
3. Example invocation with sample arguments
4. Any supporting files that were created
