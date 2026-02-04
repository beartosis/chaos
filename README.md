# CHAOS

**Claude Handling Agentic Orchestration System** · v0.0.1

> **Early Release**: This is an initial release (v0.0.1). APIs and workflows may change as we iterate based on feedback.

Spec-driven agentic orchestration for Claude Code. Write specs, let agents handle the rest. CHAOS transforms natural language specifications into working code through a coordinated pipeline of specialized AI agents.

## Quick Start

```bash
# 1. Install Beads (required) - https://github.com/steveyegge/beads
go install github.com/steveyegge/beads/cmd/bd@latest

# 2. Clone the framework
git clone https://github.com/beartosis/chaos.git ~/chaos

# 3. Install into your project
cd ~/my-project
~/chaos/install.sh

# 4. Create and run your first spec
claude /create-spec
claude /orchestrate YYYY-MM-DD-my-feature
```

## How It Works

```
Human → Spec
         ↓
    /orchestrate (main skill)
         ↓
    Spec Reviewer ←→ Human (questions)
         ↓
    Work Breakdown (beads issues)
         ↓
    Explore → Plan → Implement → Verify → Review
         ↓ (on failure)
    Dispute Resolver → Retry or Escalate
```

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI
- [Beads](https://github.com/steveyegge/beads) - issue tracking (`bd` command) - Official repo: [steveyegge/beads](https://github.com/steveyegge/beads)
- Git
- Bash 4+

### Installing Beads

```bash
# From official source
go install github.com/steveyegge/beads/cmd/bd@latest
```

## Installation

```bash
cd /path/to/your/project
~/chaos/install.sh
```

This creates:
- `.claude/` - Agent definitions, skills, and scripts
- `specs/` - Directory for your specifications
- `.CHAOS/` - Framework configuration
- `CLAUDE.md` - Project instructions for Claude

## Usage

### Creating Specs

```bash
# Interactive guided creation
claude /create-spec

# From a GitHub issue
claude /create-spec --from-issue https://github.com/org/repo/issues/123
```

This starts an interactive conversation that:
1. Asks what you want to build
2. Explores your codebase for patterns
3. Asks clarifying questions
4. Generates a complete spec

### Analyzing Codebase Health

```bash
claude /analyze
```

Identifies tech debt, test gaps, security issues, and improvement opportunities. Optionally create specs from findings:

```bash
claude /analyze --create-spec
```

### Running Orchestration

```bash
claude /orchestrate YYYY-MM-DD-my-feature
```

The orchestrator will:
1. **Review** - Validate spec completeness
2. **Break down** - Create beads issues with dependencies
3. **Execute** - Run explore → plan → implement pipeline
4. **Verify** - Check acceptance criteria
5. **Review code** - Quality gate before completion

### Handling Failures

- **Automatic retry**: Up to 3 attempts per work unit
- **Dispute resolution**: On repeated failures, decides retry vs escalate
- **Human escalation**: Complex issues go back to you

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| spec-architect | Opus | Transforms intent into well-formed specs |
| spec-reviewer | Sonnet | Validates spec completeness |
| code-explorer | Haiku | Codebase health analysis |
| scout | Haiku | Pattern discovery for spec creation |
| explore | Haiku | Fast codebase investigation |
| plan | Sonnet | Designs implementation approach |
| implement | Opus | Writes code |
| verifier | Haiku | Checks acceptance criteria |
| code-reviewer | Sonnet | Quality gate |
| dispute-resolver | Sonnet | Handles failures |
| beads-helper | Haiku | Issue tracking commands |
| tooling-setup | Haiku | Diagnoses tooling issues |

## Project Structure

```
CHAOS/                       # Framework (you clone this)
├── install.sh              # Main installer
├── lib/                    # Framework utilities
│   ├── beads_check.sh      # Verifies Beads is installed
│   ├── template_engine.sh  # Processes templates
│   └── verify.sh           # Post-install verification
├── templates/              # Files installed into projects
│   ├── .claude/
│   │   ├── agents/         # Agent definitions
│   │   ├── skills/         # Skill definitions
│   │   └── scripts/        # Helper scripts
│   ├── specs/              # Example spec
│   └── CLAUDE.md.tmpl      # Project instructions
└── docs/                   # Documentation
```

## Philosophy

**Human writes specs** - Clear, testable requirements in natural language.

**Agents handle execution** - Review, plan, implement, verify in a coordinated pipeline.

**Minimal context** - Agents return summaries (<500 tokens), detailed work goes to beads issues and git.

**Beads-first workflow** - All agents read from and write to beads issues, creating a persistent record of work.

## Autonomous Operation

CHAOS is designed with humans in the loop. For fully autonomous operation (batch processing, overnight runs, CI/CD), see [ORDER](https://github.com/beartosis/order).

ORDER is an optional plugin that intercepts CHAOS's human escalation points, enabling autonomous execution with safety limits.

## Documentation

- [Vision Document](docs/CHAOS-VISION.md) - Full architecture and design philosophy
- [Writing Specs](docs/writing-specs.md) - How to write effective specifications
- [Architecture](docs/architecture.md) - System design and agent coordination

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

MIT License - see LICENSE file.
