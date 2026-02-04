# Documentation Standards

## When to Comment

Comment when:
- Logic isn't self-evident from the code
- There's a non-obvious reason for an approach
- External constraints dictate the implementation

Don't comment:
- What the code does (the code shows that)
- Obvious operations
- Every function/method

## Rationale Comments

Use rationale comments to explain *why*, not *what*:

```python
# Rationale: Using eager loading here because the view always displays related items
items = query.options(selectinload(Order.items)).all()

# Rationale: Committing before notification so data persists even if notification fails
await session.commit()
await notify_user(order)
```

Rationale comments prevent future developers (and AI agents) from "fixing" intentional patterns.

## API Documentation

- Document public APIs with parameters and return types
- Include usage examples for complex functions
- Keep internal implementation details internal
