const express = require('express');
const router = express.Router();

// POST /api/auth/login
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  // Simplified auth for testing
  if (email && password) {
    res.json({
      token: 'mock-jwt-token',
      user: { id: 1, email }
    });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// POST /api/auth/logout
router.post('/logout', (req, res) => {
  res.json({ success: true });
});

// POST /api/auth/register
router.post('/register', (req, res) => {
  const { email, password } = req.body;

  if (email && password) {
    res.status(201).json({
      user: { id: 2, email }
    });
  } else {
    res.status(400).json({ error: 'Email and password required' });
  }
});

module.exports = router;
