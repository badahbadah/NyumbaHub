const pool = require('./db');

async function createHostel({
  owner_id, name, institution_id, description, latitude, longitude,
  has_water_backup, has_electricity_backup, has_security, has_wifi, has_study_area,
}) {
  const result = await pool.query(
    `INSERT INTO hostels
      (owner_id, name, institution_id, description, latitude, longitude,
       has_water_backup, has_electricity_backup, has_security, has_wifi, has_study_area)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
     RETURNING *`,
    [owner_id, name, institution_id || null, description || null, latitude || null, longitude || null,
     !!has_water_backup, !!has_electricity_backup, !!has_security, !!has_wifi, !!has_study_area]
  );
  return result.rows[0];
}

async function getAllHostels({ institution_id, status, search } = {}) {
  const conditions = [];
  const values = [];

  if (institution_id) { values.push(institution_id); conditions.push(`institution_id = $${values.length}`); }
  if (status) { values.push(status); conditions.push(`status = $${values.length}`); }
  if (search) { values.push(`%${search}%`); conditions.push(`name ILIKE $${values.length}`); }

  const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query(`SELECT * FROM hostels ${whereClause} ORDER BY created_at DESC`, values);
  return result.rows;
}

async function getHostelById(id) {
  const result = await pool.query('SELECT * FROM hostels WHERE id = $1', [id]);
  return result.rows[0];
}

async function updateHostelStatus(id, status) {
  const result = await pool.query(
    'UPDATE hostels SET status = $1, updated_at = now() WHERE id = $2 RETURNING *',
    [status, id]
  );
  return result.rows[0];
}

async function getHostelsByOwnerId(owner_id) {
  const result = await pool.query('SELECT * FROM hostels WHERE owner_id = $1 ORDER BY created_at DESC', [owner_id]);
  return result.rows;
}

async function updateHostel(id, fields) {
  const { name, description, institution_id, has_water_backup, has_electricity_backup, has_security, has_wifi, has_study_area } = fields;
  const result = await pool.query(
    `UPDATE hostels SET
       name = COALESCE($1, name),
       description = COALESCE($2, description),
       institution_id = COALESCE($3, institution_id),
       has_water_backup = COALESCE($4, has_water_backup),
       has_electricity_backup = COALESCE($5, has_electricity_backup),
       has_security = COALESCE($6, has_security),
       has_wifi = COALESCE($7, has_wifi),
       has_study_area = COALESCE($8, has_study_area),
       updated_at = now()
     WHERE id = $9
     RETURNING *`,
    [name, description, institution_id, has_water_backup, has_electricity_backup, has_security, has_wifi, has_study_area, id]
  );
  return result.rows[0];
}

module.exports = {
  createHostel, getAllHostels, getHostelById, updateHostelStatus, getHostelsByOwnerId, updateHostel,
};