# Frontend State Standards

## State Location

| Data Type | Location |
|-----------|----------|
| UI state (open/closed, hover) | Local component state |
| Form state | Form library or local state |
| Server data | Data fetching library cache |
| Global app state | Context or state manager |

## Server State

Use a data fetching library (React Query, SWR, etc.):

- Automatic caching and revalidation
- Loading and error states
- Optimistic updates
- Background refetching

## Form State

- Use controlled inputs for validation
- Validate on blur or submit, not every keystroke
- Show errors clearly near the field
- Preserve form state on validation errors

## Avoid

- Storing derived data in state
- Duplicating server data locally
- Global state for component-specific data
- State synchronization between components (lift instead)
