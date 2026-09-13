exports.up = (pgm) => {
  pgm.createTable('property_media', {
    id: 'id',
    property_id: { type: 'integer', notNull: true, references: 'properties', onDelete: 'CASCADE' },
    media_url: { type: 'text', notNull: true },
    media_type: { type: 'varchar(10)', notNull: true, default: 'photo' }, // photo | video
    uploaded_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('property_media');
};