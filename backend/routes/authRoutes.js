const express = require('express');
const router = express.Router();
const { register, login, createAdmin, getMe } = require('../controllers/authController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { registerSchema, loginSchema, createAdminSchema } = require('../validators/authValidators');

router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);

router.get('/me', verifyToken, getMe);

router.post('/create-admin', verifyToken, requireRole('admin'), validate(createAdminSchema), createAdmin);

module.exports = router;