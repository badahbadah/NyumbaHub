const express = require('express');
const router = express.Router();
const { create, listMine, approve, reject, remove, getPendingCount } = require('../controllers/bookingController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createBookingSchema } = require('../validators/bookingValidators');

router.post('/', verifyToken, requireRole('student'), validate(createBookingSchema), create);
router.get('/mine', verifyToken, requireRole('student'), listMine);
router.get('/pending-count', verifyToken, requireRole('hostel_owner'), getPendingCount);
router.patch('/:id/approve', verifyToken, requireRole('hostel_owner'), approve);
router.patch('/:id/reject', verifyToken, requireRole('hostel_owner'), reject);
router.delete('/:id', verifyToken, requireRole('student'), remove);

module.exports = router;