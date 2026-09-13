const { z } = require('zod');

const createRoomSchema = z.object({
  room_type: z.enum(['single', '2-sharing', '4-sharing'], {
    errorMap: () => ({ message: 'room_type must be single, 2-sharing, or 4-sharing' }),
  }),
  price_amount: z.coerce.number().positive('price_amount must be greater than 0'),
  price_period: z.enum(['month', 'semester']).optional(),
  total_beds: z.coerce.number().int().positive('total_beds must be a positive whole number'),
  is_self_contained: z.boolean().optional(),
});

module.exports = { createRoomSchema };