const pool = require('./db');

async function getAllInstitutions() {
  const result = await pool.query('SELECT * FROM institutions ORDER BY name ASC');
  return result.rows;
}

module.exports = { getAllInstitutions };