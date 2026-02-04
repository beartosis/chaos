# Backend Testing Standards

## What to Test

- Core business logic and services
- API endpoint behavior (happy path + errors)
- Data validation and edge cases
- Integration points

## What Not to Test

- Framework functionality
- Third-party library internals
- Trivial getters/setters
- Implementation details

## Test Structure

```python
def test_<action>_<scenario>_<expected>():
    # Arrange - set up test data
    user = create_user(...)

    # Act - perform the action
    result = service.process(user)

    # Assert - verify the outcome
    assert result.status == "complete"
```

## Fixtures

- Use fixtures for common setup
- Keep fixtures minimal and focused
- Avoid deep fixture dependencies
- Clean up after tests

## Coverage

- Aim for meaningful coverage, not 100%
- Focus on critical paths
- Test error conditions, not just happy path
