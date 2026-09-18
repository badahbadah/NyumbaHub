const express = require('express');
const router = express.Router();
const { list } = require('../controllers/institutionController');

router.get('/', list); // public

module.exports = router;