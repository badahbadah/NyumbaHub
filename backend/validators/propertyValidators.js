const { z } = require('zod');

const createPropertySchema = z.object({
  listing_type: z.enum(['rent', 'sale'], { errorMap: () => ({ message: 'listing_type must be "rent" or "sale"' }) }),
  property_type: z.enum(['house', 'apartment', 'shop', 'land']),
  city: z.string().min(2, 'city is required'),
  area: z.string().optional(),
  latitude: z.coerce.number().min(-90).max(90).optional(),
  longitude: z.coerce.number().min(-180).max(180).optional(),
  bedrooms: z.coerce.number().int().nonnegative().optional(),
  bathrooms: z.coerce.number().int().nonnegative().optional(),
  price_amount: z.coerce.number().positive('price_amount must be greater than 0'),
  price_period: z.string().optional(),
  description: z.string().optional(),
  is_fenced: z.boolean().optional(),
  has_water_tank: z.boolean().optional(),
  is_paved: z.boolean().optional(),
});

module.exports = { createPropertySchema };