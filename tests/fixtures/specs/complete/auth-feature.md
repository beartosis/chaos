# Spec: User Authentication System

## Goal

Implement a complete user authentication system with login, registration, and password reset capabilities using JWT tokens stored in httpOnly cookies.

## Requirements

### API Endpoints (Backend already exists at /api/auth/*)
- [ ] POST /api/auth/login - accepts `{ email: string, password: string }`, returns `{ user: User, token: string }`
- [ ] POST /api/auth/register - accepts `{ email: string, password: string, confirmPassword: string }`, returns `{ user: User }`
- [ ] POST /api/auth/logout - clears session, returns `{ success: true }`
- [ ] POST /api/auth/forgot-password - accepts `{ email: string }`, sends reset email
- [ ] POST /api/auth/reset-password - accepts `{ token: string, password: string }`

### Frontend Components
- [ ] Create `LoginForm` component with email/password fields and "Forgot password?" link
- [ ] Create `RegisterForm` component with email, password, confirmPassword fields
- [ ] Create `ForgotPasswordForm` component with email field
- [ ] Create `ResetPasswordForm` component (receives token from URL param)
- [ ] Create `ProtectedRoute` wrapper component that redirects to /login if not authenticated

### State Management
- [ ] Create `AuthContext` with values: `{ user, isAuthenticated, isLoading, login, logout, register }`
- [ ] Store JWT in httpOnly cookie (set by backend, not accessible via JS)
- [ ] Store user object in React state (not localStorage for security)
- [ ] On app mount, call `/api/auth/me` to validate existing session

### Form Validation
- [ ] Email: valid email format (regex: `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`)
- [ ] Password: minimum 8 characters, at least one number and one letter
- [ ] Confirm password: must match password field
- [ ] Show inline validation errors below each field

### Error Handling
- [ ] Display "Invalid email or password" for 401 responses on login
- [ ] Display "Email already registered" for 409 responses on registration
- [ ] Display "Network error, please try again" for 5xx responses
- [ ] Display field-specific validation errors from API (422 responses)

## Constraints

- Must use existing Express backend API at /api/auth/* (do not modify backend)
- Passwords hashed with bcrypt on backend (frontend sends plaintext over HTTPS)
- JWT tokens expire after 24 hours (backend handles expiration)
- Must work with existing User model: `{ id: number, email: string, createdAt: Date }`
- Use existing `Button`, `Input`, `Form` components from src/components/ui/
- No third-party auth libraries (no Auth0, Firebase Auth, etc.)
- Cookie settings: `httpOnly: true, secure: true, sameSite: 'strict'`

## Acceptance Criteria

- [ ] Users can register with valid email (not already in use) and password meeting requirements
- [ ] Users can login with correct email/password combination
- [ ] Invalid login attempts show "Invalid email or password" (no info leakage)
- [ ] Protected routes (e.g., /dashboard, /profile) redirect to /login when not authenticated
- [ ] After login, user is redirected to originally requested page (or /dashboard if direct login)
- [ ] Auth state persists across page refreshes (session cookie validated on mount)
- [ ] Logout clears session cookie and redirects to /login
- [ ] Password reset email is sent (verify via backend logs in dev environment)
- [ ] Password reset with valid token allows setting new password
- [ ] All forms show validation errors before submission (client-side)
- [ ] All forms show API errors after failed submission (server-side)
- [ ] Unit tests cover: AuthContext, ProtectedRoute, form validation logic
- [ ] Integration tests cover: login flow, registration flow, logout flow

## Out of Scope

- Social login (Google, GitHub, etc.) - separate spec
- Two-factor authentication - separate spec
- Account deletion - separate spec
- Email verification on registration - not required for MVP
- "Remember me" checkbox - tokens always expire in 24h
- Password strength meter UI - basic validation only

---
*Status: READY*
*Author: Test Fixture*
*Created: 2026-02-03*
