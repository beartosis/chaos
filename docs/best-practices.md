# CHAOS Best Practices & Claude Compatibility

This document analyzes CHAOS's design against Claude Code best practices and provides guidance for optimal usage.

## Architecture Alignment

### Why CHAOS Skills Run Inline (Not `context: fork`)

Claude Code's `context: fork` pattern runs skills in isolated subagent contexts. CHAOS intentionally does **not** use this pattern for orchestration skills. Here's why:

**Critical Limitation**: Subagents cannot spawn other subagents.

Since `/orchestrate` and `/create-spec` coordinate multiple agents (scout, spec-reviewer, explore, plan, implement, verifier, code-reviewer), they must run inline in the main conversation where subagent spawning is permitted.

| Skill | Spawns Agents? | Can Use `context: fork`? |
|-------|---------------|-------------------------|
| `/orchestrate` | Yes (6+ agents) | No |
| `/create-spec` | Yes (scout, spec-reviewer) | No |
| `/review-spec` | Yes (spec-reviewer) | No |
| `/coding-standards` | No | Could, but unnecessary |

**When `context: fork` IS appropriate**:
- Read-only research skills that don't coordinate agents
- Single-task isolated execution
- Skills that benefit from clean context isolation

**CHAOS's pattern is correct** - orchestration requires main conversation access.

---

## Agent Definitions

CHAOS's agents (`.claude/agents/*.md`) are standard Claude Code subagents:

```yaml
---
name: explore
description: Fast codebase exploration
model: haiku
allowed-tools: Read, Grep, Glob, Bash, WebFetch, WebSearch
---
```

This matches Claude's expected format exactly.

### Tool Restrictions: CLI vs SDK

**Important**: The `allowed-tools` frontmatter only works with Claude Code CLI.

| Context | Tool Restrictions |
|---------|-------------------|
| Claude Code CLI | Frontmatter `allowed-tools` works |
| Claude Agent SDK | Must use `allowedTools` in query config |

**SDK Example**:
```python
options = ClaudeAgentOptions(
    cwd="/path/to/project",
    setting_sources=["user", "project"],
    allowed_tools=["Read", "Grep", "Glob"]  # SDK-level restriction
)
```

---

## Background Agent Execution

### The Pattern

CHAOS uses `run_in_background: true` for all agent launches:

```
Task(explore, run_in_background: true):
  Issue: [issue-id]
  ...
```

This is a valid Claude Code feature. Background agents:
1. Run concurrently while the main conversation continues
2. Auto-inherit parent permissions (auto-deny unpermitted actions)
3. Notify on completion with their output
4. Cannot use MCP tools

### Timeout Handling

Background agents may hang in rare cases. Recommendations:

1. **Session-level timeout**: Set `CLAUDE_CODE_MAX_TASK_DURATION_MS` environment variable
2. **Manual recovery**: If an agent appears stuck:
   - Check `/tasks` for running agents
   - Use `Ctrl+C` to interrupt
   - Resume the conversation and retry
3. **Watchdog hook** (advanced): Add a `SubagentStart` hook that spawns a timeout monitor

See [patterns.md](../templates/.claude/skills/orchestrate/patterns.md) for detailed guidance.

---

## Context Management

### The 500-Token Guideline

All agents are instructed to return summaries under 500 tokens. This is **guidance, not enforcement**.

**Why this matters**:
- Orchestrator receives summaries from 6+ agents
- Detailed output would bloat context rapidly
- Full details persist in Beads issues and Git

**If summaries grow too large**:
- Agent responses may exceed the guideline
- Context will fill faster
- Consider more frequent Beads syncing

**Acceptable range**: 500-1000 tokens is fine for complex summaries. The goal is keeping the orchestrator lean, not strict enforcement.

---

## Beads Dependency

CHAOS requires Beads (`bd` CLI) for:
- Issue tracking (`bd create`, `bd show`, `bd close`)
- Note persistence (`bd update --notes`)
- Design storage (`bd update --design`)
- Synchronization (`bd sync`)

### Graceful Handling

The installer checks for Beads and offers to install if missing. If Beads becomes unavailable during a session:

1. **Preflight hook** (`skill_start`) runs `preflight.sh`
2. **Session hooks** run `bd prime` with `|| true` (fails silently)
3. Agents that can't reach Beads will report errors

**Fallback mode** (not yet implemented):
- Future versions may support local file-based fallback
- Current version requires Beads

---

## Hook Configuration

### CHAOS's Installed Hooks

`settings.local.json` configures:

| Event | Matcher | Action |
|-------|---------|--------|
| `PreCompact` | (all) | `bd prime` |
| `SessionStart` | (all) | `bd prime` |
| `SubagentStart` | `explore\|plan\|implement\|verifier\|code-reviewer` | Log + `bd prime` |
| `SubagentStop` | `implement` | `bd sync --flush-only` |

### Potential Conflicts

If your project already has hooks in `.claude/settings.local.json`:

1. **CHAOS installation backs up existing file** to `CLAUDE.md.backup`
2. **Manual merge may be needed** for custom hooks
3. **Order is not guaranteed** when hooks from multiple sources run

**Recommendations**:
- Review `settings.local.json` after installation
- Test hooks don't interfere with each other
- Use specific matchers to scope hooks narrowly

### Adding Custom Hooks

To add hooks without conflicting:

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "implement",
        "hooks": [{ "type": "command", "command": "bd sync --flush-only" }]
      },
      {
        "matcher": "your-custom-agent",
        "hooks": [{ "type": "command", "command": "./your-script.sh" }]
      }
    ]
  }
}
```

Use distinct matchers for different hooks.

---

## SDK Usage Guide

### Required Configuration

```python
from claude_agent_sdk import query, ClaudeAgentOptions

options = ClaudeAgentOptions(
    cwd="/path/to/project",
    setting_sources=["user", "project"],  # REQUIRED to load skills/agents
    allowed_tools=["Skill", "Task", "Read", "Write", "Edit", "Bash", "Grep", "Glob"]
)
```

**Common mistake**: Forgetting `setting_sources` means skills won't load.

### Invoking Skills

```python
async for message in query(
    prompt="/orchestrate 2025-01-25-my-feature",
    options=options
):
    print(message)
```

### Tool Restrictions per Agent

Since frontmatter `allowed-tools` doesn't apply in SDK:

```python
# For read-only exploration
explore_options = ClaudeAgentOptions(
    setting_sources=["user", "project"],
    allowed_tools=["Read", "Grep", "Glob", "Bash"]
)

# For implementation
implement_options = ClaudeAgentOptions(
    setting_sources=["user", "project"],
    allowed_tools=["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
)
```

---

## Troubleshooting

### Agent Not Using Correct Tools

**Symptom**: Agent uses Write when it should be read-only
**Cause**: Using SDK without explicit `allowedTools`
**Fix**: Add tool restrictions to SDK configuration

### Skills Not Found

**Symptom**: `/orchestrate` not recognized
**Cause**: Missing `setting_sources` in SDK, or skill files not installed
**Fix**:
1. Verify `.claude/skills/orchestrate/SKILL.md` exists
2. Add `setting_sources=["user", "project"]` to SDK config

### Beads Commands Fail

**Symptom**: `bd: command not found`
**Cause**: Beads not installed
**Fix**: Run `go install github.com/steveyegge/beads/cmd/bd@latest` or re-run `~/chaos/install.sh`

### Context Growing Too Fast

**Symptom**: Conversation compacts frequently during orchestration
**Cause**: Agent summaries exceeding guidelines
**Fix**:
1. Review agent outputs for verbosity
2. Ensure agents are writing details to Beads
3. Consider breaking large specs into smaller ones

### Hooks Not Running

**Symptom**: `bd prime` not executing
**Cause**: Hook configuration not loaded
**Fix**: Check `.claude/settings.local.json` exists and is valid JSON

---

## Comparison: CHAOS vs Claude Patterns

| Feature | Claude Standard | CHAOS Implementation | Status |
|---------|-----------------|---------------------|--------|
| Skill frontmatter | YAML with `description` | Correct | Good |
| `disable-model-invocation` | For side-effect skills | Used on orchestrate/create-spec | Good |
| SKILL.md size | < 500 lines | ~200 lines | Good |
| Supporting files | Separate from SKILL.md | `patterns.md` companion | Good |
| Agent definitions | `.claude/agents/*.md` | Correct format | Good |
| `context: fork` | For isolated execution | Not used (correctly) | Good |
| `allowed-tools` | CLI only | Documented limitation | Good |
| Background execution | `run_in_background` | Used throughout | Good |

**Overall**: CHAOS aligns well with Claude Code best practices. The main consideration is SDK compatibility for tool restrictions.
