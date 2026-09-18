const { z } = require('zod');

const createHostelSchema = z.object({
  name: z.string().min(2, 'name is required'),
  institution_id: z.coerce.number().int().positive().optional().nullable(),
  description: z.string().optional(),
  latitude: z.coerce.number().min(-90).max(90).optional(),
  longitude: z.coerce.number().min(-180).max(180).optional(),
  has_water_backup: z.boolean().optional(),
  has_electricity_backup: z.boolean().optional(),
  has_security: z.boolean().optional(),
  has_wifi: z.boolean().optional(),
  has_study_area: z.boolean().optional(),
});

const updateHostelSchema = z.object({
  name: z.string().min(2).optional(),
  institution_id: z.coerce.number().int().positive().optional().nullable(),
  description: z.string().optional(),
  has_water_backup: z.boolean().optional(),
  has_electricity_backup: z.boolean().optional(),
  has_security: z.boolean().optional(),
  has_wifi: z.boolean().optional(),
  has_study_area: z.boolean().optional(),
});

module.exports = { createHostelSchema, updateHostelSchema };