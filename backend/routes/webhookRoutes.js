const express = require('express');
const router = express.Router();
const { handleWebhook } = require('../controllers/paymentController');

router.post('/payments', handleWebhook); // intentionally no verifyToken — see note belo

module.exports = router;