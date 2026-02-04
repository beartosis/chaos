# Backend Error Handling Standards

## Error Class Hierarchy

Create domain-specific exceptions:

```python
class DomainError(Exception):
    """Base for all domain errors."""
    pass

class NotFoundError(DomainError):
    """Resource not found."""
    pass

class ValidationError(DomainError):
    """Invalid input data."""
    pass

class AuthorizationError(DomainError):
    """User not authorized."""
    pass
```

## API Error Mapping

Map domain errors to HTTP responses:

| Domain Error | HTTP Status | Response |
|--------------|-------------|----------|
| NotFoundError | 404 | `{"error": "not_found", "message": "..."}` |
| ValidationError | 400 | `{"error": "validation_error", "details": [...]}` |
| AuthorizationError | 403 | `{"error": "forbidden", "message": "..."}` |
| Unexpected | 500 | `{"error": "internal_error"}` |

## Rules

- Never expose stack traces to clients
- Log full error details server-side
- Use consistent error response format
- Include actionable error messages when safe
