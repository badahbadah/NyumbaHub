const express = require('express');
const router = express.Router();
const { getBasic } = require('../controllers/userController');
const { verifyToken } = require('../middleware/authMiddleware');

router.get('/:id/basic', verifyToken, getBasic);

module.exports = router;