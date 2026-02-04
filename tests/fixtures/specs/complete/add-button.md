# Spec: Add Logout Button to Header

## Goal

Add a logout button to the application header that allows authenticated users to sign out of their session.

## Requirements

- [ ] Add a "Logout" button to the `header-right` div in `src/components/Header.js`
- [ ] Button should only render when `useAuth().isAuthenticated` is true
- [ ] Button onClick handler should call `useAuth().logout()`
- [ ] After logout completes, redirect to `/login` using react-router's `useNavigate()`
- [ ] The `logout()` function in AuthContext should clear `authToken` and `user` from localStorage

## Constraints

- Do not modify the existing header layout for non-authenticated users
- Must use the existing `useAuth()` hook from `src/context/AuthContext.js`
- Button styling must use existing `btn-secondary` class from the design system
- No changes to the backend `/api/auth/logout` endpoint (already exists)
- No additional npm dependencies

## Acceptance Criteria

- [ ] Logout button appears in header when `isAuthenticated === true`
- [ ] Logout button is not rendered when `isAuthenticated === false`
- [ ] Clicking logout calls POST `/api/auth/logout` via the AuthContext
- [ ] After successful logout, `localStorage.getItem('authToken')` returns null
- [ ] After successful logout, browser navigates to `/login`
- [ ] Unit test verifies button visibility based on auth state
- [ ] Unit test verifies logout function is called on click

## Out of Scope

- Logout confirmation modal - not needed for simple logout
- "Remember me" functionality - separate feature
- Session timeout auto-logout - separate feature
- Loading state during logout - keep it simple

---
*Status: READY*
*Author: Test Fixture*
*Created: 2026-02-03*
