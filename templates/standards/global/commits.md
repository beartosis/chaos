# Commit Standards

## Message Format

```
type(scope): short description

Longer explanation if needed.

{{#if BEADS_AVAILABLE}}
Refs: beads-XXX
{{/if BEADS_AVAILABLE}}
```

## Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code change that neither fixes nor adds
- `test`: Adding or updating tests
- `docs`: Documentation only
- `chore`: Maintenance tasks

## Rules

- Keep subject line under 72 characters
- Use imperative mood ("Add feature" not "Added feature")
- Reference issue IDs when applicable
- One logical change per commit
