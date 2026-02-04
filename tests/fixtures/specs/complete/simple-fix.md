# Spec: Fix Date Formatting in User Profile

## Goal

Fix the date formatting issue in the user profile page where dates display in ISO format instead of human-readable format.

## Requirements

- [ ] Update the date display in UserProfile component to use "MMM DD, YYYY" format
- [ ] Apply the same formatting to the "Member since" and "Last login" fields

## Constraints

- Use the existing date-fns library (already installed)
- Do not change the date format stored in the database
- Only modify the UserProfile component

## Acceptance Criteria

- [ ] "Member since" displays as "Jan 15, 2026" instead of "2026-01-15T00:00:00Z"
- [ ] "Last login" displays in the same human-readable format
- [ ] Existing tests still pass

## Out of Scope

- Timezone conversion
- Localization of date formats
- Date formatting in other components

---
*Status: READY*
*Author: Test Fixture*
*Created: 2026-02-03*
