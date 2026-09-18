const express = require('express');
const router = express.Router();
const { create, list, listMine, markFull, markActive, update } = require('../controllers/hostelController');
const { listForHostel } = require('../controllers/bookingController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createHostelSchema, updateHostelSchema } = require('../validators/hostelValidators');

router.get('/', list); // public, supports ?institution_id=&status=&search=
router.get('/mine', verifyToken, requireRole('hostel_owner'), listMine);
router.post('/', verifyToken, requireRole('hostel_owner'), validate(createHostelSchema), create);
router.patch('/:id', verifyToken, requireRole('hostel_owner'), validate(updateHostelSchema), update);
router.patch('/:id/full', verifyToken, requireRole('hostel_owner'), markFull);
router.patch('/:id/active', verifyToken, requireRole('hostel_owner'), markActive);
router.get('/:id/bookings', verifyToken, requireRole('hostel_owner'), listForHostel);

module.exports = router;