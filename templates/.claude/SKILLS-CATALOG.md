# CHAOS Skills Catalog

A guide to CHAOS v2 skills — the single-developer workflow.

## Quick Reference

| Skill | Command | Purpose |
|-------|---------|---------|
| [Work](#work) | `/work <task-id>` | Execute task from start to draft PR |
| [Plan](#plan) | `/plan <goal>` | Explore codebase and design implementation approach |
| [Self-Check](#self-check) | `/self-check` | Pre-push quality gate |
| [Review Feedback](#review-feedback) | `/review-feedback` | Address PR review comments |
| [Learn](#learn) | `/learn` | Post-task reflection and pattern promotion |

---

## Workflow Overview

```
    ORDER assigns task
         │
         ▼
    ┌──────────┐
    │  /work   │  Read task → Explore → Plan → Implement → Test
    └────┬─────┘
         │
         ▼
    ┌──────────────┐
    │ /self-check  │  Run tests, review diff, verify criteria
    └──────┬───────┘
           │
           ▼
    Push branch → Draft PR
           │
           ▼
    ORDER reviews → marks ready
           │
           ▼
    GHA automated review
           │
           ▼
    ┌──────────────────┐
    │ /review-feedback │  Read comments → Fix → Push → Respond
    └──────┬───────────┘
           │
           ▼
    PR approved → Merge
           │
           ▼
    ┌──────────┐
    │  /learn  │  Reflect → Capture → Promote patterns
    └──────────┘
```

---

## Skills Detail

### Work

**Command**: `/work <task-id>`

**Purpose**: The flagship skill. Execute a complete task from reading the assignment to creating a draft PR.

**When to Use**:
- Starting a new task assigned by ORDER
- Picking up a Beads issue to work on

**How It Works**:
1. **Read** — Load task from Beads, read learnings, read standards
2. **Explore** — Investigate codebase for patterns, find files to modify
3. **Plan** — Break work into steps using TodoWrite
4. **Implement** — Write production-grade code with tests
5. **Self-Check** — Run /self-check before pushing
6. **Ship** — Create branch, commit, push, open draft PR

**Context Used**: Beads task, `.chaos/learnings.md`, `standards/`

---

### Plan

**Command**: `/plan <goal>`

**Purpose**: Read-only exploration skill. Understand the goal, explore the codebase, and design an implementation approach before writing code.

**When to Use**:
- Before starting a complex task
- When multiple implementation approaches are possible
- When you want to understand the scope before committing

**How It Works**:
1. **Understand** — Parse the goal and constraints
2. **Explore** — Read-only codebase investigation
3. **Design** — Create a structured implementation plan
4. **Present** — Show the plan with file list, execution order, and risks
5. **Wait** — Get user approval before implementing

**Output**: Structured plan with changes table, execution order, testing strategy, and risks

---

### Self-Check

**Command**: `/self-check`

**Purpose**: Pre-push quality gate. Catches issues before they reach review.

**When to Use**:
- Before pushing code (called automatically by /work)
- After making changes to verify quality

**Checklist**:
- [ ] Test suite passes
- [ ] No hardcoded values, secrets, or debug code
- [ ] Error handling is complete
- [ ] Follows existing codebase patterns
- [ ] Changes are scoped to the task
- [ ] New behavior has tests
- [ ] Acceptance criteria are met

**Output**: `READY TO PUSH` or `NEEDS FIXES` with specific items

---

### Review Feedback

**Command**: `/review-feedback`

**Purpose**: Address PR review comments from ORDER and GHA automated review.

**When to Use**:
- After ORDER reviews your draft PR
- After GHA automated review leaves comments
- Whenever PR has unresolved review comments

**How It Works**:
1. **Read** — Fetch PR comments via `gh pr view`
2. **Categorize** — Actionable fixes, questions, suggestions
3. **Fix** — Address each actionable comment
4. **Test** — Run test suite after fixes
5. **Push** — Commit and push fixes
6. **Respond** — Comment on PR summarizing what was addressed

---

### Learn

**Command**: `/learn`

**Purpose**: Post-task reflection. Capture what you learned and promote proven patterns to standards.

**When to Use**:
- After merging a PR
- After completing a significant task
- When you've discovered something future sessions should know

**How It Works**:
1. **Reflect** — What worked, what surprised you, what to avoid
2. **Capture** — Append observations to `.chaos/learnings.md`
3. **Scan** — Look for patterns appearing 3+ times
4. **Promote** — Move proven patterns to `standards/`
5. **Archive** — Move promoted entries to `.chaos/learnings-archive/`

**The Learning Loop**:
```
Session observations → learnings.md → (3+ occurrences) → standards/
                                                              ↓
                                    Future sessions read standards first
```

---

## Background Skills

These are loaded automatically by Claude, not invoked directly.

| Skill | Purpose |
|-------|---------|
| `coding-standards` | References `standards/` for code patterns and style |
| `testing-guide` | References `standards/` for testing philosophy and patterns |

---

## Security Profiles

| Profile | Access Level | Skills |
|---------|--------------|--------|
| `read_only` | Read files only | self-check, coding-standards, testing-guide |
| `standard` | Read/write within project | learn |
| `elevated` | Full development access | work, review-feedback |

---

## See Also

- [Standards Index](standards/standards.yml) - Coding standards
- [Learnings](.chaos/learnings.md) - Accumulated observations
- [Architecture](docs/architecture.md) - System design
