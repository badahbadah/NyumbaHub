const express = require('express');
const router = express.Router({ mergeParams: true });
const upload = require('../middleware/upload');
const { upload: uploadPhotos, list, remove } = require('../controllers/hostelMediaController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.get('/', list); // public
router.post('/', verifyToken, requireRole('hostel_owner'), upload.array('photos', 10), uploadPhotos);
router.delete('/:mediaId', verifyToken, requireRole('hostel_owner'), remove);

module.exports = router;