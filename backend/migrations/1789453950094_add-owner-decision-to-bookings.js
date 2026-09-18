/**
 * @type {import('node-pg-migrate').ColumnDefinitions | undefined}
 */
export const shorthands = undefined;

/**
 * @param pgm {import('node-pg-migrate').MigrationBuilder}
 * @param run {() => void | undefined}
 * @returns {Promise<void> | void}
 */
export const up = (pgm) => {
    pgm.addColumn('bookings', {
    owner_decision: { type: 'varchar(10)', notNull: true, default: 'pending' }, // pending | approved | denied
  });
  pgm.sql(`UPDATE bookings SET owner_decision = 'approved' WHERE approved = true`);
  pgm.dropColumn('bookings', 'approved');
};

/**
 * @param pgm {import('node-pg-migrate').MigrationBuilder}
 * @param run {() => void | undefined}
 * @returns {Promise<void> | void}
 */
export const down = (pgm) => {
    pgm.addColumn('bookings', { approved: { type: 'boolean', notNull: true, default: false } });
  pgm.sql(`UPDATE bookings SET approved = true WHERE owner_decision = 'approved'`);
  pgm.dropColumn('bookings', 'owner_decision');
};
