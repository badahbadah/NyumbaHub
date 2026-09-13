const pool = require('../models/db');
const { getBookingsByStudentId } = require('../models/bookingModel');

exports.create = async (req, res) => {
  const client = await pool.connect(); // borrow one dedicated connection for this whole transaction

  try {
    const { room_id, deposit_amount } = req.body;

    if (!room_id || !deposit_amount) {
      client.release();
      return res.status(400).json({ error: 'room_id and deposit_amount are required' });
    }

    await client.query('BEGIN');

    // Take one bed, but ONLY if one is still available — this line is what prevents overbooking
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