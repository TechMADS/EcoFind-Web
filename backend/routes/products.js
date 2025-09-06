// routes/products.js
const express = require('express');
const db = require('../db/connection');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// Get all products (optional query: search, sortBy, order)
router.get('/', (req, res) => {
  try {
    const { search, sortBy, order } = req.query;
    let query = 'SELECT * FROM products';
    const params = [];

    if (search) {
      query += ' WHERE name LIKE ? OR description LIKE ?';
      const term = `%${search}%`;
      params.push(term, term);
    }

    if (sortBy) {
      const allowed = ['name', 'price', 'stock', 'created_at'];
      if (!allowed.includes(sortBy)) return res.status(400).json({ message: 'Invalid sortBy' });
      const sortOrder = (order && order.toUpperCase() === 'DESC') ? 'DESC' : 'ASC';
      query += ` ORDER BY ${sortBy} ${sortOrder}`;
    }

    const rows = db.prepare(query).all(...params);
    // parse images JSON field
    const products = rows.map(r => ({ ...r, images: r.images ? JSON.parse(r.images) : [] }));
    res.json(products);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get single product by id
router.get('/:id', (req, res) => {
  const { id } = req.params;
  try {
    const stmt = db.prepare('SELECT * FROM products WHERE id = ?');
    const p = stmt.get(id);
    if (!p) return res.status(404).json({ message: 'Product not found' });
    p.images = p.images ? JSON.parse(p.images) : [];
    res.json(p);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Create product (admin)
router.post('/', authenticateToken, requireAdmin, (req, res) => {
  const { name, description = '', price, stock, currency = 'INR', images = [] } = req.body;
  if (!name || price == null || stock == null) return res.status(400).json({ message: 'Name, price, stock required' });

  try {
    const stmt = db.prepare('INSERT INTO products (name, description, price, stock, currency, images, seller_id) VALUES (?, ?, ?, ?, ?, ?, ?)');
    const info = stmt.run(name, description, price, stock, currency, JSON.stringify(images), req.user.id || null);
    res.status(201).json({ message: 'Product created', productId: info.lastInsertRowid });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Update product (admin)
router.put('/:id', authenticateToken, requireAdmin, (req, res) => {
  const { id } = req.params;
  const { name, description = '', price, stock, currency = 'INR', images = [] } = req.body;
  if (!name || price == null || stock == null) return res.status(400).json({ message: 'Name, price, stock required' });

  try {
    const stmt = db.prepare('UPDATE products SET name = ?, description = ?, price = ?, stock = ?, currency = ?, images = ? WHERE id = ?');
    const info = stmt.run(name, description, price, stock, currency, JSON.stringify(images), id);
    if (info.changes === 0) return res.status(404).json({ message: 'Product not found' });
    res.json({ message: 'Product updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Delete product (admin)
router.delete('/:id', authenticateToken, requireAdmin, (req, res) => {
  const { id } = req.params;
  try {
    const info = db.prepare('DELETE FROM products WHERE id = ?').run(id);
    if (info.changes === 0) return res.status(404).json({ message: 'Product not found' });
    res.json({ message: 'Product deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
