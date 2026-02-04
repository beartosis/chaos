# Backend Patterns Standards

## File Organization

- Group related functionality together
- Keep files focused on single responsibility
- Use clear, descriptive file names

## Code Patterns

### Service Layer

Extract business logic into service functions/classes:
- Keep route handlers thin
- Services handle business rules
- Services are testable in isolation

### Data Access

- Use repository pattern or clear data access layer
- Don't mix business logic with queries
- Handle transactions at service boundaries

## Dependencies

- Prefer explicit dependency injection
- Avoid global state
- Make dependencies mockable for testing

## Configuration

- Use environment variables for configuration
- Provide sensible defaults
- Document required vs optional config
