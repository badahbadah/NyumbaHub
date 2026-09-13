exports.up = (pgm) => {
  pgm.createTable('hostel_reviews', {
    id: 'id',
    hostel_id: { type: 'integer', notNull: true, references: 'hostels', onDelete: 'CASCADE' },
    student_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    booking_id: { type: 'integer', references: 'bookings', onDelete: 'SET NULL' },
    water_rating: { type: 'smallint', notNull: true },
    electricity_rating: { type: 'smallint', notNull: true },
    safety_rating: { type: 'smallint', notNull: true },
    responsiveness_rating: { type: 'smallint', notNull: true },
    comment: { type: 'text' },
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('hostel_reviews');
};