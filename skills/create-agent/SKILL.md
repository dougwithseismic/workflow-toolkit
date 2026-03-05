---
name: create-agent
description: Creates a new Claude Code custom subagent configuration. Guides you through designing agent scope, tools, permissions, hooks, and system prompts.
argument-hint: <agent-name> <brief description of the agent's purpose>
disable-model-invocation: true
---

# Create a New Claude Code Subagent

You are creating a new custom subagent based on the user's request: **$ARGUMENTS**

Follow the steps below precisely to produce a production-quality subagent definition.

## Step 1: Parse the Request

Extract from `$ARGUMENTS`:
- **Agent name**: The first token (use kebab-case, lowercase letters and hyphens only). If the user did not provide one, derive a concise name from the description.
- **Purpose**: Everything after the name describes what the agent should do.

## Step 2: Determine Scope and Placement

| Scope | Path | When to choose |
|-------|------|----------------|
| Project | `.claude/agents/<agent-name>.md` | Agent is specific to this codebase and should be shared via version control. |
| Personal | `~/.claude/agents/<agent-name>.md` | Agent is useful across all projects but not team-shared. |

Default to **project scope** (`.claude/agents/<agent-name>.md`) unless the user explicitly says "personal" or "global".

## Step 3: Design the Agent Configuration

### 3a: Choose the Model

| Model | Best for |
|-------|----------|
| `haiku` | Fast, read-only tasks like code search, exploration, quick lookups. Low cost. |
| `sonnet` | Balanced capability and speed. Good for analysis, reviews, moderate complexity. |
| `opus` | Maximum capability. Complex reasoning, architecture decisions, nuanced analysis. |
| `inherit` | Uses the same model as the main conversation. Default if omitted. |

### 3b: Select Tools

Choose from Claude Code's available tools. Only grant what the agent needs:

**Read-only tools** (safe for exploration):
- `Read` - Read file contents
- `Grep` - Search file contents
- `Glob` - Find files by pattern

**Modification tools** (grant with care):
- `Write` - Write new files
- `Edit` - Modify existing files
- `Bash` - Execute shell commands

**Special tools**:
- `Agent(type)` - Spawn subagents of a specific type
- MCP server tools (reference configured server names)

### 3c: Configure Permission Mode

| Mode | Behavior | Use when |
|------|----------|----------|
| `default` | Standard permission prompts | Interactive tasks needing oversight |
| `acceptEdits` | Auto-accept file edits | Trusted code modification tasks |
| `dontAsk` | Auto-deny permission prompts (allowed tools still work) | Background tasks that should not interrupt |
| `bypassPermissions` | Skip all permission checks | Fully trusted automation (use with extreme caution) |
| `plan` | Read-only exploration mode | Research and planning only |

### 3d: Consider Advanced Options

**Persistent Memory** (`memory` field):
- `user` - Remember learnings across all projects
- `project` - Project-specific knowledge, shareable via version control
- `local` - Project-specific, not version controlled

**Preloaded Skills** (`skills` field):
- List skill names to inject their full content into the agent's context at startup

**Max Turns** (`maxTurns`), **Background** (`background: true`), **Isolation** (`isolation: worktree`), **Hooks** (`hooks` for PreToolUse/PostToolUse/Stop)

## Step 4: Compose the Frontmatter

```yaml
---
name: <agent-name>
description: <when Claude should delegate to this agent>
tools: <appropriate tool list>
model: <haiku|sonnet|opus|inherit>
permissionMode: <appropriate mode>
maxTurns: <optional limit>
skills: <optional list of skills to preload>
memory: <optional: user|project|local>
---
```

## Step 5: Write the System Prompt

The markdown body after frontmatter becomes the agent's system prompt.

```markdown
You are a [role description].

When invoked:
1. [Gather context]
2. [Analyze/process]
3. [Take action]
4. [Verify results]

[Domain guidelines, output format, constraints]
```

## Step 6: Write the File

1. Create the agents directory if needed: `mkdir -p .claude/agents`
2. Write the agent file to `<scope-path>/<agent-name>.md`

## Step 7: Validate and Report

Verify kebab-case naming, valid frontmatter, scoped tools, clear system prompt. Then tell the user the file path, how to invoke it, and example usage.
