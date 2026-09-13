const { z } = require('zod');

const createRequestSchema = z.object({
  property_type: z.enum(['house', 'apartment', 'shop', 'land']),
  target_area: z.string().optional(),
  city: z.string().min(2, 'city is required'),
  budget_amount: z.coerce.number().positive('budget_amount must be greater than 0'),
  budget_period: z.string().optional(),
  notes: z.string().max(1000).optional(),
});

module.exports = { createRequestSchema };