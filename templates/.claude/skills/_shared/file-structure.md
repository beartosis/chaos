# File Structure Conventions

## Spec Folder Naming

Always use dated folders: `specs/YYYY-MM-DD-feature-name/`

Example: `specs/2025-02-03-dark-mode/`

## Spec Directory Structure

```
specs/YYYY-MM-DD-[feature-name]/
├── SPEC.md              # Main specification
├── context/
│   ├── patterns.md      # Codebase patterns to follow
│   ├── references.md    # Files to modify/reference
│   └── decisions.md     # Design decisions
└── visuals/             # Optional: mockups, diagrams
    └── ...
```

## Finding Specs

```bash
# List all specs
ls specs/

# Find spec by name
ls specs/*dark-mode*

# Read a spec
cat specs/2025-02-03-dark-mode/SPEC.md
```

## Spec Arguments

When a skill takes `[spec-name]`:
- Use the folder name: `2025-02-03-dark-mode`
- NOT the full path: `specs/2025-02-03-dark-mode/SPEC.md`

Example: `/orchestrate 2025-02-03-dark-mode`
