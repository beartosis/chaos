---
name: plan
description: Explore codebase and design an implementation approach before writing code
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# /plan — Design Before You Build

Read-only exploration skill. Understand the goal, explore the codebase, and present a structured implementation plan for user approval before writing any code.

## Arguments

Goal or task description: `$ARGUMENTS`

## Step 1: Understand the Goal

Parse the goal:
- What needs to be accomplished?
- What are the constraints?
- What does "done" look like?

If the goal is ambiguous, use `AskUserQuestion` to clarify before exploring.

## Step 2: Explore the Codebase

Use read-only tools to build a mental model:

```bash
# Find relevant files
# Use Grep and Glob to locate code related to the goal
```

Key questions:
- What existing code is related to this goal?
- What patterns and conventions does the codebase use?
- What files will need modification?
- What tests exist for the affected areas?
- Are there potential side effects?

## Step 3: Design the Approach

Based on exploration, design an implementation approach:

1. **Strategy**: High-level approach (extend existing, refactor, new module, etc.)
2. **File changes**: Which files to modify/create, in what order
3. **Dependencies**: What must happen first
4. **Risk areas**: What could go wrong, what to watch for
5. **Testing strategy**: How to verify the changes work

## Step 4: Present the Plan

Output a structured plan:

```markdown
## Plan: [Goal Summary]

### Approach
[1-2 sentence strategy description]

### Changes
| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | path/to/file | Modify | What changes and why |
| 2 | path/to/new  | Create | What it contains |

### Execution Order
1. [First step — what and why]
2. [Second step — what and why]
3. [Continue...]

### Testing
- [How to verify each change]
- [What tests to add/modify]

### Risks
- [Potential issue and mitigation]
```

## Step 5: Wait for Approval

Present the plan and wait for user confirmation before proceeding. The user may:
- **Approve**: Proceed with implementation (use `/work` or implement directly)
- **Modify**: Adjust the approach based on feedback
- **Reject**: Start over with a different strategy

## Key Principles

- **Read-only exploration.** Do not modify any files during planning.
- **Be thorough.** A good plan prevents wasted implementation effort.
- **Show your work.** Reference specific files and line numbers from your exploration.
- **Consider alternatives.** If multiple approaches exist, present them with trade-offs.
