const pool = require('./db');

async function createTransaction({ user_id, related_type, related_id, amount, provider, provider_reference, status }) {
  const result = await pool.query(
    `INSERT INTO transactions (user_id, related_type, related_id, amount, provider, provider_reference, status)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING *`,
    [user_id, related_type, related_id, amount, provider, provider_reference, status]
  );
  return result.rows[0];
}

async function findTransactionByReference(provider_reference) {
  const result = await pool.query(
    'SELECT * FROM transactions WHERE provider_reference = $1',
    [provider_reference]
  );
  return result.rows[0];
}

async function updateTransactionStatus(provider_reference, status) {
  const result = await pool.query(
    'UPDATE transactions SET status = $1 WHERE provider_reference = $2 RETURNING *',
    [status, provider_reference]
  );
  return result.rows[0];
}

module.exports = { createTransaction, findTransactionByReference, updateTransactionStatus };