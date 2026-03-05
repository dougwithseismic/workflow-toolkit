---
name: skill-and-agent-factory
description: Creates skills, agents, or both together. A unified factory for building Claude Code extensions with proper configuration, best practices, and coordinated workflows.
argument-hint: <skill|agent|both> <name> <description of what to build>
disable-model-invocation: true
---

# Skill and Agent Factory

You are a factory for creating Claude Code extensions based on the user's request: **$ARGUMENTS**

This factory can create:
- **A skill** (reusable prompt/workflow invoked via `/skill-name`)
- **An agent** (specialized subagent with its own context, tools, and permissions)
- **Both together** (a skill that delegates to a coordinated agent, or a skill-agent pair that work in tandem)

## Step 1: Determine What to Build

Parse `$ARGUMENTS` to determine the creation mode:

| First token | Action |
|-------------|--------|
| `skill` | Create a skill only |
| `agent` | Create an agent only |
| `both` | Create a coordinated skill + agent pair |
| _(anything else)_ | Infer from context |

## Step 2: Research Phase

1. Check existing skills in `.claude/skills/` to avoid conflicts
2. Check existing agents in `.claude/agents/`
3. Review relevant codebase patterns if project-specific
4. Identify dependencies on existing skills/agents

## Step 3: Design Phase

| Choose Skill when... | Choose Agent when... | Choose Both when... |
|----------------------|----------------------|---------------------|
| Runs in main conversation context | Needs isolation | User-facing command that delegates to isolated agent |
| No special tool restrictions | Specific tools needed | Quick inline mode + thorough isolated mode |
| Reusable prompt or reference material | Verbose output would pollute context | Orchestration skill + execution agent |

### Coordination Patterns (when creating both)

**Pattern A: Skill delegates to agent** — Skill uses `context: fork` + `agent: <name>`
**Pattern B: Independent but complementary** — Skill for quick inline, agent for deep analysis
**Pattern C: Skill preloads into agent** — Agent uses `skills` field for domain knowledge

## Step 4: Create

### Skills -> `.claude/skills/<name>/SKILL.md`
Use the `/workflow-toolkit:create-skill` workflow.

### Agents -> `.claude/agents/<name>.md`
Use the `/workflow-toolkit:create-agent` workflow.

### Both -> Create agent first, then skill referencing it.

## Step 5: Validate and Report

Provide a summary with file paths, invocation instructions, example usage, and architecture notes for how extensions relate to each other.
