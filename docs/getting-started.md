# Getting Started with CHAOS

This guide walks you through installing CHAOS and working on your first task.

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- [Beads](https://github.com/steveyegge/beads) — the `bd` command
- [GitHub CLI](https://cli.github.com/) — the `gh` command (recommended)
- Git
- Bash 4+

## Step 1: Install Beads

Beads is required for CHAOS. Install it first:

```bash
go install github.com/steveyegge/beads/cmd/bd@latest
```

Verify it's installed:
```bash
bd --version
```

## Step 2: Install GitHub CLI

The GitHub CLI is needed for the PR workflow (`/review-feedback`):

```bash
# See https://cli.github.com/ for your platform
gh auth login
```

## Step 3: Clone the Framework

```bash
git clone https://github.com/beartosis/chaos.git ~/chaos
```

## Step 4: Install into Your Project

Navigate to your project and run the installer:

```bash
cd ~/my-project
~/chaos/install.sh
```

The installer will:
1. Verify Beads is installed
2. Check for GitHub CLI
3. Ask for confirmation
4. Install skill definitions and configuration
5. Create the learnings system
6. Install coding standards
7. Run verification

## Step 5: Work on a Task

Once ORDER assigns a task (as a Beads issue), start working:

```bash
claude /work <task-id>
```

This guides you through:
1. **Reading** the task, learnings, and standards
2. **Exploring** the codebase for context
3. **Planning** the approach
4. **Implementing** code with tests
5. **Self-checking** before pushing
6. **Creating** a draft PR

## Step 6: Address Review Feedback

After ORDER and GHA review your PR:

```bash
claude /review-feedback
```

This reads PR comments, addresses each one, and pushes fixes.

## Step 7: Capture Learnings

After merging:

```bash
claude /learn
```

This captures what you learned for future sessions.

## What Happens Next

- **ORDER reviews** your draft PR (subjective quality gate)
- **GHA automated review** runs when PR is marked ready
- **You address comments** with `/review-feedback` (same session)
- **PR merges** when both reviews pass
- **Learnings accumulate** in `.chaos/learnings.md`
- **Patterns get promoted** to `standards/` over time

## Tips

1. **Always read learnings first** — `.chaos/learnings.md` has notes from past sessions
2. **Follow standards** — Check `standards/` for established patterns
3. **Minimal changes** — Only change what the task requires
4. **Write tests alongside code** — Not after
5. **Update Beads as you work** — `bd update <id> --note "..."`

## Next Steps

- Read [Architecture](architecture.md) to understand how CHAOS works
- Read [CHAOS-VISION.md](CHAOS-VISION.md) for the design philosophy
- Read [Best Practices](best-practices.md) for usage tips
