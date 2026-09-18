const pool = require('./db');

async function findActiveBookingByStudentAndHostel(student_id, hostel_id) {
  const result = await pool.query(
    `SELECT * FROM bookings WHERE student_id = $1 AND hostel_id = $2 AND status != 'cancelled' LIMIT 1`,
    [student_id, hostel_id]
  );
  return result.rows[0];
}

async function getBookingById(id) {
  const result = await pool.query('SELECT * FROM bookings WHERE id = $1', [id]);
  return result.rows[0];
}

async function updateBookingPaymentStatus(id, payment_status, status) {
  const result = await pool.query(
    'UPDATE bookings SET payment_status = $1, status = $2 WHERE id = $3 RETURNING *',
    [payment_status, status, id]
  );
  return result.rows[0];
}

async function updateBookingDecision(id, decision) {
  const result = await pool.query(
    'UPDATE bookings SET owner_decision = $1 WHERE id = $2 RETURNING *',
    [decision, id]
  );
  return result.rows[0];
}

async function getBookingsByStudentId(student_id) {
  const result = await pool.query(
    `SELECT bookings.*, hostels.name AS hostel_name, hostels.owner_id AS hostel_owner_id, rooms.room_type
     FROM bookings
     JOIN hostels ON hostels.id = bookings.hostel_id
     JOIN rooms ON rooms.id = bookings.room_id
     WHERE bookings.student_id = $1
     ORDER BY bookings.created_at DESC`,
    [student_id]
  );
  return result.rows;
}

async function getBookingsByHostelId(hostel_id) {
  const result = await pool.query(
    `SELECT bookings.*, users.full_name AS student_name, rooms.room_type
     FROM bookings
     JOIN users ON users.id = bookings.student_id
     JOIN rooms ON rooms.id = bookings.room_id
     WHERE bookings.hostel_id = $1
     ORDER BY bookings.created_at DESC`,
    [hostel_id]
  );
  return result.rows;
}

async function countPendingBookingsForOwner(owner_id) {
  const result = await pool.query(
    `SELECT COUNT(*)::int AS pending_count
     FROM bookings
     JOIN hostels ON hostels.id = bookings.hostel_id
     WHERE hostels.owner_id = $1 AND bookings.status != 'cancelled' AND bookings.owner_decision = 'pending'`,
    [owner_id]
  );
  return result.rows[0].pending_count;
}

module.exports = {
  findActiveBookingByStudentAndHostel,
  getBookingById,
  updateBookingPaymentStatus,
  updateBookingDecision,
  getBookingsByStudentId,
  getBookingsByHostelId,
  countPendingBookingsForOwner,
};