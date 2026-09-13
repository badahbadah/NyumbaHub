exports.up = (pgm) => {
  pgm.createTable('messages', {
    id: 'id',
    conversation_id: { type: 'integer', notNull: true, references: 'conversations', onDelete: 'CASCADE' },
    sender_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    message_text: { type: 'text', notNull: true },
    sent_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
    is_read: { type: 'boolean', notNull: true, default: false },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('messages');
};