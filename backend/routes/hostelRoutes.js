const express = require('express');
const router = express.Router();
const { create, list, markFull } = require('../controllers/hostelController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createHostelSchema } = require('../validators/hostelValidators');

router.get('/', list); // public

router.post('/', verifyToken, requireRole('hostel_owner'), validate(createHostelSchema), create);

router.patch('/:id/full', verifyToken, requireRole('hostel_owner'), markFull);

module.exports = router;