const pool = require('./db');

async function createMessage({ conversation_id, sender_id, message_text }) {
  const result = await pool.query(
    `INSERT INTO messages (conversation_id, sender_id, message_text)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [conversation_id, sender_id, message_text]
  );
  return result.rows[0];
}

async function getMessagesByConversationId(conversation_id) {
  const result = await pool.query(
    'SELECT * FROM messages WHERE conversation_id = $1 ORDER BY sent_at ASC',
    [conversation_id]
  );
  return result.rows;
}

async function markMessagesAsRead(conversation_id, reader_id) {
  await pool.query(
    `UPDATE messages SET is_read = true
     WHERE conversation_id = $1 AND sender_id != $2 AND is_read = false`,
    [conversation_id, reader_id]
  );
}

module.exports = { createMessage, getMessagesByConversationId, markMessagesAsRead };