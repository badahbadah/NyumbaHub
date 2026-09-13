const pool = require('./db');

async function findBookingByStudentAndHostel(student_id, hostel_id) {
  const result = await pool.query(
    'SELECT * FROM bookings WHERE student_id = $1 AND hostel_id = $2 ORDER BY created_at DESC LIMIT 1',
    [student_id, hostel_id]
  );
  return result.rows[0];
}

async function getBookingById(id) {
  const result = await pool.query('SELECT * FROM bookings WHERE id = $1', [id]);
  return result.rows[0];
}

async function updateBookingPaymentStatus(id, { payment_status, status, payment_method }) {
  const result = await pool.query(
    `UPDATE bookings SET payment_status = $1, status = $2, payment_method = $3 WHERE id = $4 RETURNING *`,
    [payment_status, status, payment_method, id]
  );
  return result.rows[0];
}

module.exports = { findBookingByStudentAndHostel, getBookingById, updateBookingPaymentStatus };