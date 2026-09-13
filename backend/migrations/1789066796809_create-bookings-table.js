exports.up = (pgm) => {
  pgm.createTable('bookings', {
    id: 'id',
    student_id: { type: 'integer', notNull: true, references: 'users', onDelete: 'CASCADE' },
    room_id: { type: 'integer', notNull: true, references: 'rooms', onDelete: 'CASCADE' },
    hostel_id: { type: 'integer', notNull: true, references: 'hostels', onDelete: 'CASCADE' },
    deposit_amount: { type: 'decimal(12,2)', notNull: true },
    payment_status: { type: 'varchar(20)', notNull: true, default: 'pending' }, // pending | paid | failed
    payment_method: { type: 'varchar(30)' }, // TNM Mpamba | Airtel Money
    booking_code: { type: 'varchar(20)', notNull: true, unique: true },
    status: { type: 'varchar(20)', notNull: true, default: 'pending' }, // pending | confirmed | cancelled
    reserved_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('bookings');
};