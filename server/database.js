const { Pool } = require('pg');
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'flutter',
  password: 'password',
  port: 5433,
});

module.exports = pool;
