# CHAOS: Claude Handling Autonomous Orchestration System

v0.0.2

A skill-driven framework for Claude Code that treats each conversation as a professional software developer. CHAOS provides workflow skills, coding standards, and a self-reinforcing learning system that accumulates wisdom across sessions.

## Quick Start

```bash
# 1. Install Beads (required) - https://github.com/steveyegge/beads
go install github.com/steveyegge/beads/cmd/bd@latest

# 2. Install GitHub CLI (recommended) - https://cli.github.com/
# Required for PR workflow (/review-feedback)

# 3. Clone the framework
git clone https://github.com/beartosis/chaos.git ~/chaos

# 4. Install into your project
cd ~/my-project
~/chaos/install.sh

# 5. Start working on a task
claude /work <task-id>
```

## How It Works

```
    /work <task-id>
         ↓
    Read task + learnings + standards
         ↓
    Explore → Plan → Implement → Test
         ↓
    /self-check (pre-push quality gate)
         ↓
    Push branch → Create draft PR
         ↓
    GHA automated review
         ↓
    /review-feedback (address comments)
         ↓
    Merge → /learn (capture observations)
```

## Requirements

| Tool | Purpose | Install |
|------|---------|---------|
| [Claude Code](https://claude.ai/code) | CLI for Claude | See website |
| [Beads](https://github.com/steveyegge/beads) | Issue tracking (`bd` command) | `go install github.com/steveyegge/beads/cmd/bd@latest` |
| [GitHub CLI](https://cli.github.com/) | PR workflow (`gh` command) | See website |
| [jq](https://jqlang.github.io/jq/) | JSON processor | `brew install jq` / `apt install jq` |
| Git | Version control | Usually pre-installed |
| Bash 4+ | Shell | Usually pre-installed |

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| **Work** | `/work <task-id>` | Execute task from start to draft PR |
| **Plan** | `/plan <goal>` | Explore codebase and design an approach |
| **Self-Check** | `/self-check` | Pre-push quality gate |
| **Review Feedback** | `/review-feedback` | Address PR review comments |
| **Learn** | `/learn` | Post-task reflection and pattern promotion |

Plus two background reference skills: `coding-standards` and `testing-guide`.

## Installation

```bash
cd /path/to/your/project
~/chaos/install.sh

# For CI/scripts (no prompts)
~/chaos/install.sh --force
```

This creates:
- `.claude/` — Skill definitions, scripts, and configuration
- `.chaos/` — Learnings system and framework metadata
- `standards/` — Coding standards (evolves via `/learn`)
- `CLAUDE.md` — Project instructions for Claude

## The Learning Loop

CHAOS includes a self-reinforcing improvement system:

1. **During work**: Claude reads `.chaos/learnings.md` for notes from past sessions
2. **After tasks**: `/learn` captures observations about what worked, what didn't
3. **Pattern promotion**: When an observation appears 3+ times, it gets promoted to `standards/`
4. **Future sessions**: New conversations benefit from accumulated project wisdom

```
Session 1: "The codebase uses tRPC, not Express"  → learnings.md
Session 2: "Found tRPC routers in src/server/"     → learnings.md
Session 3: "API routes are all tRPC procedures"    → PROMOTED to standards/backend/patterns.md
Session 4+: Reads standards, knows to use tRPC from the start
```

## Key Rules

CHAOS enforces several rules across all skills:

- **Read before you write** — always explore existing code before modifying it
- **Minimal diffs** — only change what the task requires
- **Tests alongside code** — write tests as you implement, not after
- **Beads-first** — update Beads issues as you work for persistent state
- **No attribution** — no Co-Authored-By, Signed-off-by, or other co-author lines in commits

## Security

Skills operate under tiered security profiles:

| Profile | Level | Purpose |
|---------|-------|---------|
| `read_only` | 1 | Reference skills, verification |
| `standard` | 2 | Learning and documentation |
| `elevated` | 3 | Full development workflow |

The elevated tier scopes Bash access to the project directory and blocks dangerous commands (`rm -rf /`, `sudo`, `curl | sh`, etc.).

## Project Structure

```
CHAOS/                          # Framework (you clone this)
├── install.sh                  # Main installer
├── uninstall.sh                # Clean uninstaller
├── lib/                        # Framework utilities
│   ├── beads_check.sh          # Verifies Beads is installed
│   ├── template_engine.sh      # Processes templates
│   ├── verify.sh               # Post-install verification
│   └── skill-discovery.sh      # Skill query tool
├── templates/                  # Files installed into projects
│   ├── .claude/
│   │   ├── skills/             # Skill definitions
│   │   └── scripts/            # Helper scripts
│   ├── .chaos/                 # Learnings system
│   ├── standards/              # Coding standards
│   └── CLAUDE.md.tmpl          # Project instructions
└── docs/                       # Documentation
```

## Philosophy

**One conversation = one developer.** No subagents, no delegation, no background processes. Claude reads the task, plans the approach, writes the code, and pushes a PR — just like a human developer.

**Quality over speed.** A clean first draft saves more time than a fast sloppy one. Code should pass review on the first try.

**Learn from experience.** The learnings system means each session makes the next one better. Patterns get discovered, validated, and promoted to standards automatically.

**Beads-first workflow.** All work state lives in Beads issues, creating a persistent record that survives context compaction.

## Uninstallation

```bash
cd /path/to/your/project
~/chaos/uninstall.sh

# For CI/scripts (no prompts)
~/chaos/uninstall.sh --force
```

Learnings are preserved if they contain significant content.

## Autonomous Operation

CHAOS works with [ORDER](https://github.com/beartosis/order) (Optional Resource During Extended Runtimes) for autonomous multi-step execution. ORDER acts as the Engineering Lead:
- Decomposes specs into PR-sized tasks with Beads Issue Contracts
- Executes tasks sequentially, merging each PR before starting the next
- Manages the full PR lifecycle: rebase, GHA checks, review feedback, merge
- Hands off between ORDER instances via structured YAML for long-running roadmaps

See [ORDER](https://github.com/beartosis/order) for details.

## Documentation

- [Architecture](docs/architecture.md) — System design and skill workflow
- [Vision Document](docs/CHAOS-VISION.md) — Design philosophy
- [Getting Started](docs/getting-started.md) — Installation and first task
- [Best Practices](docs/best-practices.md) — Usage patterns and tips

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

MIT — see [LICENSE](LICENSE) file.
