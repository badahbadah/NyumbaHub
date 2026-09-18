const pool = require('./db');

async function createRoom({ hostel_id, room_type, price_amount, price_period, total_beds, is_self_contained }) {
  const result = await pool.query(
    `INSERT INTO rooms (hostel_id, room_type, price_amount, price_period, total_beds, available_beds, is_self_contained)
     VALUES ($1, $2, $3, $4, $5, $5, $6)
     RETURNING *`,
    [hostel_id, room_type, price_amount, price_period || 'month', total_beds, !!is_self_contained]
  );
  return result.rows[0];
}

async function getRoomsByHostelId(hostel_id) {
  const result = await pool.query('SELECT * FROM rooms WHERE hostel_id = $1 ORDER BY created_at DESC', [hostel_id]);
  return result.rows;
}

async function getRoomById(id) {
  const result = await pool.query('SELECT * FROM rooms WHERE id = $1', [id]);
  return result.rows[0];
}

async function updateAvailableBeds(id, available_beds) {
  const result = await pool.query(
    'UPDATE rooms SET available_beds = $1 WHERE id = $2 RETURNING *',
    [available_beds, id]
  );
  return result.rows[0];
}

module.exports = { createRoom, getRoomsByHostelId, getRoomById, updateAvailableBeds };