exports.up = (pgm) => {
  pgm.createTable('properties', {
    id: 'id',
    agent_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    listing_type: { type: 'varchar(10)', notNull: true }, // rent | sale
    property_type: { type: 'varchar(30)', notNull: true }, // house | apartment | shop | land
    city: { type: 'varchar(100)', notNull: true },
    area: { type: 'varchar(100)' },
    latitude: { type: 'decimal(10,7)' },
    longitude: { type: 'decimal(10,7)' },
    bedrooms: { type: 'integer' },
    bathrooms: { type: 'integer' },
    price_amount: { type: 'decimal(14,2)', notNull: true },
    price_period: { type: 'varchar(20)' }, // month (rent) | null (sale)
    description: { type: 'text' },
    is_fenced: { type: 'boolean', notNull: true, default: false },
    has_water_tank: { type: 'boolean', notNull: true, default: false },
    is_paved: { type: 'boolean', notNull: true, default: false },
    status: { type: 'varchar(20)', notNull: true, default: 'available' }, // available | taken
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
    updated_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('properties');
};