import React from 'react';
import { useAuth } from '../context/AuthContext';

export function UserProfile() {
  const { user } = useAuth();

  if (!user) {
    return <div>Please log in to view your profile.</div>;
  }

  return (
    <div className="user-profile">
      <h2>User Profile</h2>
      <div className="profile-info">
        <p><strong>Email:</strong> {user.email}</p>
        {/* BUG: Dates display in raw ISO format instead of human-readable */}
        <p><strong>Member since:</strong> {user.createdAt}</p>
        <p><strong>Last login:</strong> {user.lastLogin}</p>
      </div>
    </div>
  );
}
