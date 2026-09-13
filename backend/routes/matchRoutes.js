const express = require('express');
const router = express.Router();
const { updateStatus } = require('../controllers/matchController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { updateMatchStatusSchema } = require('../validators/matchValidators');

router.patch('/:id', verifyToken, requireRole('house_hunter'), validate(updateMatchStatusSchema), updateStatus);

module.exports = router;