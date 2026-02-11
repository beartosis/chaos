# CHAOS Architecture

## Overview

CHAOS (Claude Handling Autonomous Orchestration System) is a skill-driven framework that treats each Claude Code conversation as a professional software developer. Instead of coordinating multiple agents, CHAOS provides workflow skills that guide a single conversation through the complete development lifecycle.

## Core Concepts

### Single Developer Paradigm

Each CHAOS conversation is one developer working on one task:
- Reads the task assignment and accumulated learnings
- Explores the codebase to understand context
- Plans the approach
- Implements production-grade code with tests
- Self-reviews before pushing
- Creates a PR and addresses review feedback
- Captures learnings for future sessions

No subagents. No delegation. No background processes.

### Skills as Workflow Guides

Skills are markdown documents that guide Claude through multi-step workflows:

```
/work <task-id>      → Full task lifecycle
/self-check          → Pre-push quality verification
/review-feedback     → Address PR review comments
/learn               → Post-task reflection and pattern promotion
```

### Beads Integration

Beads provides persistent work state:
- Read task context: `bd show <task-id>`
- Track progress: `bd update <id> --note "..."`
- Close completed work: `bd close <id>`
- Survives context compaction via `bd prime`

### Learning System

A self-reinforcing loop that accumulates project wisdom:

```
Observations → .chaos/learnings.md → (3+ occurrences) → standards/
                                                              ↓
                                    Future sessions read standards first
```

## Workflow

### Complete Task Lifecycle

```
1. /work <task-id>
   ├── Read task from Beads
   ├── Read .chaos/learnings.md
   ├── Read standards/
   ├── Explore codebase (Grep, Glob, Read)
   ├── Plan approach (TodoWrite)
   ├── Implement code + tests
   ├── /self-check
   ├── Create branch, commit, push
   └── Create draft PR (gh pr create --draft)

2. ORDER reviews draft PR
   └── Marks ready-for-review when satisfied

3. GHA automated Claude review
   └── Leaves review comments on PR

4. /review-feedback
   ├── Read PR comments (gh pr view)
   ├── Address each comment
   ├── Run tests
   ├── Push fixes
   └── Respond on PR

5. PR approved → Merge
   └── gh pr merge --squash

6. /learn
   ├── Reflect on what worked
   ├── Capture observations
   ├── Scan for promotable patterns
   └── Promote to standards/
```

### PR Review Flow

```
CHAOS pushes draft PR
         ↓
ORDER reviews (subjective quality gate)
         ↓ approves
PR marked ready-for-review
         ↓
GHA automated Claude review (PR comments)
         ↓
CHAOS /review-feedback (same session, full context)
         ↓ addresses all comments
Both reviews pass → Merge
```

## Template System

### Variable Substitution

Templates use `${VARIABLE}` syntax:
- `${CHAOS_ROOT}` — Framework location
- `${PROJECT_ROOT}` — Project location

### Template vs Non-Template Files

- `.tmpl` files are processed by the template engine (variable substitution)
- `.md` files are copied as-is
- Skills that reference `$ARGUMENTS` use `.tmpl` extension

## File Structure

```
project/                        # Your project
├── .claude/
│   ├── skills/
│   │   ├── work/               # Task execution workflow
│   │   ├── self-check/         # Pre-push quality gate
│   │   ├── learn/              # Learning and pattern promotion
│   │   ├── review-feedback/    # PR review handler
│   │   ├── coding-standards/   # Standards reference (background)
│   │   ├── testing-guide/      # Testing reference (background)
│   │   └── index.yml           # Skill registry
│   ├── scripts/
│   │   └── preflight.sh        # Tooling checks
│   ├── settings.local.json     # Claude Code hooks
│   └── SKILLS-CATALOG.md       # Skill documentation
├── .chaos/
│   ├── framework/              # Framework configuration
│   │   ├── framework_path      # Points to ~/chaos
│   │   ├── version             # Configuration
│   │   └── skill-registry.json # Machine-readable skill registry
│   ├── learnings.md            # Accumulated observations
│   └── learnings-archive/      # Archived promoted observations
├── standards/                  # Coding standards
│   ├── standards.yml           # Index
│   ├── global/                 # Universal standards
│   ├── backend/                # Backend-specific
│   ├── frontend/               # Frontend-specific
│   └── testing/                # Testing standards
└── CLAUDE.md                   # Project instructions
```

## Hook Configuration

CHAOS installs hooks in `.claude/settings.local.json`:

| Event | Purpose |
|-------|---------|
| `PreCompact` | Prime Beads before context compaction |
| `SessionStart` | Prime Beads + load learnings at session start |

### Merging with Existing Hooks

If your project already has hooks, CHAOS backs up your existing `settings.local.json`. You may need to manually merge custom hooks.

## SDK Compatibility

### Loading Skills from Filesystem

The SDK does not load filesystem settings by default. Configure `setting_sources`:

```python
options = ClaudeAgentOptions(
    cwd="/path/to/project",
    setting_sources=["user", "project"],
    allowed_tools=["Skill", "Read", "Write", "Edit", "Bash", "Grep", "Glob"]
)
```

### Invoking Skills

```python
async for message in query(
    prompt="/work task-123",
    options=options
):
    print(message)
```

## Further Reading

- [CHAOS-VISION.md](CHAOS-VISION.md) — Design philosophy
- [getting-started.md](getting-started.md) — Installation and first task
- [best-practices.md](best-practices.md) — Usage patterns
