// routes/cart.js
const express = require('express');
const db = require('../db/connection');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Add or update cart item
router.post('/', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const { productId, quantity } = req.body;
  if (!productId || !quantity) return res.status(400).json({ message: 'productId and quantity required' });

  try {
    const existing = db.prepare('SELECT * FROM cart_items WHERE user_id = ? AND product_id = ?').get(userId, productId);
    if (existing) {
      const newQ = existing.quantity + Number(quantity);
      db.prepare('UPDATE cart_items SET quantity = ? WHERE id = ?').run(newQ, existing.id);
      return res.json({ message: 'Cart updated' });
    }
    db.prepare('INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)').run(userId, productId, quantity);
    res.status(201).json({ message: 'Added to cart' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get cart for authenticated user
router.get('/', authenticateToken, (req, res) => {
  const userId = req.user.id;
  try {
    const items = db.prepare(`
      SELECT ci.id, ci.product_id, ci.quantity, p.name, p.price, p.currency
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
      WHERE ci.user_id = ?
    `).all(userId);
    res.json(items);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Remove cart item
router.delete('/:cartItemId', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const { cartItemId } = req.params;
  try {
    const info = db.prepare('DELETE FROM cart_items WHERE id = ? AND user_id = ?').run(cartItemId, userId);
    if (info.changes === 0) return res.status(404).json({ message: 'Cart item not found' });
    res.json({ message: 'Removed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
