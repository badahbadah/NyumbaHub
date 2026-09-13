exports.up = (pgm) => {
  pgm.createTable('house_wanted_requests', {
    id: 'id',
    hunter_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    property_type: { type: 'varchar(30)', notNull: true },
    target_area: { type: 'varchar(100)' },
    city: { type: 'varchar(100)', notNull: true },
    budget_amount: { type: 'decimal(14,2)', notNull: true },
    budget_period: { type: 'varchar(20)', default: 'month' },
    notes: { type: 'text' },
    status: { type: 'varchar(20)', notNull: true, default: 'open' }, // open | closed
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('house_wanted_requests');
};