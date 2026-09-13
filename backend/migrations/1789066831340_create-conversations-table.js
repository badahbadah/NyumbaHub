exports.up = (pgm) => {
  pgm.createTable('conversations', {
    id: 'id',
    initiator_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    recipient_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    related_type: { type: 'varchar(20)' }, // hostel | property | request
    related_id: { type: 'integer' },
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('conversations');
};