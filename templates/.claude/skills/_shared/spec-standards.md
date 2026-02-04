# Spec Standards

## SOLID Understanding

Before generating a spec, ensure you have SOLID understanding:

- **S**pecific - No vague terms like "fast", "better", "improved"
- **O**bservable - Every requirement can be verified/tested
- **L**imited - Clear boundaries on what's in and out of scope
- **I**ndependent - Can be built without unrequested features
- **D**efined - Edge cases and error handling are specified

## Spec Structure

All specs follow this format:

```markdown
# [Feature Name]

## Goal
[One clear sentence describing what this achieves]

## Requirements
- [ ] [Specific, testable requirement 1]
- [ ] [Specific, testable requirement 2]

## Constraints
- [Technical constraint or limitation]
- [Performance or compatibility requirement]

## Acceptance Criteria
- [ ] [How to verify requirement 1 is met]
- [ ] [How to verify requirement 2 is met]

## Out of Scope
- [What this spec explicitly does NOT include]
```

## Context Files

Every spec includes context files:

- `context/patterns.md` - Existing patterns to follow, anti-patterns to avoid
- `context/references.md` - Files to modify, reference files, dependencies
- `context/decisions.md` - Design decisions made during spec creation

## Validation Checklist

- [ ] Goal is clear and specific
- [ ] Requirements are testable
- [ ] Constraints are documented
- [ ] Acceptance criteria are verifiable
- [ ] Scope boundaries are defined
- [ ] Context files exist
