const express = require('express');
const router = express.Router();
const { create, list, close } = require('../controllers/requestController');
const { create: createMatch, listForRequest } = require('../controllers/matchController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createRequestSchema } = require('../validators/requestValidators');
const { createMatchSchema } = require('../validators/matchValidators');

router.get('/', list); // public — agents browse this feed

router.post('/', verifyToken, requireRole('house_hunter'), validate(createRequestSchema), create);

router.patch('/:id/close', verifyToken, requireRole('house_hunter'), close);

router.post('/:requestId/matches', verifyToken, requireRole('agent'), validate(createMatchSchema), createMatch);

router.get('/:requestId/matches', verifyToken, requireRole('house_hunter'), listForRequest);

module.exports = router;