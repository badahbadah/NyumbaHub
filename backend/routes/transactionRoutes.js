const express = require('express');
const router = express.Router();
const { payForBooking } = require('../controllers/transactionController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { payForBookingSchema } = require('../validators/transactionValidators');

router.post('/bookings/:id/pay', verifyToken, requireRole('student'), validate(payForBookingSchema), payForBooking);

module.exports = router;