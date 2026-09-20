const express = require('express');
const router = express.Router({ mergeParams: true });
const uploadProperty = require('../middleware/uploadProperty');
const { upload: uploadPhotos, list, remove } = require('../controllers/propertyMediaController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.get('/', list); // public

router.post('/', verifyToken, requireRole('agent'), uploadProperty.array('photos', 10), uploadPhotos);

router.delete('/:mediaId', verifyToken, requireRole('agent'), remove);

module.exports = router;