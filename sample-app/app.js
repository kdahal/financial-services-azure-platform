const express = require('express');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Placeholder secret for JWT (in prod, fetch from Key Vault)
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';

// Protected route: Treasury transactions (requires valid JWT)
app.get('/treasury/transactions', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    // Simulate financial data fetch (e.g., from Cosmos DB)
    res.json({
      transactions: [
        { id: 1, amount: 10000, currency: 'USD', status: 'Completed' },
        { id: 2, amount: 25000, currency: 'JPY', status: 'Pending' }
      ],
      user: decoded.sub
    });
  } catch (err) {
    res.status(403).json({ error: 'Invalid token' });
  }
});

// Health check
app.get('/health', (req, res) => res.json({ status: 'OK' }));

app.listen(PORT, () => {
  console.log(`Treasury API running on port ${PORT}`);
});