const { z } = require('zod');

const registerSchema = z.object({
  full_name: z.string().min(2, 'full_name must be at least 2 characters'),
  phone_number: z.string().min(9, 'phone_number looks too short').max(15),
  email: z.string().email('email must be valid').optional().or(z.literal('')),
  password: z.string().min(6, 'password must be at least 6 characters'),
  role: z.enum(['user', 'student', 'hostel_owner', 'agent', 'house_hunter']).optional(),
});

const loginSchema = z.object({
  identifier: z.string().min(3, 'identifier is required'),
  password: z.string().min(1, 'password is required'),
});

const createAdminSchema = z.object({
  full_name: z.string().min(2),
  phone_number: z.string().min(9).max(15),
  email: z.string().email().optional().or(z.literal('')),
  password: z.string().min(6),
});

module.exports = { registerSchema, loginSchema, createAdminSchema };