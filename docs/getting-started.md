# Getting Started with CHAOS

This guide walks you through installing CHAOS (Claude Handling Agentic Orchestration System) and running your first spec-driven workflow.

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- [Beads](https://github.com/steveyegge/beads) - the `bd` command
- Git
- Bash 4+

## Step 1: Install Beads

Beads is required for CHAOS. Install it first:

```bash
# From official source
go install github.com/steveyegge/beads/cmd/bd@latest
```

Verify it's installed:
```bash
bd --version
```

## Step 2: Clone the Framework

```bash
git clone https://github.com/beartosis/chaos.git ~/chaos
```

## Step 3: Install into Your Project

Navigate to your project and run the installer:

```bash
cd ~/my-project
~/chaos/install.sh
```

The installer will:
1. Verify Beads is installed
2. Ask for confirmation
3. Install agent definitions, skills, and configuration
4. Create the `specs/` directory
5. Run verification

## Step 4: Create Your First Spec

The recommended way to create specs is through interactive conversation:

```bash
claude /create-spec
```

This starts a guided conversation that:
1. Asks what you want to build
2. Explores your codebase for relevant patterns
3. Asks clarifying questions until requirements are clear
4. Generates a complete spec with context files
5. Validates the spec automatically

Example flow:
```
> /create-spec

What feature would you like to spec out?

> A user greeting feature that welcomes users by name

Let me explore your codebase... [scout finds patterns]

Questions:
1. How should the greeting be displayed? (modal, banner, inline?)
2. Where does the name come from? (input, stored, URL param?)
3. What if no name is available?

> Inline text, from user input, show "Hello, stranger!"

Creating spec...
✓ Created: specs/2025-01-25-user-greeting/SPEC.md
✓ Validation passed

Ready to orchestrate: /orchestrate 2025-01-25-user-greeting
```

## Step 5: Run Orchestration

```bash
claude /orchestrate 2025-01-25-user-greeting
```

Watch as CHAOS:
1. Reviews your spec for completeness
2. Creates beads issues with dependencies
3. Explores your codebase
4. Plans the implementation
5. Writes the code
6. Verifies against acceptance criteria
7. Reviews code quality

## What Happens Next

- **If everything passes**: You get a completion report with files modified and tests added.
- **If something fails**: The agent retries up to 3 times, then escalates to you.
- **If clarification needed**: You'll be asked questions during spec review.

## Tips for Good Specs

1. **Be specific** - "Handle errors gracefully" is vague; "Log errors and show user-friendly message" is specific.

2. **Make criteria testable** - "Fast" is not testable; "Responds within 200ms" is.

3. **Define boundaries** - The "Out of Scope" section prevents scope creep.

4. **One feature per spec** - Keep specs focused for better orchestration.

## Next Steps

- Read [Architecture](architecture.md) to understand how CHAOS works
- See [Writing Specs](writing-specs.md) for advanced patterns
