# CHAOS Architecture

## Overview

CHAOS (Claude Handling Agentic Orchestration System) is a spec-driven orchestration framework that coordinates multiple AI agents to transform specifications into working code.

## Core Concepts

### Specs

A spec is a markdown file describing what you want to build:
- **Goal**: What we're achieving
- **Requirements**: What must be done
- **Constraints**: What must not change
- **Acceptance Criteria**: How we know it's done
- **Out of Scope**: What we're not doing

### Agents

Specialized AI agents handle different phases:

```
┌─────────────────┐
│  spec-reviewer  │  Validates spec completeness
└────────┬────────┘
         ↓
┌─────────────────┐
│    explore      │  Investigates codebase
└────────┬────────┘
         ↓
┌─────────────────┐
│     plan        │  Designs implementation
└────────┬────────┘
         ↓
┌─────────────────┐
│   implement     │  Writes code
└────────┬────────┘
         ↓
┌─────────────────┐
│    verifier     │  Checks acceptance criteria
└────────┬────────┘
         ↓
┌─────────────────┐
│  code-reviewer  │  Quality gate
└─────────────────┘
```

### Beads Integration

All agents follow a Beads-first workflow:
- Read task context from beads issues (`bd show`)
- Write discoveries to notes (`bd update --notes`)
- Write plans to design field (`bd update --design`)
- Close issues on completion (`bd close --reason`)

## Execution Flow

### Phase 0: Preflight

Before any work begins, the orchestrator runs preflight checks:

```bash
.claude/scripts/preflight.sh
```

If Beads is not installed, the preflight fails and suggests installation.

### Phase 1: Spec Review

The `spec-reviewer` agent validates:
- All sections are present
- Requirements are specific
- Acceptance criteria are testable
- No conflicting constraints

If issues are found, it asks clarifying questions via `AskUserQuestion`.

### Phase 2: Work Breakdown

The orchestrator analyzes the spec and creates beads issues with dependencies:

```bash
bd create --title="Explore: area" --type=task
bd create --title="Plan: feature" --type=task
bd create --title="Implement: component" --type=task
bd dep add [implement-id] [plan-id]
bd dep add [plan-id] [explore-id]
```

Example breakdown:
```
Explore: Understand existing greeting patterns
    ↓
Plan: Design greeting component
    ↓
Implement: Create greeting feature
    ↓
Verify: Check acceptance criteria
```

### Phase 3: Execution Pipeline

For each work unit:

1. **Explore** (Haiku) - Fast codebase investigation
   - Finds relevant files
   - Identifies patterns to follow
   - Notes potential challenges

2. **Plan** (Sonnet) - Designs approach
   - Lists files to modify
   - Orders changes
   - Specifies testing approach

3. **Implement** (Opus) - Writes code
   - Follows the plan
   - Matches existing patterns
   - Adds tests

### Phase 4: Verification

Two-stage quality gate:

1. **Verifier** (Haiku) - Quick checks
   - Acceptance criteria met?
   - Tests pass?
   - Files exist?

2. **Code Reviewer** (Sonnet) - Deep review
   - Has tests?
   - Follows patterns?
   - No security issues?
   - Minimal changes?

### Phase 5: Dispute Resolution

On third failure, the `dispute-resolver` agent decides:
- **RETRY**: Try a different approach
- **ESCALATE**: Get human input

## Context Management

### The 500-Token Rule

All agents return summaries under 500 tokens. This prevents context bloat in the main orchestrator.

### Background Execution

Agents run with `run_in_background: true`. The orchestrator:
- Launches agent
- Waits for notification
- Receives summary only

### Where Details Go

| Information | Destination |
|-------------|-------------|
| Exploration findings | Beads notes |
| Implementation plan | Beads design field |
| Code changes | Git |
| Test results | Summary in return |

## Template System

### Variable Substitution

Templates use `${VARIABLE}` syntax:
- `${CHAOS_ROOT}` - Framework location
- `${PROJECT_ROOT}` - Project location

## File Structure

```
project/                    # Your project
├── .claude/
│   ├── agents/             # Agent definitions
│   ├── skills/             # Skill definitions
│   ├── scripts/
│   │   └── preflight.sh    # Tooling checks
│   └── settings.local.json # Claude Code config
├── specs/                  # Your specifications
├── .CHAOS/
│   ├── framework_path      # Points to ~/chaos
│   └── version             # Configuration
└── CLAUDE.md               # Project instructions
```

## Configuration Schemas

### Agent vs Skill Frontmatter

Agents and skills use different YAML frontmatter schemas:

**Agent definitions** (`.claude/agents/*.md`):
```yaml
---
name: implement
description: Implements features following plans
model: opus
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---
```

**Skill definitions** (`.claude/skills/*/SKILL.md`):
```yaml
---
name: orchestrate
description: Runs the spec-to-completion workflow
allowed-tools: Read, Grep, Glob, Bash, Task, TodoWrite
disable-model-invocation: true
argument-hint: "[spec-name]"
---
```

## SDK Compatibility

### Important Limitations

When using CHAOS workflows through the **Claude Agent SDK** (rather than Claude Code CLI directly):

#### Tool Restrictions

The `allowed-tools` frontmatter field in SKILL.md **only works with Claude Code CLI**. It does not apply when skills are invoked through the SDK.

**Workaround**: When using the SDK, control tool access through the main `allowedTools` option in your query configuration.

#### Loading Skills from Filesystem

By default, the SDK does not load filesystem settings. You must explicitly configure `setting_sources`:

```python
options = ClaudeAgentOptions(
    cwd="/path/to/project",
    setting_sources=["user", "project"],  # Required!
    allowed_tools=["Skill", ...]
)
```

### Recommended Usage

| Context | Recommendation |
|---------|----------------|
| Interactive development | Use Claude Code CLI (full feature support) |
| CI/CD automation | Use SDK with explicit `allowed_tools` |
| Programmatic orchestration | Use SDK, replicate tool restrictions in config |

## Hook Configuration

CHAOS installs hooks in `.claude/settings.local.json`:

| Event | Purpose |
|-------|---------|
| `PreCompact` | Prime Beads before context compaction |
| `SessionStart` | Prime Beads at session start |
| `SubagentStart` | Log and prime Beads when agents start |
| `SubagentStop` | Sync Beads after implement agent completes |

### Merging with Existing Hooks

If your project already has hooks, CHAOS's installation backs up your existing `settings.local.json`. You may need to manually merge custom hooks.

**Best practices**:
- Use specific matchers to scope hooks narrowly
- Test hook interactions after installation
- Review `settings.local.json` for duplicates

See [best-practices.md](best-practices.md) for detailed hook guidance.

## Further Reading

- [best-practices.md](best-practices.md) - Claude compatibility analysis and recommendations
- [writing-specs.md](writing-specs.md) - How to write effective specifications
- [getting-started.md](getting-started.md) - Installation and first run guide
