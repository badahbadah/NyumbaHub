const { z } = require('zod');

const createBookingSchema = z.object({
  room_id: z.coerce.number().int().positive('room_id is required'),
  deposit_amount: z.coerce.number().positive('deposit_amount must be greater than 0'),
});

module.exports = { createBookingSchema };