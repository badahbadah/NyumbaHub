exports.up = (pgm) => {
  pgm.createTable('property_matches', {
    id: 'id',
    request_id: { type: 'integer', notNull: true, references: 'house_wanted_requests', onDelete: 'CASCADE' },
    property_id: { type: 'integer', notNull: true, references: 'properties', onDelete: 'CASCADE' },
    agent_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    status: { type: 'varchar(20)', notNull: true, default: 'pending' }, // pending | accepted | declined
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('property_matches');
};