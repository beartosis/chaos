# Standards System

CHAOS uses a low-context standards system inspired by [agent-os](https://github.com/stableborn/agent-os). Standards are small, focused documents that Claude reads on-demand rather than having all guidance preloaded.

In CHAOS v2, the standards system is a **living system** — the `/learn` skill promotes proven patterns from `.chaos/learnings.md` into `standards/` when they appear 3+ times across tasks.

## Why Standards Instead of Skills?

| Aspect | Preloaded Skills | On-Demand Standards |
|--------|------------------|---------------------|
| Context usage | All content loaded upfront | Only index loaded; content on-demand |
| Granularity | Broad guidelines | Focused, domain-specific |
| Per-task selection | No | Yes - tasks can declare which apply |
| Discovery | Skill descriptions in context | `standards.yml` lists all standards |
| Maintenance | Edit single skill file | Edit specific standard files |
| Evolution | Manual updates only | `/learn` promotes patterns automatically |

## Directory Structure

```
project/
├── standards/
│   ├── standards.yml       # Registry of all standards
│   ├── backend/
│   │   ├── patterns.md
│   │   ├── error-handling.md
│   │   └── testing.md
│   ├── frontend/
│   │   ├── components.md
│   │   ├── state.md
│   │   └── accessibility.md
│   ├── global/
│   │   ├── code-style.md
│   │   ├── commits.md
│   │   ├── documentation.md
│   │   └── minimal-changes.md
│   └── testing/
│       ├── philosophy.md
│       └── patterns.md
```

## How It Works

### 1. Discovery via standards.yml

The `standards.yml` file is small (~40 lines) and provides a registry of all standards:

```yaml
backend:
  patterns:
    description: Code patterns, file organization, and architectural decisions
  error-handling:
    description: Error class hierarchy, exception patterns, and API error mapping

global:
  code-style:
    description: General code style, naming conventions, and formatting
  minimal-changes:
    description: Keep changes focused, avoid over-engineering
```

Claude can read this file to know what standards exist without loading all content.

### 2. On-Demand Loading

Claude reads specific standards relevant to the current task:

```markdown
## Standards

Before starting work, read the applicable standards:

cat standards/global/code-style.md
cat standards/global/minimal-changes.md

For backend work, also read:
- standards/backend/patterns.md
- standards/backend/error-handling.md
```

### 3. Spec-Level Declaration (Optional)

Specs can declare which standards apply:

```markdown
# Spec: Add User Authentication

## Standards
- global/*
- backend/patterns
- backend/error-handling
- testing/patterns

## Goal
...
```

The `/work` skill ensures Claude reads declared standards before implementing.

## Writing Standards

### Keep Them Focused

Each standard should cover one concern:
- **Good**: `error-handling.md` - just error handling patterns
- **Bad**: `backend-guide.md` - everything about backend

### Keep Them Short

Target 20-50 lines per standard. The longest should be ~100 lines.

### Include Examples

Show, don't just tell:

```markdown
## Rationale Comments

Use rationale comments to explain *why*, not *what*:

# Rationale: Using eager loading here because the view always displays related items
items = query.options(selectinload(Order.items)).all()
```

### Cross-Reference Other Standards

When standards relate, reference them:

```markdown
For commit message format, see `standards/global/commits.md`.
```

## Customizing Standards

### Project-Specific Standards

Add your own standards alongside the defaults:

```bash
# Create a project-specific standard
cat > standards/backend/our-api-conventions.md << 'EOF'
# Our API Conventions

## Response Format
All API responses use this structure:
{
  "data": {...},
  "meta": {"timestamp": "..."}
}
EOF
```

Update `standards.yml`:

```yaml
backend:
  our-api-conventions:
    description: Project-specific API response format
```

### Overriding Defaults

To override a default standard, simply edit it:

```bash
# Customize the minimal-changes standard
vim standards/global/minimal-changes.md
```

### Removing Standards

Remove standards you don't need:

```bash
rm standards/frontend/accessibility.md
```

Update `standards.yml` to remove the entry.

## Standards vs Skills

Standards and skills serve different purposes:

| Use Case | Use |
|----------|-----|
| Reference documentation | Standards |
| Actionable workflows | Skills |
| Per-task customization | Standards |
| User-invocable commands | Skills |

**Example**:
- `standards/global/commits.md` - Guidelines for commit messages
- `/commit` skill - Interactive commit workflow

## The Learning Loop

Standards evolve through the CHAOS learning loop:

1. **Observation**: During `/work`, Claude discovers a codebase pattern
2. **Capture**: During `/learn`, the observation is recorded in `.chaos/learnings.md`
3. **Promotion**: When 3+ sessions observe the same pattern, `/learn` promotes it to `standards/`
4. **Application**: Future sessions read standards before writing code

This means your standards directory gets smarter over time without manual maintenance.
