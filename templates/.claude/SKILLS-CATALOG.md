# CHAOS Skills Catalog

A comprehensive guide to CHAOS skills - what they do, when to use them, and how they work together.

## Quick Reference

| Skill | Command | Purpose | Duration |
|-------|---------|---------|----------|
| [Create Spec](#create-spec) | `/create-spec [name]` | Build a spec interactively | 5-20 min |
| [Review Spec](#review-spec) | `/review-spec [name]` | Validate spec completeness | 2-5 min |
| [Orchestrate](#orchestrate) | `/orchestrate [name]` | Run full implementation pipeline | 10-60 min |
| [Analyze](#analyze) | `/analyze` | Find codebase health issues | 5-15 min |

---

## Workflow Overview

```
                    ┌─────────────────┐
                    │  Human Intent   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
       ┌──────────┐   ┌──────────┐   ┌──────────┐
       │ /analyze │   │/create-  │   │ GitHub   │
       │          │   │  spec    │   │  Issue   │
       └────┬─────┘   └────┬─────┘   └────┬─────┘
            │              │              │
            └──────────────┼──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ /review-spec │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ /orchestrate │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Complete   │
                    └──────────────┘
```

---

## Skills Detail

### Create Spec

**Command**: `/create-spec [feature-name]` or `/create-spec --from-issue <url>`

**Purpose**: Transform a high-level goal or GitHub issue into a complete, actionable specification.

**When to Use**:
- Starting a new feature
- Formalizing requirements from a discussion
- Converting a GitHub issue to a CHAOS spec

**How It Works**:
1. **Context Assessment** - Checks for prior discussion or parses GitHub issue
2. **Scout Phase** - Explores codebase for relevant patterns
3. **Clarification** - Asks questions until SOLID understanding achieved
4. **Generation** - Creates spec with all required sections
5. **Validation** - Runs spec-reviewer automatically

**Agents Used**: scout, spec-architect, spec-reviewer

**Example**:
```
/create-spec dark-mode

> What feature would you like to spec out?
User: I want to add a dark mode toggle to settings

> [Scout finds existing theme patterns...]
> Should dark mode persist across sessions?
User: Yes, save to localStorage

> [Creates spec at specs/2025-02-03-dark-mode/]
```

**Output**: `specs/YYYY-MM-DD-[name]/SPEC.md` + context files

---

### Review Spec

**Command**: `/review-spec [spec-name]`

**Purpose**: Validate that a specification is complete, clear, and ready for implementation.

**When to Use**:
- Before running orchestrate
- After making changes to a spec
- To get feedback on spec quality

**How It Works**:
1. Loads spec from `specs/[name]/SPEC.md`
2. Checks against SOLID principles
3. Validates all required sections
4. Returns completeness score and issues

**Agents Used**: spec-reviewer

**Checklist**:
- [ ] Goal is clear and specific
- [ ] Requirements are testable
- [ ] Constraints are documented
- [ ] Acceptance criteria are verifiable
- [ ] Scope boundaries are defined
- [ ] Context files exist

**Output**: Completeness score (0-100%) + specific issues

---

### Orchestrate

**Command**: `/orchestrate [spec-name]`

**Purpose**: Execute the complete implementation pipeline from validated spec to reviewed code.

**When to Use**:
- After spec passes review
- To automate feature implementation
- For end-to-end workflow execution

**How It Works**:
1. **Spec Review** - Validates spec is ready
2. **Work Breakdown** - Creates beads issues
3. **Pipeline** - For each issue:
   - Explore (find patterns)
   - Plan (design approach)
   - Implement (write code)
   - Verify (run tests)
   - Review (quality gate)
4. **Completion** - Syncs all state, reports results

**Agents Used**: spec-reviewer, explore, plan, implement, verifier, code-reviewer, dispute-resolver (on failure)

**Failure Handling**:
- 3 retries per stage
- Automatic escalation to dispute-resolver
- Human intervention for unresolvable issues

**Output**: Implemented feature + completion report

---

### Analyze

**Command**: `/analyze` or `/analyze --create-spec`

**Purpose**: Systematically assess codebase health and identify improvement opportunities.

**When to Use**:
- Regular health checks
- Before major refactoring
- Finding tech debt priorities
- Security audits

**How It Works**:
1. **Exploration** - code-explorer scans codebase
2. **Categorization** - Groups findings by type and severity
3. **Prioritization** - Ranks by impact
4. **Reporting** - Presents actionable findings
5. **(Optional)** - Creates specs for selected issues

**Agents Used**: code-explorer, scout, spec-architect (with --create-spec)

**Finding Categories**:
- **Security**: Injection risks, secrets, vulnerabilities
- **Tech Debt**: TODOs, duplicates, outdated patterns
- **Test Gaps**: Low coverage, missing edge cases
- **Performance**: N+1 queries, blocking calls
- **Documentation**: Stale docs, undocumented APIs

**Output**: Prioritized health report

---

## Security Profiles

Skills operate under different security constraints:

| Profile | Access Level | Skills |
|---------|--------------|--------|
| `read_only` | Read files only | review-spec, coding-standards |
| `standard` | Read/write within project | analyze |
| `elevated` | External requests, full shell | orchestrate, create-spec |

---

## Context Requirements

### What Skills Need

| Skill | Required | Recommended |
|-------|----------|-------------|
| create-spec | - | standards/standards.yml |
| review-spec | specs/[name]/SPEC.md | specs/[name]/context/ |
| orchestrate | specs/[name]/SPEC.md | standards/, agents/index.yml |
| analyze | - | .CHAOS/analysis/config.yml |

---

## Skill Chaining

Skills are designed to work together:

```bash
# Full workflow
/create-spec my-feature     # Build the spec
/review-spec my-feature     # Validate it
/orchestrate my-feature     # Implement it

# Analysis workflow
/analyze                    # Find issues
/analyze --create-spec      # Turn finding into spec
/orchestrate [spec-name]    # Fix the issue
```

---

## Thinking Triggers

CHAOS agents use Anthropic's thinking hierarchy for deeper reasoning:

| Level | Trigger | Used By | Purpose |
|-------|---------|---------|---------|
| Light | `think` | scout | Pattern recognition |
| Moderate | `think hard` | implement, code-reviewer | Code analysis |
| Deep | `think harder` | plan, dispute-resolver | Architecture decisions |
| Maximum | `ultrathink` | spec-architect | Requirements clarity |

---

## Troubleshooting

### Skill Won't Start
- Check preflight: `.claude/scripts/preflight.sh`
- Ensure beads is installed: `bd --version`
- Verify file exists: `ls specs/[name]/SPEC.md`

### Orchestrate Keeps Failing
- Check dispute-resolver output
- Review beads issue notes: `bd show [id]`
- Escalate to human if stuck

### Analysis Misses Files
- Check ignore patterns in `.CHAOS/analysis/config.yml`
- Ensure paths are relative to project root

---

## See Also

- [Agent Index](.claude/agents/index.yml) - Available agents
- [Standards Index](standards/standards.yml) - Coding standards
- [Architecture](docs/architecture.md) - System design
- [Best Practices](docs/best-practices.md) - Usage patterns
