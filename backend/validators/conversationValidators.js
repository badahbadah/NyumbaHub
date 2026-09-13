const { z } = require('zod');

const startConversationSchema = z.object({
  recipient_id: z.coerce.number().int().positive('recipient_id is required'),
  related_type: z.enum(['hostel', 'property', 'request']).optional(),
  related_id: z.coerce.number().int().positive().optional(),
  message_text: z.string().min(1, 'message_text cannot be empty').max(2000),
});

const sendReplySchema = z.object({
  message_text: z.string().min(1, 'message_text cannot be empty').max(2000),
});

module.exports = { startConversationSchema, sendReplySchema };