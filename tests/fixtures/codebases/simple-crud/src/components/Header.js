import React from 'react';
import { useAuth } from '../context/AuthContext';

export function Header() {
  const { user } = useAuth();

  return (
    <header className="header">
      <div className="header-left">
        <h1>Simple CRUD App</h1>
      </div>
      <nav className="header-nav">
        <a href="/">Home</a>
        <a href="/users">Users</a>
        {user && <a href="/profile">Profile</a>}
      </nav>
      <div className="header-right">
        {/* TODO: Add logout button for authenticated users */}
      </div>
    </header>
  );
}
