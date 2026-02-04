# Writing Effective Specs

Good specs lead to good implementations. This guide covers how to write specs that agents can execute successfully.

## Spec Structure

Every spec has five sections:

```markdown
# Spec: [Title]

## Goal
## Requirements
## Constraints
## Acceptance Criteria
## Out of Scope
```

### Goal

One or two sentences describing the outcome. Focus on **what**, not **how**.

**Good**:
> Add a user profile page that displays account information and allows editing.

**Bad**:
> Use React to create a component with useState hooks that fetches from /api/user.

### Requirements

Specific, actionable items. Use checkboxes for tracking.

**Good**:
```markdown
- [ ] Display user's name, email, and join date
- [ ] Allow editing name and email
- [ ] Show validation errors inline
- [ ] Save changes on form submit
```

**Bad**:
```markdown
- [ ] Make it look nice
- [ ] Handle errors properly
- [ ] Be performant
```

### Constraints

What must NOT change or must be maintained.

**Good**:
```markdown
- Must use existing Button and Input components
- Must not modify the auth middleware
- Response time must stay under 200ms
```

### Acceptance Criteria

Testable conditions for completion. These drive verification.

**Good**:
```markdown
- [ ] Profile page loads in under 500ms
- [ ] Name field accepts 1-100 characters
- [ ] Invalid email shows "Please enter a valid email"
- [ ] After save, page shows "Profile updated"
```

**Bad**:
```markdown
- [ ] Page works correctly
- [ ] Errors are handled
- [ ] UX is good
```

### Out of Scope

Explicitly exclude related but separate work.

**Good**:
```markdown
- Password change (separate spec)
- Profile photo upload
- Account deletion
```

## Tips for Better Specs

### 1. One Feature Per Spec

**Do**: Create separate specs for related features
**Don't**: Combine multiple features into one spec

Bad:
> Add user profiles, settings page, and notification preferences

Good:
> Spec: user-profile
> Spec: settings-page
> Spec: notification-preferences

### 2. Be Specific About Behavior

**Vague**: "Handle errors gracefully"
**Specific**: "Display error banner with message, log to console, don't crash"

**Vague**: "Make it fast"
**Specific**: "Initial load under 500ms, subsequent loads under 100ms"

### 3. Reference Existing Patterns

Help agents find the right examples:

```markdown
## Constraints
- Follow the pattern used in src/components/UserList.tsx
- Use the same API format as /api/products
```

### 4. Include Edge Cases

```markdown
## Requirements
- [ ] Show empty state when no items exist
- [ ] Limit display to 100 items with pagination
- [ ] Handle network timeout with retry button
```

### 5. Specify Error Messages

```markdown
## Acceptance Criteria
- [ ] Empty name shows "Name is required"
- [ ] Invalid email shows "Please enter a valid email"
- [ ] Network error shows "Unable to save. Please try again."
```

## Common Mistakes

### Too Vague

```markdown
## Goal
Make the dashboard better.
```

Fix: What specifically should improve?

### Too Prescriptive

```markdown
## Requirements
- [ ] Create a React component called DashboardStats
- [ ] Use useEffect to fetch from /api/stats
- [ ] Store results in useState
```

Fix: Describe **what**, let the agent decide **how**.

### Missing Edge Cases

```markdown
## Acceptance Criteria
- [ ] Displays user list
```

Fix: What about empty list? Loading state? Errors?

### No Clear Completion

```markdown
## Acceptance Criteria
- [ ] Works well
- [ ] No bugs
```

Fix: Testable, specific criteria.

## Example: Complete Spec

```markdown
# Spec: user-search

## Goal
Add a search feature to the user list page that filters users by name or email in real-time.

## Requirements
- [ ] Add search input above user table
- [ ] Filter users as user types (debounced, 300ms)
- [ ] Search matches partial name OR email
- [ ] Case-insensitive matching
- [ ] Clear button to reset search
- [ ] Show result count ("Showing X of Y users")

## Constraints
- Must use existing Input component from ui/
- Must not change UserList component API
- Search runs client-side (no API calls)
- Must work with up to 1000 users without lag

## Acceptance Criteria
- [ ] Typing "john" shows users with "john" in name or email
- [ ] Search is case-insensitive ("John" = "john" = "JOHN")
- [ ] Results update within 400ms of last keystroke
- [ ] Clear button empties input and shows all users
- [ ] Empty search shows all users
- [ ] "Showing 5 of 100 users" displays correctly
- [ ] With 1000 users, no visible lag while typing

## Out of Scope
- Server-side search
- Search history
- Advanced filters (date, role, etc.)
- Keyboard navigation of results
```

This spec is:
- Focused (one feature)
- Specific (exact behavior defined)
- Testable (clear acceptance criteria)
- Bounded (out of scope defined)
- Constrained (uses existing patterns)
