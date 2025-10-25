cat > app.js << 'EOF'
const express = require('express');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'default-secret-for-dev';  // From K8s secret

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Treasury API is running' });
});

app.get('/treasury/balance', (req, res) => {
  // Simulate JWT validation for /treasury endpoints
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized: Token required' });
  }

  try {
    jwt.verify(token, JWT_SECRET);
    res.json({ balance: 1000000, currency: 'USD', message: 'Balance retrieved successfully' });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.listen(PORT, () => {
  console.log(`Treasury API listening on port ${PORT}`);
});
EOF