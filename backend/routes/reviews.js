// routes/reviews.js
const express = require('express');
const db = require('../db/connection');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Post review (auth required)
router.post('/:productId/reviews', authenticateToken, (req, res) => {
  const { productId } = req.params;
  const userId = req.user.id;
  const { rating, comment } = req.body;

  if (!rating || rating < 1 || rating > 5) return res.status(400).json({ message: 'Valid rating required' });

  try {
    db.prepare('INSERT INTO reviews (product_id, user_id, rating, comment) VALUES (?, ?, ?, ?)').run(productId, userId, rating, comment);
    res.status(201).json({ message: 'Review submitted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get reviews for product
router.get('/:productId/reviews', (req, res) => {
  const { productId } = req.params;
  try {
    const rows = db.prepare('SELECT r.*, u.username FROM reviews r JOIN users u ON r.user_id = u.id WHERE product_id = ? ORDER BY created_at DESC').all(productId);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
