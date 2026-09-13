const express = require('express');
const router = express.Router();
const { create, list, updateStatus } = require('../controllers/reportController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createReportSchema, updateReportStatusSchema } = require('../validators/reportValidators');

router.post('/', verifyToken, validate(createReportSchema), create); // any logged-in user can report someone

router.get('/', verifyToken, requireRole('admin'), list);

router.patch('/:id', verifyToken, requireRole('admin'), validate(updateReportStatusSchema), updateStatus);

module.exports = router;