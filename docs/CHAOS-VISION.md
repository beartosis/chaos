# CHAOS Vision: Single Developer with Accumulated Wisdom

**Claude Handling Autonomous Orchestration System**

---

## Vision

Software development is a craft. The best developers aren't fast — they're thorough. They read existing code before writing new code. They follow established patterns. They learn from experience and get better over time.

CHAOS embodies this philosophy. Each Claude Code conversation is a professional software developer who:
- **Reads before writing** — understands the codebase before making changes
- **Follows standards** — uses established patterns, doesn't reinvent
- **Learns from experience** — captures observations, promotes proven patterns
- **Produces reviewable work** — clean PRs that pass review on the first try

### From Orchestration to Craftsmanship

CHAOS v1 coordinated 12 specialized agents through a complex pipeline. It was architecturally interesting but operationally fragile — context leaked between agents, failures cascaded, and the overhead of coordination often exceeded the cost of the work itself.

CHAOS v2 takes a different approach: **one developer, one conversation, production-grade output.**

```
v1: 12 agents × coordination overhead × context management = complexity
v2: 1 developer × good habits × accumulated wisdom = quality
```

The insight is that a single Claude Code conversation, given the right guidance and accumulated project knowledge, produces better work than a team of specialized agents trying to coordinate.

---

## The Learning Loop

The most important innovation in CHAOS v2 is the self-reinforcing learning system.

### How It Works

```
Session 1: Developer works on auth feature
           Discovers: "The codebase uses Passport.js, not custom auth"
           → Captured in .chaos/learnings.md

Session 2: Developer works on user profiles
           Discovers: "Auth middleware is in src/middleware/auth.ts"
           → Captured in .chaos/learnings.md

Session 3: Developer works on API keys
           Discovers: "All auth flows go through Passport strategies"
           → Captured in .chaos/learnings.md
           → PATTERN DETECTED: 3 observations about Passport.js
           → PROMOTED to standards/backend/patterns.md:
             "Use Passport.js strategies for all authentication flows"

Session 4+: Developer reads standards first
            Knows to use Passport.js without rediscovering it
```

### Why This Matters

Each Claude Code session starts fresh — no memory of previous conversations. The learning system provides continuity:

- **Learnings** (`.chaos/learnings.md`) — short-term memory. Raw observations from recent sessions.
- **Standards** (`standards/`) — long-term memory. Proven patterns promoted from learnings.
- **Archive** (`.chaos/learnings-archive/`) — graduated observations that have been promoted.

The system gets smarter over time without any external training or fine-tuning. It's just structured note-taking with a promotion threshold.

---

## Skills

CHAOS v2 has four user-invocable skills and two background reference skills:

### `/work <task-id>` — The Developer

The flagship skill. Guides Claude through the complete task lifecycle:
1. Read the task, learnings, and standards
2. Explore the codebase
3. Plan the approach
4. Implement with tests
5. Self-check before pushing
6. Create a draft PR

This replaces the entire v1 pipeline (spec-reviewer → explore → plan → implement → verifier → code-reviewer) with a single, coherent workflow.

### `/self-check` — The Inner Critic

Pre-push quality gate. Before pushing code, Claude runs through a checklist:
- Tests pass
- No hardcoded values or secrets
- Follows existing patterns
- Changes are scoped to the task
- Acceptance criteria are met

This replaces v1's verifier and code-reviewer agents.

### `/review-feedback` — The Responsive Developer

When PR reviews come back (from ORDER or GHA), Claude reads the comments, addresses each one, and pushes fixes. Same session, full context — no handoff loss.

### `/learn` — The Reflective Practitioner

After completing a task, Claude reflects on what happened:
- What worked well?
- What was surprising?
- What should future sessions know?

Observations go to `learnings.md`. Patterns that appear 3+ times get promoted to `standards/`.

---

## Integration with ORDER

CHAOS is the developer. ORDER is the Engineering Lead.

| Role | CHAOS | ORDER |
|------|-------|-------|
| Task assignment | Receives tasks | Assigns tasks |
| Code writing | Implements features | Reviews PRs |
| Quality | Self-check + addresses reviews | Subjective quality gate |
| Planning | Plans individual tasks | Breaks specs into tasks |
| Learning | Captures observations | Sets team standards |

### The Full Workflow

```
1. Human writes a spec (or ORDER generates from roadmap)
2. ORDER: /plan-work <spec> → breaks into PR-sized tasks
3. ORDER: assigns task to CHAOS instance
4. CHAOS: /work <task-id> → implements → draft PR
5. ORDER: reviews draft PR → marks ready-for-review
6. GHA: automated Claude review on PR
7. CHAOS: /review-feedback → addresses comments
8. Both approve → CHAOS merges PR
9. CHAOS: /learn → captures observations
```

---

## Design Principles

1. **Simplicity over sophistication** — A single conversation doing good work beats a complex multi-agent system doing mediocre work.

2. **Standards over instructions** — Rather than telling each session what to do, build up standards that all sessions follow.

3. **Experience over training** — The learning system provides project-specific knowledge that no amount of pre-training can match.

4. **Quality over speed** — A clean first draft that passes review is faster than a quick draft that needs three rounds of fixes.

5. **Persistence over memory** — Beads issues and learnings files survive context compaction. Nothing important is lost.
