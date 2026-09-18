const express = require('express');
const router = express.Router({ mergeParams: true });
const { create, list, updateBeds } = require('../controllers/roomController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createRoomSchema } = require('../validators/roomValidators');

router.get('/', list); // public
router.post('/', verifyToken, requireRole('hostel_owner'), validate(createRoomSchema), create);
router.patch('/:roomId/beds', verifyToken, requireRole('hostel_owner'), updateBeds);

module.exports = router;