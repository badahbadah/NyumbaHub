const pool = require('../models/db');
const {
  getBookingsByStudentId,
  getBookingsByHostelId,
  countPendingBookingsForOwner,
} = require('../models/bookingModel');
const { getHostelById } = require('../models/hostelModel');
const { getRoomById } = require('../models/roomModel');

exports.create = async (req, res) => {
  const client = await pool.connect();
  try {
    const { room_id, deposit_amount } = req.body;

    if (!room_id || !deposit_amount) {
      client.release();
      return res.status(400).json({ error: 'room_id and deposit_amount are required' });
    }

    const room = await getRoomById(room_id);
    if (!room) {
      client.release();
      return res.status(404).json({ error: 'Room not found' });
    }

    const existingBooking = await pool.query(
      `SELECT * FROM bookings WHERE student_id = $1 AND hostel_id = $2 AND status != 'cancelled' LIMIT 1`,
      [req.user.id, room.hostel_id]
    );
    if (existingBooking.rows[0]) {
      client.release();
      return res.status(409).json({ error: 'You already have an active reservation at this hostel' });
    }

    await client.query('BEGIN');

    const roomResult = await client.query(
      `UPDATE rooms SET available_beds = available_beds - 1
       WHERE id = $1 AND available_beds > 0
       RETURNING hostel_id`,
      [room_id]
    );

    if (roomResult.rows.length === 0) {
      await client.query('ROLLBACK');
      client.release();
      return res.status(409).json({ error: 'No beds available in this room' });
    }

    const { hostel_id } = roomResult.rows[0];
    const booking_code = 'NH-' + Math.random().toString(36).substring(2, 8).toUpperCase();

    const bookingResult = await client.query(
      `INSERT INTO bookings (student_id, room_id, hostel_id, deposit_amount, booking_code)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [req.user.id, room_id, hostel_id, deposit_amount, booking_code]
    );

    await client.query('COMMIT');
    client.release();

    res.status(201).json({ message: 'Booking created successfully', booking: bookingResult.rows[0] });
  } catch (err) {
    await client.query('ROLLBACK');
    client.release();
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while creating the booking' });
  }
};

exports.listMine = async (req, res) => {
  try {
    const bookings = await getBookingsByStudentId(req.user.id);
    res.json({ bookings });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching your bookings' });
  }
};

exports.listForHostel = async (req, res) => {
  try {
    const { id } = req.params;
    const hostel = await getHostelById(id);
    if (!hostel) return res.status(404).json({ error: 'Hostel not found' });
    if (hostel.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only view bookings for your own hostel' });
    }
    const bookings = await getBookingsByHostelId(id);
    res.json({ bookings });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching bookings' });
  }
};

exports.approve = async (req, res) => {
  try {
    const { id } = req.params;
    const bookingResult = await pool.query('SELECT * FROM bookings WHERE id = $1', [id]);
    const booking = bookingResult.rows[0];
    if (!booking) return res.status(404).json({ error: 'Booking not found' });

    const hostel = await getHostelById(booking.hostel_id);
    if (hostel.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only manage bookings for your own hostel' });
    }

    const updated = await pool.query(
      `UPDATE bookings SET owner_decision = 'approved' WHERE id = $1 RETURNING *`,
      [id]
    );
    res.json({ message: 'Booking approved', booking: updated.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while approving the booking' });
  }
};

// Denying frees the bed immediately, since the owner won't be honoring this reservation.
exports.reject = async (req, res) => {
  const client = await pool.connect();
  try {
    const { id } = req.params;
    const bookingResult = await client.query('SELECT * FROM bookings WHERE id = $1', [id]);
    const booking = bookingResult.rows[0];
    if (!booking) { client.release(); return res.status(404).json({ error: 'Booking not found' }); }

    const hostel = await getHostelById(booking.hostel_id);
    if (hostel.owner_id !== req.user.id) {
      client.release();
      return res.status(403).json({ error: 'You can only manage bookings for your own hostel' });
    }

    await client.query('BEGIN');

    if (!booking.bed_released) {
      await client.query('UPDATE rooms SET available_beds = available_beds + 1 WHERE id = $1', [booking.room_id]);
      await client.query('UPDATE bookings SET bed_released = true WHERE id = $1', [id]);
    }

    const updated = await client.query(
      `UPDATE bookings SET owner_decision = 'denied' WHERE id = $1 RETURNING *`,
      [id]
    );

    await client.query('COMMIT');
    client.release();

    res.json({ message: 'Booking denied', booking: updated.rows[0] });
  } catch (err) {
    await client.query('ROLLBACK');
    client.release();
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the booking' });
  }
};

// Student-only. Permanently removes a booking that hasn't been approved yet.
// Frees the bed only if it hasn't already been freed (e.g. by a prior denial).
exports.remove = async (req, res) => {
  const client = await pool.connect();
  try {
    const { id } = req.params;
    const bookingResult = await client.query('SELECT * FROM bookings WHERE id = $1', [id]);
    const booking = bookingResult.rows[0];

    if (!booking) { client.release(); return res.status(404).json({ error: 'Booking not found' }); }
    if (booking.student_id !== req.user.id) {
      client.release();
      return res.status(403).json({ error: 'You can only delete your own booking' });
    }
    if (booking.owner_decision === 'approved') {
      client.release();
      return res.status(409).json({ error: 'Approved bookings cannot be deleted' });
    }

    await client.query('BEGIN');

    if (!booking.bed_released) {
      await client.query('UPDATE rooms SET available_beds = available_beds + 1 WHERE id = $1', [booking.room_id]);
    }
    await client.query('DELETE FROM bookings WHERE id = $1', [id]);

    await client.query('COMMIT');
    client.release();

    res.json({ message: 'Booking deleted successfully' });
  } catch (err) {
    await client.query('ROLLBACK');
    client.release();
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while deleting the booking' });
  }
};

exports.getPendingCount = async (req, res) => {
  try {
    const count = await countPendingBookingsForOwner(req.user.id);
    res.json({ pending_count: count });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching pending bookings count' });
  }
};