exports.up = (pgm) => {
  pgm.createTable('users', {
    id: 'id',
    full_name: { type: 'varchar(255)', notNull: true },
    phone_number: { type: 'varchar(20)', notNull: true, unique: true },
    email: { type: 'varchar(255)', unique: true },
    password_hash: { type: 'varchar(255)', notNull: true },
    role: {
      type: 'varchar(50)',
      notNull: true,
      default: 'user', // user | student | hostel_owner | agent | house_hunter
    },
    national_id_photo_url: { type: 'text' },
    verification_status: {
      type: 'varchar(20)',
      notNull: true,
      default: 'unverified', // unverified | pending | verified
    },
    institution_id: {
      type: 'integer',
      references: 'institutions',
      onDelete: 'SET NULL',
    },
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
    updated_at: { type: 'timestamp', notNull: true, default: pgm.func('now()') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('users');
};