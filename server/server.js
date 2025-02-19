const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { loginUser, signUpUser, updateUserProfile } = require('./login');  
const pool = require('./database');
const authenticateToken = require('./middleware');
const { getSearchItems, saveSearchItem } = require('./search');

const app = express();
const PORT = 3006;

// Middleware to parse request body
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

app.use(cors());

// Login Route
//route must be after the middleware
app.post('/login', loginUser);
app.post('/signup', signUpUser); 
app.put('/api/update-profile', authenticateToken, updateUserProfile);
// Route to get search items
app.get('/get_search_items', getSearchItems);

// Route to save a search item
app.post('/save_search_item', saveSearchItem);

app.get('/user/profile', authenticateToken, async (req, res) => {
  const userId = req.user?.id; // Get user ID from the token

  if (!userId) {
    return res.status(401).json({ error: 'User not authenticated' });
  }

  try {
    const query = `SELECT name, email, image FROM users WHERE id = $1`;
    const result = await pool.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching user profile:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Route to add a product
app.post('/add-product', async (req, res) => {
  const {
    name,
    description,
    price, 
    discount,
    stock_quantity,
    category,
    image_url,
    rating,
    brand,
    weight,
    tags,
  } = req.body;       

  try {
    // SQL query to insert the product into the products table
    const result = await pool.query(
      'INSERT INTO products (name, description, price, discount, stock_quantity, category, image_url, rating, brand, weight, tags) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *',
      [
        name,
        description,
        price,
        discount,
        stock_quantity,
        category,
        image_url,
        rating,
        brand, 
        weight,
        tags,
      ]
    );  

    // Send back the created product details as response
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error inserting product:', err);
    res.status(500).json({ message: 'Internal Server Error' });
  }  
});    

// Route to fetch all products
app.get('/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching products:', err);
    res.status(500).json({ message: 'Failed to fetch products' });
  }
});

// Route to add to cart
app.post('/cart', authenticateToken, async (req, res) => {
  const { productId, quantity } = req.body;
  const userId = req.user?.id;

  if (!userId) {
    return res.status(401).json({ error: "User not authenticated" });
  }

  if (!productId || typeof productId !== 'number' || productId <= 0) {
    return res.status(400).json({ error: "Invalid product ID" });
  }

  if (!quantity || typeof quantity !== 'number' || quantity <= 0) {
    return res.status(400).json({ error: "Invalid quantity" });
  }

  try {
    // Check product existence
    const productQuery = `SELECT price::numeric FROM products WHERE id = $1`;
    const productResult = await pool.query(productQuery, [productId]);

    if (productResult.rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    const price = parseFloat(productResult.rows[0].price);

    // Check if product exists in cart
    const checkCartQuery = `SELECT id, quantity FROM cart WHERE product_id = $1 AND user_id = $2`;
    const existingCartItem = await pool.query(checkCartQuery, [productId, userId]);

    if (existingCartItem.rows.length > 0) {
      const newQuantity = existingCartItem.rows[0].quantity + quantity;
      const updateQuery = `
        UPDATE cart 
        SET quantity = $1::numeric, total_amount = $2::numeric * $1::numeric
        WHERE id = $3
      `;
      await pool.query(updateQuery, [newQuantity, price, existingCartItem.rows[0].id]);
      return res.status(200).json({ message: "Cart updated successfully" });
    } else {
      const insertQuery = `
        INSERT INTO cart (user_id, product_id, quantity, price, total_amount) 
        VALUES ($1, $2, $3::numeric, $4::numeric, $5::numeric)
      `;
      const totalAmount = price * quantity;
      await pool.query(insertQuery, [userId, productId, quantity, price, totalAmount]);
      return res.status(201).json({ message: "Product added to cart" });
    }
  } catch (err) {
    console.error("Error adding product to cart:", err);
    res.status(500).json({ error: "Internal server error", details: err.message });
  }
});


// Route to get all items in the cart, with product details
//It also get the product image url based on product id
app.get('/cart', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.id; // user info is attached to req.user from authenticateToken middleware

    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    // SQL query to join the cart table with the products table and filter by user_id
    const query = `
      SELECT c.id, c.product_id, c.quantity, p.name, p.image_url, p.price
      FROM cart c
      INNER JOIN products p ON c.product_id = p.id
      WHERE c.user_id = $1
    `;
    
    const result = await pool.query(query, [userId]);

    // Send back the cart data as response, including product details for the logged-in user
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching cart data:', err);
    res.status(500).json({ message: 'Failed to fetch cart data' });
  }
});

app.patch('/cart/:productId', authenticateToken, async (req, res) => {
  const { productId } = req.params;
  const { quantity } = req.body;
  const userId = req.user.id;  // Get the user ID from the token

  // Validate input
  if (!quantity || quantity < 1) {
    return res.status(400).json({ error: 'Invalid quantity' });
  }

  try {
    // Get the price of the product from the cart for the specific user
    const priceQuery = `
      SELECT price FROM cart 
      WHERE product_id = $1 AND user_id = $2
    `;
    const priceResult = await pool.query(priceQuery, [productId, userId]);

    if (priceResult.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found in cart for this user' });
    }

    const price = priceResult.rows[0].price;

    // Calculate the total amount (price * quantity)
    const totalAmount = price * quantity;

    // Update the quantity and total_amount in the cart
    const updateQuery = `
      UPDATE cart
      SET quantity = $1, total_amount = $2
      WHERE product_id = $3 AND user_id = $4
    `;
    await pool.query(updateQuery, [quantity, totalAmount, productId, userId]);

    res.status(200).json({ message: 'Quantity updated successfully' });
  } catch (error) {
    console.error('Error updating quantity:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.delete('/cart/:productId', authenticateToken, async (req, res) => {
  const { productId } = req.params;
  const userId = req.user.id;  // Assuming req.user is populated after token authentication

  try {
    const query = `
      DELETE FROM cart 
      WHERE product_id = $1 AND user_id = $2
    `;
    const result = await pool.query(query, [productId, userId]);

    if (result.rowCount > 0) {
      res.status(200).json({ message: 'Product removed from cart' });
    } else {
      res.status(404).json({ error: 'Product not found in cart for this user' });
    }
  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/toggle_favorite', authenticateToken, async (req, res) => {
  const { productId, isFavorite } = req.body;
  const userId = req.user.id; // Get the user ID from the token

  if (!productId) {
    return res.status(400).json({ error: 'Product ID is required' });
  }

  try {
    // Fetch the product price from the products table
    const productQuery = 'SELECT price FROM products WHERE id = $1';
    const productResult = await pool.query(productQuery, [productId]);

    if (productResult.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }

    const price = productResult.rows[0].price;
    const totalAmount = price; // Assuming quantity is 1 for now

    // Check if the product is already in the user's cart
    const checkProductQuery = 'SELECT * FROM cart WHERE product_id = $1 AND user_id = $2';
    const result = await pool.query(checkProductQuery, [productId, userId]);

    if (result.rows.length === 0) {
      // If the product is not found in the cart, add it with price, total_amount, and initial favorite status
      const addProductQuery = `
        INSERT INTO cart (product_id, user_id, favorite, price, total_amount)
        VALUES ($1, $2, $3, $4, $5)
      `;
      await pool.query(addProductQuery, [productId, userId, isFavorite, price, totalAmount]);
      return res.status(200).json({ message: 'Product added to cart with price and favorite status' });
    } else {
      // If the product exists, check if any field is null
      const cartItem = result.rows[0];
      const shouldUpdate =
        cartItem.price === null ||
        cartItem.total_amount === null ||
        cartItem.favorite === null;

      if (shouldUpdate) {
        // Update the product details in the cart if any field is null
        const updateProductQuery = `
          UPDATE cart
          SET favorite = $1, price = $2, total_amount = $3
          WHERE product_id = $4 AND user_id = $5
        `;
        await pool.query(updateProductQuery, [isFavorite, price, totalAmount, productId, userId]);
        return res.status(200).json({ message: 'Cart item updated with new values' });
      }

      // If no update is needed, just update the favorite status
      const toggleFavoriteQuery = `
        UPDATE cart
        SET favorite = $1
        WHERE product_id = $2 AND user_id = $3
      `;
      await pool.query(toggleFavoriteQuery, [isFavorite, productId, userId]);

      return res.status(200).json({ message: 'Favorite status updated successfully' });
    }
  } catch (error) {
    console.error('Error processing favorite action:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// Get Favorite Products from Cart Table
app.get('/get_favorite_products', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id; // Use the user ID from the authenticated token
    const query = `
      SELECT 
        p.id, 
        p.name, 
        p.image_url, 
        p.price, 
        p.rating, 
        c.favorite
      FROM 
        products p
      INNER JOIN 
        cart c 
      ON 
        p.id = c.product_id
      WHERE 
        c.favorite = TRUE AND c.user_id = $1;
    `;
    const result = await pool.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No favorite products found.' });
    }

    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching favorite products:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

//get products based on category
app.get('/api/products', async (req, res) => {
  const categoryKey = req.query.categoryId;
  const limit = parseInt(req.query.limit) || 10;
  const offset = parseInt(req.query.offset) || 0;

  if (!categoryKey) {
    return res.status(400).json({ message: 'Category ID is required' });
  }

  const validCategories = [
    'clothes', 'books', 'shoes', 'watches', 'mobiles', 'laptops', 'cameras', 'cars'
  ];

  if (!validCategories.includes(categoryKey.toLowerCase())) {
    return res.status(400).json({ message: 'Invalid category' });
  }

  try {
    const result = await pool.query(
      'SELECT name, price, image_url FROM products WHERE category = $1 LIMIT $2 OFFSET $3',
      [categoryKey, limit, offset]
    );

    const responseData = result.rows;

    if (responseData.length > 0) {
      res.status(200).json(responseData);
    } else {
      res.status(404).json({ message: 'No products found for this category' });
    }
  } catch (error) {
    console.error('Database Error:', error);
    res.status(500).json({ message: 'Error fetching products', error });
  }
});


app.get('/', (req, res) => {
  res.send('Server is running');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});




