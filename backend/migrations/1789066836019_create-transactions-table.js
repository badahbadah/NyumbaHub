exports.up = (pgm) => {
  pgm.createTable('transactions', {
    id: 'id',
    user_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    related_type: { type: 'varchar(20)', default: 'booking' },
    related_id: { type: 'integer' },
    amount: { type: 'decimal(12,2)', notNull: true },
    currency: { type: 'varchar(5)', notNull: true, default: 'MWK' },
    provider: { type: 'varchar(30)' }, // TNM Mpamba | Airtel Money
    provider_reference: { type: 'varchar(100)' },
    status: { type: 'varchar(20)', notNull: true, default: 'pending' }, // pending | success | failed
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('transactions');
};