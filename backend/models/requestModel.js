const pool = require('./db');

async function createRequest({ hunter_id, property_type, target_area, city, budget_amount, budget_period, notes }) {
  const result = await pool.query(
    `INSERT INTO house_wanted_requests (hunter_id, property_type, target_area, city, budget_amount, budget_period, notes)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING *`,
    [hunter_id, property_type, target_area || null, city, budget_amount, budget_period || 'month', notes || null]
  );
  return result.rows[0];
}

async function getAllRequests({ city, property_type, status } = {}) {
  const conditions = [];
  const values = [];

  if (city) { values.push(city); conditions.push(`city = $${values.length}`); }
  if (property_type) { values.push(property_type); conditions.push(`property_type = $${values.length}`); }
  if (status) { values.push(status); conditions.push(`status = $${values.length}`); }

  const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query(
    `SELECT * FROM house_wanted_requests ${whereClause} ORDER BY created_at DESC`,
    values
  );
  return result.rows;
}

async function getRequestById(id) {
  const result = await pool.query('SELECT * FROM house_wanted_requests WHERE id = $1', [id]);
  return result.rows[0];
}

async function updateRequestStatus(id, status) {
  const result = await pool.query(
    'UPDATE house_wanted_requests SET status = $1 WHERE id = $2 RETURNING *',
    [status, id]
  );
  return result.rows[0];
}

module.exports = { createRequest, getAllRequests, getRequestById, updateRequestStatus };