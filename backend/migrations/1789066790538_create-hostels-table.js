exports.up = (pgm) => {
  pgm.createTable('hostels', {
    id: 'id',
    owner_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    name: { type: 'varchar(255)', notNull: true },
    institution_id: { type: 'integer', references: 'institutions', onDelete: 'SET NULL' },
    description: { type: 'text' },
    latitude: { type: 'decimal(10,7)' },
    longitude: { type: 'decimal(10,7)' },
    has_water_backup: { type: 'boolean', notNull: true, default: false },
    has_electricity_backup: { type: 'boolean', notNull: true, default: false },
    has_security: { type: 'boolean', notNull: true, default: false },
    has_wifi: { type: 'boolean', notNull: true, default: false },
    has_study_area: { type: 'boolean', notNull: true, default: false },
    status: { type: 'varchar(20)', notNull: true, default: 'active' }, // active | full
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
    updated_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('hostels');
};