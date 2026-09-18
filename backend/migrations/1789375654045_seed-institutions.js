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
    pgm.sql(`
    INSERT INTO institutions (name, short_code, city) VALUES
      ('University of Malawi - Chikanda Campus', 'UNIMA', 'Zomba'),
      ('Malawi University of Science and Technology', 'MUST', 'Thyolo'),
      ('Malawi University of Business and Applied Sciences - Chichiri', 'MUBAS', 'Blantyre'),
      ('Lilongwe University of Agriculture and Natural Resources', 'LUANAR', 'Lilongwe'),
      ('Mzuzu University', 'MZUNI', 'Mzuzu')
    ON CONFLICT (short_code) DO NOTHING;
  `);
};

/**
 * @param pgm {import('node-pg-migrate').MigrationBuilder}
 * @param run {() => void | undefined}
 * @returns {Promise<void> | void}
 */
export const down = (pgm) => {
    pgm.sql(`DELETE FROM institutions WHERE short_code IN ('UNIMA','MUST','MUBAS','LUANAR','MZUNI');`);
};
