const pool = require('./db');

async function createReport({ reporter_id, reported_user_id, related_type, related_id, reason }) {
  const result = await pool.query(
    `INSERT INTO reports (reporter_id, reported_user_id, related_type, related_id, reason)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [reporter_id, reported_user_id, related_type || null, related_id || null, reason]
  );
  return result.rows[0];
}

async function getAllReports({ status } = {}) {
  const conditions = [];
  const values = [];

  if (status) { values.push(status); conditions.push(`status = $${values.length}`); }

  const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query(
    `SELECT * FROM reports ${whereClause} ORDER BY created_at DESC`,
    values
  );
  return result.rows;
}

async function getReportById(id) {
  const result = await pool.query('SELECT * FROM reports WHERE id = $1', [id]);
  return result.rows[0];
}

async function updateReportStatus(id, status) {
  const result = await pool.query(
    'UPDATE reports SET status = $1 WHERE id = $2 RETURNING *',
    [status, id]
  );
  return result.rows[0];
}

module.exports = { createReport, getAllReports, getReportById, updateReportStatus };