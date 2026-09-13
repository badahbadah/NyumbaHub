exports.up = (pgm) => {
  pgm.createTable('institutions', {
    id: 'id',
    name: { type: 'varchar(255)', notNull: true },
    short_code: { type: 'varchar(20)', notNull: true, unique: true }, // e.g. 'UNIMA', 'MUST'
    city: { type: 'varchar(100)' },
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('institutions');
};