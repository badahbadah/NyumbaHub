const pool = require('./db');

async function createUser({ full_name, phone_number, email, password_hash, role }) {
  const result = await pool.query(
    `INSERT INTO users (full_name, phone_number, email, password_hash, role)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, full_name, phone_number, email, role, created_at`,
    [full_name, phone_number, email, password_hash, role]
  );
  return result.rows[0];
}

async function findUserByPhone(phone_number) {
  const result = await pool.query(
    'SELECT * FROM users WHERE phone_number = $1',
    [phone_number]
  );
  return result.rows[0];
}

async function findUserByIdentifier(identifier) {
  const result = await pool.query(
    'SELECT * FROM users WHERE phone_number = $1 OR email = $1',
    [identifier]
  );
  return result.rows[0];
}

async function getUserById(id) {
  const result = await pool.query(
    'SELECT id, full_name, phone_number, email, role, verification_status, created_at FROM users WHERE id = $1',
    [id]
  );
  return result.rows[0];
}

async function getUserBasicById(id) {
  const result = await pool.query('SELECT id, full_name, role FROM users WHERE id = $1', [id]);
  return result.rows[0];
}

module.exports = { createUser, findUserByPhone, findUserByIdentifier, getUserById, getUserBasicById };