const { z } = require('zod');

const payForBookingSchema = z.object({
  phone_number: z.string().min(9, 'phone_number looks too short').max(15),
  provider: z.enum(['TNM Mpamba', 'Airtel Money'], {
    errorMap: () => ({ message: 'provider must be "TNM Mpamba" or "Airtel Money"' }),
  }),
});

module.exports = { payForBookingSchema };