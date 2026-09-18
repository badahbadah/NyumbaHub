const pool = require('./db');

async function addHostelMedia(hostel_id, mediaUrls) {
  const values = [];
  const placeholders = mediaUrls.map((url, i) => {
    values.push(hostel_id, url, 'photo');
    const base = i * 3;
    return `($${base + 1}, $${base + 2}, $${base + 3})`;
  });
  const result = await pool.query(
    `INSERT INTO hostel_media (hostel_id, media_url, media_type) VALUES ${placeholders.join(', ')} RETURNING *`,
    values
  );
  return result.rows;
}

async function getMediaByHostelId(hostel_id) {
  const result = await pool.query('SELECT * FROM hostel_media WHERE hostel_id = $1 ORDER BY uploaded_at ASC', [hostel_id]);
  return result.rows;
}

async function getMediaById(id) {
  const result = await pool.query('SELECT * FROM hostel_media WHERE id = $1', [id]);
  return result.rows[0];
}

async function deleteMedia(id) {
  const result = await pool.query('DELETE FROM hostel_media WHERE id = $1 RETURNING *', [id]);
  return result.rows[0];
}

module.exports = { addHostelMedia, getMediaByHostelId, getMediaById, deleteMedia };