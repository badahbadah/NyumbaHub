const pool = require('./db');

async function createMatch({ request_id, property_id, agent_id }) {
  const result = await pool.query(
    `INSERT INTO property_matches (request_id, property_id, agent_id) VALUES ($1, $2, $3) RETURNING *`,
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

// Agent's own "My Submitted Matches" list, with enough context from both
// sides (the request they responded to, and the property they offered)
// to show something meaningful without extra round trips.
async function getMatchesByAgentId(agent_id) {
  const result = await pool.query(
    `SELECT property_matches.*,
            house_wanted_requests.city AS request_city,
            house_wanted_requests.property_type AS request_property_type,
            house_wanted_requests.budget_amount,
            properties.city AS property_city,
            properties.price_amount AS property_price
     FROM property_matches
     JOIN house_wanted_requests ON house_wanted_requests.id = property_matches.request_id
     JOIN properties ON properties.id = property_matches.property_id
     WHERE property_matches.agent_id = $1
     ORDER BY property_matches.created_at DESC`,
    [agent_id]
  );
  return result.rows;
}

async function countPendingMatchesForAgent(agent_id) {
  const result = await pool.query(
    `SELECT COUNT(*)::int AS pending_count FROM property_matches WHERE agent_id = $1 AND status = 'pending'`,
    [agent_id]
  );
  return result.rows[0].pending_count;
}

async function countPendingOffersForHunter(hunter_id) {
  const result = await pool.query(
    `SELECT COUNT(*)::int AS pending_count
     FROM property_matches
     JOIN house_wanted_requests ON house_wanted_requests.id = property_matches.request_id
     WHERE house_wanted_requests.hunter_id = $1 AND property_matches.status = 'pending'`,
    [hunter_id]
  );
  return result.rows[0].pending_count;
}

async function hasAcceptedMatchForProperty(property_id) {
  const result = await pool.query(
    `SELECT 1 FROM property_matches WHERE property_id = $1 AND status = 'accepted' LIMIT 1`,
    [property_id]
  );
  return result.rows.length > 0;
}

async function hasAcceptedMatchForRequest(request_id) {
  const result = await pool.query(
    `SELECT 1 FROM property_matches WHERE request_id = $1 AND status = 'accepted' LIMIT 1`,
    [request_id]
  );
  return result.rows.length > 0;
}

module.exports = {
  createMatch, getMatchesByRequestId, getMatchById, updateMatchStatus,
  getMatchesByAgentId, countPendingMatchesForAgent, countPendingOffersForHunter,
  hasAcceptedMatchForProperty, hasAcceptedMatchForRequest,
};