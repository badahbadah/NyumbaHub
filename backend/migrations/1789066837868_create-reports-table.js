exports.up = (pgm) => {
  pgm.createTable('reports', {
    id: 'id',
    reporter_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    reported_user_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    related_type: { type: 'varchar(20)' }, // property | request | agent
    related_id: { type: 'integer' },
    reason: { type: 'text', notNull: true },
    status: { type: 'varchar(20)', notNull: true, default: 'pending' }, // pending | reviewed | banned
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('reports');
};