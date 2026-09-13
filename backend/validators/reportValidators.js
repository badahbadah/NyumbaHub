const { z } = require('zod');

const createReportSchema = z.object({
  reported_user_id: z.coerce.number().int().positive('reported_user_id is required'),
  related_type: z.enum(['property', 'request', 'agent']).optional(),
  related_id: z.coerce.number().int().positive().optional(),
  reason: z.string().min(5, 'reason must be at least 5 characters').max(1000),
});

const updateReportStatusSchema = z.object({
  status: z.enum(['reviewed', 'banned'], { errorMap: () => ({ message: 'status must be "reviewed" or "banned"' }) }),
});

module.exports = { createReportSchema, updateReportStatusSchema };