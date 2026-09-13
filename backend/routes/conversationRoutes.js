const express = require('express');
const router = express.Router();
const {
  startOrSend,
  listMyConversations,
  getMessages,
  sendReply,
} = require('../controllers/conversationController');
const { verifyToken } = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { startConversationSchema, sendReplySchema } = require('../validators/conversationValidators');

router.post('/', verifyToken, validate(startConversationSchema), startOrSend);

router.get('/', verifyToken, listMyConversations);

router.get('/:id/messages', verifyToken, getMessages);

router.post('/:id/messages', verifyToken, validate(sendReplySchema), sendReply);

module.exports = router;