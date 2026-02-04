const express = require('express');
const router = express.Router();

// Mock user data
const users = [
  { id: 1, email: 'user@example.com', createdAt: '2026-01-15T00:00:00Z', lastLogin: '2026-02-01T10:30:00Z' }
];

// GET /api/users/:id
router.get('/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (user) {
    res.json(user);
  } else {
    res.status(404).json({ error: 'User not found' });
  }
});

// GET /api/users
router.get('/', (req, res) => {
  res.json(users);
});

module.exports = router;
