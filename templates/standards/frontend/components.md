# Frontend Component Standards

## Component Design

- One component per file
- Keep components focused and small
- Extract reusable logic into hooks
- Prefer composition over inheritance

## Props

- Use TypeScript interfaces for props
- Provide sensible defaults
- Document required vs optional props
- Avoid prop drilling (use context for deep data)

## State

- Keep state as local as possible
- Lift state only when needed by siblings
- Use appropriate state management for scope

## Naming

- PascalCase for component names
- camelCase for props and functions
- Descriptive names that indicate purpose

## File Structure

```
ComponentName/
├── ComponentName.tsx    # Main component
├── ComponentName.test.tsx
└── index.ts             # Re-export
```
