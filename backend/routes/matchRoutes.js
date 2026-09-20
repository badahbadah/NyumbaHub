const express = require('express');
const router = express.Router();
const { updateStatus, listMine, getPendingCount } = require('../controllers/matchController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { updateMatchStatusSchema } = require('../validators/matchValidators');

router.get('/mine', verifyToken, requireRole('agent'), listMine);
router.get('/pending-count', verifyToken, getPendingCount); // role-aware inside the controller
router.patch('/:id', verifyToken, requireRole('house_hunter'), validate(updateMatchStatusSchema), updateStatus);

module.exports = router;