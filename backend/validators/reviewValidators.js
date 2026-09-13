const { z } = require('zod');

const ratingField = z.coerce.number().int().min(1, 'ratings must be between 1 and 5').max(5, 'ratings must be between 1 and 5');

const createReviewSchema = z.object({
  water_rating: ratingField,
  electricity_rating: ratingField,
  safety_rating: ratingField,
  responsiveness_rating: ratingField,
  comment: z.string().max(1000).optional(),
});

module.exports = { createReviewSchema };