const express = require('express');
const router = express.Router({ mergeParams: true }); // lets this router see :hostelId from the parent route
const { create, list } = require('../controllers/roomController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createRoomSchema } = require('../validators/roomValidators');

router.get('/', list); // public

router.post('/', verifyToken, requireRole('hostel_owner'), validate(createRoomSchema), create);

module.exports = router;