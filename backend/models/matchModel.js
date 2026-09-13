const pool = require('./db');

async function createMatch({ request_id, property_id, agent_id }) {
  const result = await pool.query(
    `INSERT INTO property_matches (request_id, property_id, agent_id)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [request_id, property_id, agent_id]
  );
  return result.rows[0];
}

async function getMatchesByRequestId(request_id) {
  const result = await pool.query(
    `SELECT property_matches.*, properties.city, properties.area, properties.price_amount, properties.description
     FROM property_matches
     JOIN properties ON properties.id = property_matches.property_id
     WHERE request_id = $1
     ORDER BY property_matches.created_at DESC`,
    [request_id]
  );
  return result.rows;
}

async function getMatchById(id) {
  const result = await pool.query('SELECT * FROM property_matches WHERE id = $1', [id]);
  return result.rows[0];
}

async function updateMatchStatus(id, status) {
  const result = await pool.query(
    'UPDATE property_matches SET status = $1 WHERE id = $2 RETURNING *',
    [status, id]
  );
  return result.rows[0];
}

module.exports = { createMatch, getMatchesByRequestId, getMatchById, updateMatchStatus };