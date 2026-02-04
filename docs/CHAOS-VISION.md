# CHAOS: Claude Handling Agentic Orchestration System

**A spec-driven orchestration framework that transforms intent into working code through coordinated AI agents.**

---

## Vision

Software development is bottlenecked by specification. The gap between "I want X" and a clear, actionable spec is where most projects stall—requirements are ambiguous, edge cases unconsidered, existing patterns ignored.

CHAOS bridges this gap through **guided spec creation**. Rather than expecting humans to write perfect specifications, CHAOS asks the right questions, grounds answers in codebase reality, and produces specs that agents can execute reliably.

### The CHAOS Loop

```
Intent ──► Guided Questions ──► Specification ──► Orchestrated Execution ──► Working Code
```

- **Humans provide intent**: A goal, a bug report, or just "make it better"
- **System asks questions**: Grounded in actual codebase patterns and constraints
- **Specs emerge from dialogue**: Clear, testable, scoped to what's achievable
- **Agents execute deterministically**: Explore → Plan → Implement → Verify → Review

### Philosophy

> *"From chaos comes clarity"*

- **Questions over assumptions**: When in doubt, ask. The system never guesses at requirements.
- **Codebase-grounded**: Every question and decision references actual code, not hypotheticals.
- **Specs as contracts**: The specification is the agreement between human intent and AI execution.
- **Human authority preserved**: Humans prioritize, approve, and can override at any point.

---

## Spec Creation Modes

CHAOS supports three pathways from intent to specification:

| Mode | Entry Point | Flow | Best For |
|------|-------------|------|----------|
| **Guided** | Human goal | Questions → Clarify → Spec | New features, complex requirements |
| **From-Issue** | GitHub issue | Parse → Expand → Clarify → Spec | Bug fixes, user-reported issues |
| **Codebase Analysis** | Automated crawl | Crawl → Identify → Propose → Spec | Tech debt, test gaps, improvements |

### Mode 1: Guided Spec Creation

Human provides a high-level goal. System guides them to a complete spec.

```
Human: "I want to add dark mode"
                │
                ▼
        Scout explores codebase
        ├─ Found: ThemeProvider in src/theme/
        ├─ Found: CSS variables in styles/variables.css
        └─ Found: No existing dark theme tokens
                │
                ▼
        Clarifying questions:
        ├─ "Should dark mode persist across sessions?"
        ├─ "Toggle in header, settings, or both?"
        └─ "Should it respect system preference?"
                │
                ▼
        Human answers
                │
                ▼
        spec-architect generates spec
                │
                ▼
        specs/2025-02-03-dark-mode/SPEC.md
```

**Key principle**: Questions are grounded in what the codebase actually has, not generic best practices.

### Mode 2: From-Issue Spec Creation

System takes an existing issue and expands it into a full spec.

```
GitHub Issue #142: "Login fails silently on timeout"
                │
                ▼
        Parse issue content:
        ├─ Problem: Login fails without error message
        ├─ Reproduction: Slow network, submit form
        └─ Expected: Show timeout error to user
                │
                ▼
        Expand with codebase context:
        ├─ Found: AuthService.login() in src/services/
        ├─ Found: No timeout handling in fetch wrapper
        └─ Found: Toast component for error display
                │
                ▼
        Targeted questions (if needed):
        └─ "Should retry automatically or just show error?"
                │
                ▼
        spec-architect generates spec
                │
                ▼
        specs/2025-02-03-fix-login-timeout/SPEC.md
```

**Usage**: `/create-spec --from-issue <url>`

### Mode 3: Codebase Analysis

System proactively identifies improvement opportunities.

```
/analyze
    │
    ▼
code-explorer crawls codebase
    │
    ▼
Prioritized findings:
├─ Tech Debt:
│   ├─ [HIGH] Duplicate validation logic in 3 controllers
│   └─ [MED] Deprecated API usage in payment module
├─ Test Gaps:
│   ├─ [HIGH] AuthService has 12% coverage
│   └─ [MED] No integration tests for checkout flow
├─ Security:
│   └─ [HIGH] SQL concatenation in search endpoint
└─ Performance:
    └─ [LOW] N+1 query in user list endpoint
    │
    ▼
Human reviews and selects: "Fix SQL concatenation"
    │
    ▼
spec-architect generates spec
    │
    ▼
specs/2025-02-03-fix-sql-injection/SPEC.md
```

**Usage**: `/analyze`

---

## Agents

CHAOS coordinates specialized agents through a deterministic pipeline.

### Exploration & Analysis

| Agent | Model | Purpose |
|-------|-------|---------|
| **scout** | Haiku | Fast pattern discovery for feature context |
| **explore** | Haiku | Detailed codebase investigation for work units |
| **code-explorer** | Haiku | Systematic codebase health analysis |

### Spec Lifecycle

| Agent | Model | Purpose |
|-------|-------|---------|
| **spec-reviewer** | Sonnet | Validates spec completeness and clarity |
| **spec-architect** | Opus | Transforms intent/analysis into well-formed specs |

### Implementation Pipeline

| Agent | Model | Purpose |
|-------|-------|---------|
| **plan** | Sonnet | Designs implementation approach |
| **implement** | Opus | Writes code following standards |
| **verifier** | Haiku | Checks acceptance criteria (PASS/FAIL) |
| **code-reviewer** | Sonnet | Quality gate for patterns, tests, security |

### Escalation & Support

| Agent | Model | Purpose |
|-------|-------|---------|
| **dispute-resolver** | Sonnet | Handles failures: RETRY or ESCALATE to human |
| **beads-helper** | Haiku | Executes Beads commands for issue tracking |
| **tooling-setup** | Haiku | Diagnoses and repairs CHAOS dependencies |

### New Agent: `code-explorer`

**Model**: Haiku (fast, cheap—can run frequently)

**Purpose**: Systematic codebase health analysis

**Identifies**:
- **Tech debt**: Duplicate code, outdated patterns, complexity hotspots, TODOs/FIXMEs
- **Test coverage gaps**: Untested code paths, missing edge cases, low-coverage modules
- **Security concerns**: Injection risks, hardcoded secrets, auth gaps, OWASP issues
- **Performance issues**: N+1 queries, missing indexes, blocking calls, memory leaks
- **Documentation gaps**: Undocumented APIs, stale READMEs, missing type annotations

**Output**: Prioritized summary of improvement opportunities with severity and location.

**Philosophy**: Crawls slowly and thoroughly. Better to find fewer issues with high confidence than many false positives.

### New Agent: `spec-architect`

**Model**: Opus (thoughtful, thorough—specs require precision)

**Purpose**: Transform improvement opportunities into executable specifications

**Takes**:
- `code-explorer`'s analysis summary, OR
- Human's high-level goal, OR
- Parsed GitHub issue content
- Plus: Codebase context from scout/explore

**Produces**:
- Complete spec following CHAOS format:
  - Goal, Requirements, Constraints, Acceptance Criteria, Out of Scope
- Context files:
  - `patterns.md` — Existing patterns to follow
  - `references.md` — Files to modify
  - `decisions.md` — Design decisions made during creation
- Dependency ordering when multiple specs relate

**Key behavior**: Asks clarifying questions via `AskUserQuestion` when requirements are ambiguous. Never assumes.

---

## Skills

| Skill | Purpose |
|-------|---------|
| `/create-spec [name]` | Guided spec creation from goal |
| `/create-spec --from-issue <url>` | Create spec from GitHub issue |
| `/analyze` | Run codebase health analysis |
| `/review-spec [name]` | Validate spec completeness |
| `/orchestrate [name]` | Execute spec through agent pipeline |

---

## Execution Pipeline

Once a spec exists, `/orchestrate` executes it through a fixed pipeline:

```
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION PIPELINE                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Spec ──► spec-reviewer validates                           │
│              │                                               │
│              ▼                                               │
│         Work Breakdown (create Beads issues)                │
│              │                                               │
│              ▼                                               │
│         For each work unit:                                 │
│         ┌─────────────────────────────────────┐             │
│         │  explore ──► plan ──► implement     │             │
│         │       │                    │        │             │
│         │       └──── retry (max 3) ─┘        │             │
│         │                    │                │             │
│         │              verifier               │             │
│         │                    │                │             │
│         │             code-reviewer           │             │
│         └─────────────────────────────────────┘             │
│              │                                               │
│              ▼                                               │
│         On 3rd failure: dispute-resolver                    │
│         ├─ RETRY with new approach                          │
│         └─ ESCALATE to human                                │
│              │                                               │
│              ▼                                               │
│         Completion: Close Beads, sync, report               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Three-Strike Rule

Each work unit gets 3 attempts:
1. First attempt: Agent tries standard approach
2. Second attempt: Retry with error context
3. Third attempt: Final retry with accumulated learnings
4. After 3 failures: `dispute-resolver` decides RETRY (with guidance) or ESCALATE (to human)

No infinite loops. No silent failures.

---

## Human-in-the-Loop Touchpoints

CHAOS is designed for supervised operation. Humans intervene at these points:

| Touchpoint | When | Human Action |
|------------|------|--------------|
| **Spec clarification** | `spec-architect` needs decisions | Answer questions about requirements |
| **Analysis prioritization** | `code-explorer` found issues | Select which improvements to pursue |
| **Failure escalation** | 3 failures on work unit | Choose retry approach or adjust requirements |
| **Final review** | Pipeline complete | Review changes before merge |

---

## Beads Integration

CHAOS uses **Beads** for persistent issue tracking and audit trails.

### Workflow

```bash
# Orchestrator creates issues
bd create --title="Explore: auth patterns" --type=task

# Agents read context
bd show [issue-id]

# Agents write discoveries
bd update [issue-id] --notes="Found: existing JWT validation in..."

# Agents complete work
bd close [issue-id] --reason="Implemented X, tests added"

# Orchestrator syncs
bd sync --flush-only
```

### Why Beads?

- **Persistence**: Work survives context compaction
- **Audit trail**: Every decision is logged
- **Dependencies**: Issues can depend on each other
- **Human visibility**: Humans can inspect progress at any time

---

## Configuration

### Analysis Configuration

```yaml
# .CHAOS/analysis/config.yml
focus_areas:
  - tech_debt
  - test_coverage
  - security
  - performance
  - documentation

severity_threshold: medium    # Only report medium+ severity

ignore_paths:
  - vendor/
  - node_modules/
  - "*.min.js"
```

### Project Structure

```
project/
├── .claude/
│   ├── agents/           # Agent definitions
│   ├── skills/           # Skill definitions
│   └── settings.local.json
├── specs/                # Generated specifications
│   └── YYYY-MM-DD-name/
│       ├── SPEC.md
│       └── context/
├── standards/            # Coding standards
└── .CHAOS/
    ├── version
    ├── framework_path
    └── analysis/         # code-explorer results
        ├── latest.json
        └── history/
```

---

## Autonomous Operation

CHAOS is designed with humans in the loop—answering questions, prioritizing improvements, resolving disputes.

For fully autonomous, human-free operation, see **ORDER** (Optional Resource During Extended Runtimes). ORDER is an optional plugin that intercepts CHAOS's human escalation points:

| CHAOS Behavior | ORDER Behavior |
|----------------|----------------|
| `spec-architect` asks human | `order-oracle` decides based on codebase |
| `dispute-resolver` escalates | `order-arbiter` retries or skips, never escalates |
| Human prioritizes analysis | ORDER processes all or uses configured rules |

CHAOS remains fully functional without ORDER. ORDER simply adds automation for batch processing and overnight runs.

See [ORDER-VISION.md](ORDER-VISION.md) for details.

---

## Summary

CHAOS provides three pathways from intent to implementation:

```
Guided:           Human Goal ─────► Questions ─────► Spec ─────► Orchestrate
From-Issue:       GitHub Issue ───► Parse ─────────► Spec ─────► Orchestrate
Codebase Analysis: /analyze ──────► Identify ──────► Spec ─────► Orchestrate
```

The system encourages:
- **Questions over assumptions**: Never guess at requirements
- **Codebase-grounded decisions**: Every question references actual code
- **Human authority**: Humans prioritize, approve, and can override

CHAOS transforms the spec-writing bottleneck into a collaborative dialogue where AI asks the right questions and humans provide the right answers.
