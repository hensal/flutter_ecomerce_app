const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1]; 

  if (!token) {
    return res.status(401).json({ error: 'No token provided, user not authenticated' });
  }

  try {
    // Verify and decode the token using the secret key
    const decoded = jwt.verify(token, process.env.JWT_SECRET);  // Use your secret key here
    req.user = decoded;  // Add decoded user data to request object
    next();  // Continue to the next middleware or route handler
  } catch (err) {
    console.error('Invalid or expired token:', err);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};

module.exports = authenticateToken;

