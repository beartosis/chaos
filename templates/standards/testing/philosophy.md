# Testing Philosophy Standards

## What Tests Are For

Tests verify that:
- Code works as intended
- Changes don't break existing functionality
- Edge cases are handled
- Requirements are met

## Test Pyramid

```
        /\
       /  \    E2E (few)
      /----\   Integration (some)
     /------\  Unit (many)
    /--------\
```

- **Unit**: Fast, isolated, many of them
- **Integration**: Test component interactions
- **E2E**: Test critical user journeys only

## Coverage Philosophy

- Test behavior, not implementation
- 100% coverage is not the goal
- Critical paths need coverage
- Tests should give confidence to refactor

## When to Write Tests

- Before fixing bugs (reproduce first)
- For new features with clear requirements
- For complex business logic
- When refactoring risky code

## When to Skip Tests

- Prototypes and spikes
- Trivial code (getters, simple wrappers)
- UI styling details
- Framework/library functionality
