const { getHostelById } = require('../models/hostelModel');
const { createRoom, getRoomsByHostelId } = require('../models/roomModel');

exports.list = async (req, res) => {
  try {
    const { hostelId } = req.params;
    const rooms = await getRoomsByHostelId(hostelId);
    res.json({ rooms });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching rooms' });
  }
};

exports.create = async (req, res) => {
  try {
    const { hostelId } = req.params;
    const { room_type, price_amount, price_period, total_beds, is_self_contained } = req.body;

    if (!room_type || !price_amount || !total_beds) {
      return res.status(400).json({ error: 'room_type, price_amount and total_beds are required' });
    }

    const hostel = await getHostelById(hostelId);
    if (!hostel) {
      return res.status(404).json({ error: 'Hostel not found' });
    }
    if (hostel.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only add rooms to your own hostel' });
    }

    const room = await createRoom({ hostel_id: hostelId, room_type, price_amount, price_period, total_beds, is_self_contained });
    res.status(201).json({ message: 'Room created successfully', room });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while creating the room' });
  }
};