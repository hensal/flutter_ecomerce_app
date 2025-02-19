const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./database');
require('dotenv').config();

// Login Route
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  // Basic validation for login
  if (!email || !password) {
    return res.status(400).json({ message: 'Both email and password are required' });
  }

  try {
    // Fetch user from the database
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Ensure JWT_SECRET is defined in the .env file
    if (!process.env.JWT_SECRET) {
      console.error("JWT_SECRET is not defined in .env");
      return res.status(500).json({ message: "Server configuration error" });
    }

    // Generate a JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email }, // Payload 
      process.env.JWT_SECRET, // Secret key loaded from .env
     // { expiresIn: '1h' } // Token expiration time
    );

    // Store the token in the user's record in the database
    await pool.query('UPDATE users SET token = $1 WHERE id = $2', [token, user.id]);

    // Return the token and user details
    res.status(200).json({
      message: 'Login successful',
      token, // Send the token back to the client
      user: { name: user.name, email: user.email },
    });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ message: 'Error logging in', error: error.message });
  }
};


// Sign-up Route
const signUpUser = async (req, res) => {
  const { name, email, password } = req.body;

  // Basic validation for sign-up
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  // Check if email contains "@gmail.com"
  if (!email.includes('@gmail.com')) {
    return res.status(400).json({ message: 'Email must be a Gmail address' });
  }

  // Check if password length is at least 5 characters
  if (password.length < 5) {
    return res.status(400).json({ message: 'Password must be at least 5 characters long' });
  }

  try {
    // Hash the password before storing it
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user into the database
    const result = await pool.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING *',
      [name, email, hashedPassword]
    );

    res.status(201).json({ message: 'User created successfully', user: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating user' });
  }
};

// API to update user profile

const updateUserProfile = async (req, res) => {
  const { name, email, image } = req.body;
  const userId = req.user?.id;

  console.log('Received profile update request:', { name, email, image });

  // Check if the user is authenticated
  if (!userId) {
    return res.status(401).json({ message: "User not authenticated" });
  }

  // Strict email validation to only allow emails in the format: example@gmail.com
  const emailRegex = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: "Invalid email. Please enter a valid Gmail address." });
  }

  try {
    // Get the current email from the database for the authenticated user
    const currentEmailQuery = "SELECT email FROM users WHERE id = $1";
    const currentEmailResult = await pool.query(currentEmailQuery, [userId]);

    if (currentEmailResult.rowCount === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const currentEmail = currentEmailResult.rows[0].email;

    // If the new email is the same as the current email, don't proceed with update
    if (email === currentEmail) {
      return res.status(400).json({ message: "The email is the same as the previous one, no update needed." });
    }

    // Check if email already exists for another user
    const emailCheckQuery =
      "SELECT id FROM users WHERE email = $1 AND id != $2";
    const emailCheckResult = await pool.query(emailCheckQuery, [email, userId]);

    if (emailCheckResult.rowCount > 0) {
      return res.status(400).json({ message: "Email already taken" });
    }

    // Update user information
    const updateQuery =
      "UPDATE users SET name = $1, email = $2, image = $3 WHERE id = $4";
    await pool.query(updateQuery, [name, email, image, userId]);

    res.status(200).json({ message: "Profile updated successfully" });
  } catch (error) {
    console.error("Error updating profile:", error);

    // Provide more details for debugging in development mode
    const errorMessage =
      process.env.NODE_ENV === "development"
        ? error.message
        : "An error occurred";

    res.status(500).json({ message: errorMessage });
  }
};


// Export the functions properly
module.exports = { loginUser, signUpUser, updateUserProfile };