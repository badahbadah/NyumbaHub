const { z } = require('zod');

const createMatchSchema = z.object({
  property_id: z.coerce.number().int().positive('property_id is required'),
});

const updateMatchStatusSchema = z.object({
  status: z.enum(['accepted', 'declined'], { errorMap: () => ({ message: 'status must be "accepted" or "declined"' }) }),
});

module.exports = { createMatchSchema, updateMatchStatusSchema };