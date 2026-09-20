const express = require('express');
const router = express.Router();
const { create, list, listMine, markTaken, update, remove } = require('../controllers/propertyController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createPropertySchema, updatePropertySchema } = require('../validators/propertyValidators');

router.get('/', list); // public
router.get('/mine', verifyToken, requireRole('agent'), listMine);
router.post('/', verifyToken, requireRole('agent'), validate(createPropertySchema), create);
router.patch('/:id', verifyToken, requireRole('agent'), validate(updatePropertySchema), update);
router.patch('/:id/taken', verifyToken, requireRole('agent'), markTaken);
router.delete('/:id', verifyToken, requireRole('agent'), remove);

module.exports = router;