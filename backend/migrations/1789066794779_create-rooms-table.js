exports.up = (pgm) => {
  pgm.createTable('rooms', {
    id: 'id',
    hostel_id: { type: 'integer', notNull: true, references: 'hostels', onDelete: 'CASCADE' },
    room_type: { type: 'varchar(50)', notNull: true }, // single | 2-sharing | 4-sharing
    price_amount: { type: 'decimal(12,2)', notNull: true },
    price_period: { type: 'varchar(20)', notNull: true, default: 'month' }, // month | semester
    total_beds: { type: 'integer', notNull: true },
    available_beds: { type: 'integer', notNull: true },
    is_self_contained: { type: 'boolean', notNull: true, default: false },
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('rooms');
};