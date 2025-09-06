require('dotenv').config();
const express = require('express');
const Database = require('better-sqlite3');
const bcrypt = require('bcrypt');
const Razorpay = require('razorpay');
const crypto = require('crypto');

const app = express();
const port = 3000;

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

app.use(express.json());

const db = new Database('users.db');

db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user'
  )
`);

db.exec(`
  CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    stock INTEGER NOT NULL
  )
`);

db.exec(`
  CREATE TABLE IF NOT EXISTS cart_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
  );

  CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS wishlist_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE (user_id, product_id)
  );

  CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    total_amount REAL NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price REAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
  );

  CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- e.g., 'order_status', 'new_review', 'promotion'
    is_read INTEGER DEFAULT 0, -- 0 for false, 1 for true
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS user_ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rater_id INTEGER NOT NULL,
    ratee_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rater_id) REFERENCES users(id),
    FOREIGN KEY (ratee_id) REFERENCES users(id),
    UNIQUE (rater_id, ratee_id)
  );

  CREATE TABLE IF NOT EXISTS reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporter_id INTEGER NOT NULL,
    reported_user_id INTEGER,
    reported_product_id INTEGER,
    reason TEXT NOT NULL,
    status TEXT DEFAULT 'pending', -- e.g., 'pending', 'reviewed', 'resolved'
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(id),
    FOREIGN KEY (reported_user_id) REFERENCES users(id),
    FOREIGN KEY (reported_product_id) REFERENCES products(id)
  );

  CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_id INTEGER NOT NULL,
    receiver_id INTEGER NOT NULL,
    product_id INTEGER,
    message TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
  )
`);

// Send a message
app.post('/messages', (req, res) => {
  const { senderId, receiverId, productId, message } = req.body;

  if (!senderId || !receiverId || !message) {
    return res.status(400).json({ message: 'Sender ID, Receiver ID, and message are required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO messages (sender_id, receiver_id, product_id, message) VALUES (?, ?, ?, ?)');
    stmt.run(senderId, receiverId, productId, message);
    res.status(201).json({ message: 'Message sent successfully' });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get messages between two users (conversation history)
app.get('/messages/:user1Id/:user2Id', (req, res) => {
  const { user1Id, user2Id } = req.params;

  try {
    const stmt = db.prepare(
      `SELECT messages.*, 
              sender.username AS sender_username, 
              receiver.username AS receiver_username, 
              products.name AS product_name
       FROM messages
       JOIN users AS sender ON messages.sender_id = sender.id
       JOIN users AS receiver ON messages.receiver_id = receiver.id
       LEFT JOIN products ON messages.product_id = products.id
       WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
       ORDER BY created_at ASC`
    );
    const messages = stmt.all(user1Id, user2Id, user2Id, user1Id);
    res.status(200).json(messages);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Register route
app.post('/register', async (req, res) => {
  const { username, password, role = 'user' } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: 'Username and password are required' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const stmt = db.prepare('INSERT INTO users (username, password, role) VALUES (?, ?, ?)');
    stmt.run(username, hashedPassword, role);
    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return res.status(409).json({ message: 'Username already exists' });
    }
    console.error('Registration error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Submit a review for a product
app.post('/products/:productId/reviews', (req, res) => {
  const { productId } = req.params;
  const { userId, rating, comment } = req.body; // Assuming userId is sent from frontend for now

  if (!userId || !rating || rating < 1 || rating > 5) {
    return res.status(400).json({ message: 'User ID and a valid rating (1-5) are required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO reviews (product_id, user_id, rating, comment) VALUES (?, ?, ?, ?)');
    stmt.run(productId, userId, rating, comment);
    res.status(201).json({ message: 'Review submitted successfully' });
  } catch (error) {
    console.error('Error submitting review:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get reviews for a product
app.get('/products/:productId/reviews', (req, res) => {
  const { productId } = req.params;

  try {
    const stmt = db.prepare('SELECT reviews.*, users.username FROM reviews JOIN users ON reviews.user_id = users.id WHERE product_id = ? ORDER BY created_at DESC');
    const reviews = stmt.all(productId);
    res.status(200).json(reviews);
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Add item to wishlist
app.post('/wishlist', (req, res) => {
  const { userId, productId } = req.body;

  if (!userId || !productId) {
    return res.status(400).json({ message: 'User ID and Product ID are required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO wishlist_items (user_id, product_id) VALUES (?, ?)');
    stmt.run(userId, productId);
    res.status(201).json({ message: 'Product added to wishlist' });
  } catch (error) {
    if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return res.status(409).json({ message: 'Product already in wishlist' });
    }
    console.error('Error adding to wishlist:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Remove item from wishlist
app.delete('/wishlist/:userId/:productId', (req, res) => {
  const { userId, productId } = req.params;

  try {
    const stmt = db.prepare('DELETE FROM wishlist_items WHERE user_id = ? AND product_id = ?');
    const info = stmt.run(userId, productId);

    if (info.changes === 0) {
      return res.status(404).json({ message: 'Product not found in wishlist' });
    }
    res.status(200).json({ message: 'Product removed from wishlist' });
  } catch (error) {
    console.error('Error removing from wishlist:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get user's wishlist
app.get('/wishlist/:userId', (req, res) => {
  const { userId } = req.params;

  try {
    const stmt = db.prepare('SELECT products.* FROM wishlist_items JOIN products ON wishlist_items.product_id = products.id WHERE wishlist_items.user_id = ?');
    const wishlist = stmt.all(userId);
    res.status(200).json(wishlist);
  } catch (error) {
    console.error('Error fetching wishlist:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Add a notification
app.post('/notifications', (req, res) => {
  const { userId, message, type } = req.body;

  if (!userId || !message || !type) {
    return res.status(400).json({ message: 'User ID, message, and type are required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO notifications (user_id, message, type) VALUES (?, ?, ?)');
    stmt.run(userId, message, type);
    res.status(201).json({ message: 'Notification added successfully' });
  } catch (error) {
    console.error('Error adding notification:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get user's notifications
app.get('/notifications/:userId', (req, res) => {
  const { userId } = req.params;

  try {
    const stmt = db.prepare('SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC');
    const notifications = stmt.all(userId);
    res.status(200).json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Mark notification as read
app.put('/notifications/:notificationId/read', (req, res) => {
  const { notificationId } = req.params;

  try {
    const stmt = db.prepare('UPDATE notifications SET is_read = 1 WHERE id = ?');
    const info = stmt.run(notificationId);

    if (info.changes === 0) {
      return res.status(404).json({ message: 'Notification not found' });
    }
    res.status(200).json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Submit a user rating
app.post('/user-ratings', (req, res) => {
  const { raterId, rateeId, rating, comment } = req.body;

  if (!raterId || !rateeId || !rating || rating < 1 || rating > 5) {
    return res.status(400).json({ message: 'Rater ID, Ratee ID, and a valid rating (1-5) are required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO user_ratings (rater_id, ratee_id, rating, comment) VALUES (?, ?, ?, ?)');
    stmt.run(raterId, rateeId, rating, comment);
    res.status(201).json({ message: 'User rating submitted successfully' });
  } catch (error) {
    if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return res.status(409).json({ message: 'You have already rated this user.' });
    }
    console.error('Error submitting user rating:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get user's average rating and reviews
app.get('/user-ratings/:userId', (req, res) => {
  const { userId } = req.params;

  try {
    const avgRatingStmt = db.prepare('SELECT AVG(rating) AS average_rating FROM user_ratings WHERE ratee_id = ?');
    const avgRating = avgRatingStmt.get(userId);

    const reviewsStmt = db.prepare('SELECT user_ratings.*, users.username AS rater_username FROM user_ratings JOIN users ON user_ratings.rater_id = users.id WHERE ratee_id = ? ORDER BY created_at DESC');
    const reviews = reviewsStmt.all(userId);

    res.status(200).json({ averageRating: avgRating.average_rating, reviews });
  } catch (error) {
    console.error('Error fetching user ratings:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Submit a report
app.post('/reports', (req, res) => {
  const { reporterId, reportedUserId, reportedProductId, reason } = req.body;

  if (!reporterId || !reason || (!reportedUserId && !reportedProductId)) {
    return res.status(400).json({ message: 'Reporter ID, reason, and either reported user ID or product ID are required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO reports (reporter_id, reported_user_id, reported_product_id, reason) VALUES (?, ?, ?, ?)');
    stmt.run(reporterId, reportedUserId, reportedProductId, reason);
    res.status(201).json({ message: 'Report submitted successfully' });
  } catch (error) {
    console.error('Error submitting report:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Login route
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: 'Username and password are required' });
  }

  try {
    const stmt = db.prepare('SELECT * FROM users WHERE username = ?');
    const user = stmt.get(username);

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    res.status(200).json({ message: 'Login successful', userId: user.id, role: user.role });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get all products
app.get('/products', (req, res) => {
  try {
    const { search, sortBy, order } = req.query;
    let query = 'SELECT * FROM products';
    const params = [];

    if (search) {
      query += ' WHERE name LIKE ? OR description LIKE ?';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm);
    }

    if (sortBy) {
      const validSortBy = ['name', 'price', 'stock'];
      if (!validSortBy.includes(sortBy)) {
        return res.status(400).json({ message: 'Invalid sortBy parameter' });
      }
      const sortOrder = (order && order.toLowerCase() === 'desc') ? 'DESC' : 'ASC';
      query += ` ORDER BY ${sortBy} ${sortOrder}`;
    }

    const products = db.prepare(query).all(...params);
    res.status(200).json(products);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Add new product (Admin only)
app.post('/products', (req, res) => {
  const { name, description, price, stock } = req.body;

  if (!name || !price || !stock) {
    return res.status(400).json({ message: 'Name, price, and stock are required' });
  }

  try {
    const stmt = db.prepare('INSERT INTO products (name, description, price, stock) VALUES (?, ?, ?, ?)');
    stmt.run(name, description, price, stock);
    res.status(201).json({ message: 'Product added successfully' });
  } catch (error) {
    console.error('Error adding product:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Update product (Admin only)
app.put('/products/:id', (req, res) => {
  const { id } = req.params;
  const { name, description, price, stock } = req.body;

  if (!name || !price || !stock) {
    return res.status(400).json({ message: 'Name, price, and stock are required' });
  }

  try {
    const stmt = db.prepare('UPDATE products SET name = ?, description = ?, price = ?, stock = ? WHERE id = ?');
    const result = stmt.run(name, description, price, stock, id);
    if (result.changes > 0) {
      res.status(200).json({ message: 'Product updated successfully' });
    } else {
      res.status(404).json({ message: 'Product not found' });
    }
  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Delete product (Admin only)
app.delete('/products/:id', (req, res) => {
  const { id } = req.params;

  try {
    const result = db.prepare('DELETE FROM products WHERE id = ?').run(id);
    if (result.changes > 0) {
      res.status(200).json({ message: 'Product deleted successfully' });
    } else {
      res.status(404).json({ message: 'Product not found' });
    }
  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Add item to cart
app.post('/cart', (req, res) => {
  const { userId, productId, quantity } = req.body;

  if (!userId || !productId || !quantity) {
    return res.status(400).json({ message: 'User ID, product ID, and quantity are required' });
  }

  try {
    // Check if item already exists in cart for the user
    const existingItem = db.prepare('SELECT * FROM cart_items WHERE user_id = ? AND product_id = ?').get(userId, productId);

    if (existingItem) {
      // Update quantity if item exists
      const newQuantity = existingItem.quantity + quantity;
      db.prepare('UPDATE cart_items SET quantity = ? WHERE id = ?').run(newQuantity, existingItem.id);
      res.status(200).json({ message: 'Cart item quantity updated successfully' });
    } else {
      // Add new item to cart
      db.prepare('INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)').run(userId, productId, quantity);
      res.status(201).json({ message: 'Item added to cart successfully' });
    }
  } catch (error) {
    console.error('Error adding item to cart:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get cart items for a user
app.get('/cart/:userId', (req, res) => {
  const { userId } = req.params;

  try {
    const cartItems = db.prepare(
      `SELECT ci.id, ci.product_id, ci.quantity, p.name, p.price
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       WHERE ci.user_id = ?`
    ).all(userId);
    res.status(200).json(cartItems);
  } catch (error) {
    console.error('Error fetching cart items:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Remove item from cart
app.delete('/cart/:cartItemId', (req, res) => {
  const { cartItemId } = req.params;

  try {
    const result = db.prepare('DELETE FROM cart_items WHERE id = ?').run(cartItemId);
    if (result.changes > 0) {
      res.status(200).json({ message: 'Item removed from cart successfully' });
    } else {
      res.status(404).json({ message: 'Cart item not found' });
    }
  } catch (error) {
    console.error('Error removing item from cart:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get all users (Admin only)
app.get('/users', (req, res) => {
  try {
    const users = db.prepare('SELECT id, username, role FROM users').all();
    res.status(200).json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Update user role (Admin only)
app.put('/users/:id/role', (req, res) => {
  const { id } = req.params;
  const { role } = req.body;

  if (!role) {
    return res.status(400).json({ message: 'Role is required' });
  }

  try {
    const stmt = db.prepare('UPDATE users SET role = ? WHERE id = ?');
    const result = stmt.run(role, id);
    if (result.changes > 0) {
      res.status(200).json({ message: 'User role updated successfully' });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error updating user role:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Delete user (Admin only)
app.delete('/users/:id', (req, res) => {
  const { id } = req.params;

  try {
    const result = db.prepare('DELETE FROM users WHERE id = ?').run(id);
    if (result.changes > 0) {
      res.status(200).json({ message: 'User deleted successfully' });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Checkout route
// Razorpay order creation
app.post('/razorpay/order', async (req, res) => {
  const { amount, currency } = req.body;

  try {
    const options = {
      amount: amount * 100, // amount in smallest currency unit (paise)
      currency,
      receipt: 'receipt_order_1',
      payment_capture: 1 // auto capture
    };
    const order = await razorpay.orders.create(options);
    res.status(200).json(order);
  } catch (error) {
    console.error('Error creating Razorpay order:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.post('/checkout', (req, res) => {
  const { userId, totalAmount } = req.body;

  if (!userId || !totalAmount) {
    return res.status(400).json({ message: 'User ID and total amount are required' });
  }

  let transaction;
  try {
    transaction = db.transaction(() => {
      // 1. Create a new order
      const orderDate = new Date().toISOString();
      const orderStmt = db.prepare('INSERT INTO orders (user_id, order_date, total_amount) VALUES (?, ?, ?)');
      const orderInfo = orderStmt.run(userId, orderDate, totalAmount);
      const orderId = orderInfo.lastInsertRowid;

      // 2. Get cart items for the user
      const cartItems = db.prepare('SELECT ci.product_id, ci.quantity, p.price, p.stock FROM cart_items ci JOIN products p ON ci.product_id = p.id WHERE ci.user_id = ?').all(userId);

      if (cartItems.length === 0) {
        throw new Error('Cart is empty');
      }

      // 3. Add cart items to order_items and update product stock
      const orderItemStmt = db.prepare('INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)');
      const updateStockStmt = db.prepare('UPDATE products SET stock = stock - ? WHERE id = ?');

      for (const item of cartItems) {
        if (item.stock < item.quantity) {
          throw new Error(`Not enough stock for product ${item.product_id}`);
        }
        orderItemStmt.run(orderId, item.product_id, item.quantity, item.price);
        updateStockStmt.run(item.quantity, item.product_id);
      }

      // 4. Clear the user's cart
      db.prepare('DELETE FROM cart_items WHERE user_id = ?').run(userId);

      res.status(201).json({ message: 'Checkout successful', orderId: orderId });
    });
    transaction();
  } catch (error) {
    console.error('Checkout error:', error);
    if (error.message === 'Cart is empty' || error.message.startsWith('Not enough stock')) {
      res.status(400).json({ message: error.message });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// Razorpay payment verification
app.get('/razorpay/key', (req, res) => {
  res.send({ key: process.env.RAZORPAY_KEY_ID });
});

app.post('/razorpay/verify', async (req, res) => {
  const { order_id, payment_id, signature } = req.body;

  const body = order_id + "|" + payment_id;

  const crypto = require('crypto');
  const expectedSignature = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
                                  .update(body.toString())
                                  .digest('hex');

  if (expectedSignature === signature) {
    res.status(200).json({ message: 'Payment verified successfully' });
  } else {
    res.status(400).json({ message: 'Invalid signature' });
  }
});

app.listen(port, () => {
  console.log(`Backend server listening at http://localhost:${port}`);
});