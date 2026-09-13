const express = require('express');
const router = express.Router();
const { create } = require('../controllers/bookingController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createBookingSchema } = require('../validators/bookingValidators');

router.post('/', verifyToken, requireRole('student'), validate(createBookingSchema), create);

module.exports = router;