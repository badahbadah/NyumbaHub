const pool = require('./db');

async function addPropertyMedia(property_id, mediaUrls) {
  const values = [];
  const placeholders = mediaUrls.map((url, i) => {
    values.push(property_id, url, 'photo');
    const base = i * 3;
    return `($${base + 1}, $${base + 2}, $${base + 3})`;
  });
  const result = await pool.query(
    `INSERT INTO property_media (property_id, media_url, media_type) VALUES ${placeholders.join(', ')} RETURNING *`,
    values
  );
  return result.rows;
}

async function getMediaByPropertyId(property_id) {
  const result = await pool.query('SELECT * FROM property_media WHERE property_id = $1 ORDER BY uploaded_at ASC', [property_id]);
  return result.rows;
}

async function getMediaById(id) {
  const result = await pool.query('SELECT * FROM property_media WHERE id = $1', [id]);
  return result.rows[0];
}

async function deleteMedia(id) {
  const result = await pool.query('DELETE FROM property_media WHERE id = $1 RETURNING *', [id]);
  return result.rows[0];
}

module.exports = { addPropertyMedia, getMediaByPropertyId, getMediaById, deleteMedia };