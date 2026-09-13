const express = require('express');
const router = express.Router({ mergeParams: true }); // lets this router see :hostelId from the parent route
const { create, list } = require('../controllers/reviewController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { createReviewSchema } = require('../validators/reviewValidators');

router.get('/', list); // public — includes average ratings

router.post('/', verifyToken, requireRole('student'), validate(createReviewSchema), create);

module.exports = router;