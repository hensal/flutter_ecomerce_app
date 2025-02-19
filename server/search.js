const pool = require('./database');
// GET endpoint to retrieve stored search items
async function getSearchItems(req, res) {
  try {
    const result = await pool.query('SELECT search_items FROM users WHERE id = 1');
    if (result.rows.length > 0) {
      const searchItems = result.rows[0].search_items || [];
      res.json({ search_items: searchItems });
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
}

// POST endpoint to save a new search item
async function saveSearchItem(req, res) {
  const { search_text } = req.body;

  if (!search_text) {
    return res.status(400).json({ error: 'Search text is required' });
  }

  try {
    const result = await pool.query('SELECT search_items FROM users WHERE id = 1');
    if (result.rows.length > 0) {
      let currentItems = result.rows[0].search_items || [];
      currentItems.push(search_text);

      await pool.query('UPDATE users SET search_items = $1 WHERE id = 1', [currentItems]);
      res.json({ message: 'Search item saved successfully' });
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
}

// Export functions
module.exports = { getSearchItems, saveSearchItem };
