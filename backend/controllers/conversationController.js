const {
  findExistingConversation,
  createConversation,
  getConversationById,
  getConversationsForUser,
} = require('../models/conversationModel');
const { createMessage, getMessagesByConversationId, markMessagesAsRead } = require('../models/messageModel');

// Start a conversation (or reuse an existing one) and send the first message
exports.startOrSend = async (req, res) => {
  try {
    const { recipient_id, related_type, related_id, message_text } = req.body;

    if (!recipient_id || !message_text) {
      return res.status(400).json({ error: 'recipient_id and message_text are required' });
    }
    if (recipient_id === req.user.id) {
      return res.status(400).json({ error: 'You cannot message yourself' });
    }

    let conversation = await findExistingConversation(req.user.id, recipient_id, related_type, related_id);
    if (!conversation) {
      conversation = await createConversation({
        initiator_id: req.user.id,
        recipient_id,
        related_type,
        related_id,
      });
    }

    const message = await createMessage({
      conversation_id: conversation.id,
      sender_id: req.user.id,
      message_text,
    });

    res.status(201).json({ message: 'Message sent', conversation, sentMessage: message });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while sending the message' });
  }
};

exports.listMyConversations = async (req, res) => {
  try {
    const conversations = await getConversationsForUser(req.user.id);
    res.json({ conversations });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching conversations' });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { id } = req.params;

    const conversation = await getConversationById(id);
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }
    if (conversation.initiator_id !== req.user.id && conversation.recipient_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not part of this conversation' });
    }

    const messages = await getMessagesByConversationId(id);
    await markMessagesAsRead(id, req.user.id);

    res.json({ conversation, messages });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching messages' });
  }
};

exports.sendReply = async (req, res) => {
  try {
    const { id } = req.params;
    const { message_text } = req.body;

    if (!message_text) {
      return res.status(400).json({ error: 'message_text is required' });
    }

    const conversation = await getConversationById(id);
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }
    if (conversation.initiator_id !== req.user.id && conversation.recipient_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not part of this conversation' });
    }

    const message = await createMessage({ conversation_id: id, sender_id: req.user.id, message_text });
    res.status(201).json({ message: 'Reply sent', sentMessage: message });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while sending the reply' });
  }
};