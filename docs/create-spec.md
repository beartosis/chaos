# Creating Specs with /create-spec

The `/create-spec` command creates specifications in CHAOS through interactive conversation, building a complete, validated spec with context files.

## Quick Start

```bash
claude /create-spec
```

Or with a feature name:

```bash
claude /create-spec user-auth
```

## How It Works

### Context-Aware

The command runs in your main conversation, so it can:
- See everything you've discussed previously
- Offer to turn existing discussions into specs
- Build on context naturally

### Two Entry Points

**Starting fresh:**
```
> /create-spec

What feature would you like to spec out?

> I want to add user notifications

Great! Let me explore your codebase...
[scout agent finds relevant patterns]

Questions to clarify:
1. What events trigger notifications?
2. Email, push, or both?
...
```

**After discussing a feature:**
```
> [prior discussion about dark mode]

> /create-spec

I see we've been discussing a dark mode feature.
Would you like me to create a spec based on what we've discussed?

From our conversation:
- Goal: Add dark mode toggle
- Persist in localStorage
- Auto-detect system preference

Is this accurate?
```

## The SOLID Principle

The command keeps asking questions until it has a **SOLID** understanding:

- **S**pecific - No vague terms like "fast" or "better"
- **O**bservable - Every requirement can be verified
- **L**imited - Clear scope boundaries
- **I**ndependent - Can be built standalone
- **D**efined - Edge cases and errors specified

## What Gets Created

```
specs/2025-01-25-user-notifications/
├── SPEC.md              # Main specification
├── context/
│   ├── patterns.md      # Codebase patterns (from scout)
│   ├── references.md    # Files to modify
│   └── decisions.md     # Design decisions from conversation
└── visuals/             # Mockups/screenshots (if provided)
```

### SPEC.md Structure

```markdown
# Spec: User Notifications

## Goal
[1-2 sentences]

## Requirements
- [ ] Requirement 1
- [ ] Requirement 2

## Constraints
- Must not break X
- Performance: Y

## Acceptance Criteria
- [ ] Testable criterion 1
- [ ] Testable criterion 2

## Out of Scope
- Feature for later
- Related but separate concern
```

### Context Files

**patterns.md** - What the scout agent found:
- Similar implementations in your codebase
- Patterns to follow
- Test approaches

**references.md** - Files involved:
- Files to read for context
- Files to modify
- Related test files

**decisions.md** - Design choices made:
- Questions that were asked
- Decisions made
- Rationale captured

## Adding Visuals

If you have mockups or screenshots:

```
Do you have any visuals (mockups, screenshots)?

> Yes, I have a mockup at ~/designs/login-mockup.png

[copies to specs/[date]-[name]/visuals/]
[adds reference in SPEC.md]
```

## Auto-Validation

After generating the spec, `/create-spec` automatically runs the spec-reviewer to check:
- All 5 sections are complete
- Requirements are specific
- Acceptance criteria are testable
- No ambiguous language

## After Creating a Spec

Once your spec is created and validated:

```bash
# Run the full orchestration pipeline
claude /orchestrate 2025-01-25-user-notifications
```

## Tips

1. **Don't rush** - Let the conversation develop naturally
2. **Be honest about uncertainty** - If you're not sure, say so
3. **Add visuals** - They help clarify requirements
4. **Review the context files** - They're useful for implementation
