const pool = require('./db');

async function findExistingConversation(userA, userB, related_type, related_id) {
  const result = await pool.query(
    `SELECT * FROM conversations
     WHERE ((initiator_id = $1 AND recipient_id = $2) OR (initiator_id = $2 AND recipient_id = $1))
       AND related_type = $3 AND related_id = $4
     LIMIT 1`,
    [userA, userB, related_type, related_id]
  );
  return result.rows[0];
}

async function createConversation({ initiator_id, recipient_id, related_type, related_id }) {
  const result = await pool.query(
    `INSERT INTO conversations (initiator_id, recipient_id, related_type, related_id)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [initiator_id, recipient_id, related_type || null, related_id || null]
  );
  return result.rows[0];
}

async function getConversationById(id) {
  const result = await pool.query('SELECT * FROM conversations WHERE id = $1', [id]);
  return result.rows[0];
}

// Includes a per-conversation has_unread flag, so the UI can show
// exactly which chats have new messages, not just a total count.
async function getConversationsForUser(user_id) {
  const result = await pool.query(
    `SELECT conversations.*,
       EXISTS (
         SELECT 1 FROM messages
         WHERE messages.conversation_id = conversations.id
           AND messages.sender_id != $1
           AND messages.is_read = false
       ) AS has_unread
     FROM conversations
     WHERE initiator_id = $1 OR recipient_id = $1
     ORDER BY created_at DESC`,
    [user_id]
  );
  return result.rows;
}

module.exports = { findExistingConversation, createConversation, getConversationById, getConversationsForUser };