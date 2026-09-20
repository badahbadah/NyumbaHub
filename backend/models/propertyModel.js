const pool = require('./db');

async function createProperty({
  agent_id, listing_type, property_type, city, area, latitude, longitude,
  bedrooms, bathrooms, price_amount, price_period, description,
  is_fenced, has_water_tank, is_paved,
}) {
  const result = await pool.query(
    `INSERT INTO properties
      (agent_id, listing_type, property_type, city, area, latitude, longitude,
       bedrooms, bathrooms, price_amount, price_period, description,
       is_fenced, has_water_tank, is_paved)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
     RETURNING *`,
    [
      agent_id, listing_type, property_type, city, area || null,
      latitude || null, longitude || null, bedrooms || null, bathrooms || null,
      price_amount, price_period || null, description || null,
      !!is_fenced, !!has_water_tank, !!is_paved,
    ]
  );
  return result.rows[0];
}

async function getAllProperties({ city, property_type, listing_type, status } = {}) {
  const conditions = [];
  const values = [];

  if (city) { values.push(city); conditions.push(`city = $${values.length}`); }
  if (property_type) { values.push(property_type); conditions.push(`property_type = $${values.length}`); }
  if (listing_type) { values.push(listing_type); conditions.push(`listing_type = $${values.length}`); }
  if (status) { values.push(status); conditions.push(`status = $${values.length}`); }

  const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query(`SELECT * FROM properties ${whereClause} ORDER BY created_at DESC`, values);
  return result.rows;
}

async function getPropertyById(id) {
  const result = await pool.query('SELECT * FROM properties WHERE id = $1', [id]);
  return result.rows[0];
}

async function updatePropertyStatus(id, status) {
  const result = await pool.query(
    'UPDATE properties SET status = $1, updated_at = now() WHERE id = $2 RETURNING *',
    [status, id]
  );
  return result.rows[0];
}

async function getPropertiesByAgentId(agent_id) {
  const result = await pool.query('SELECT * FROM properties WHERE agent_id = $1 ORDER BY created_at DESC', [agent_id]);
  return result.rows;
}

async function updateProperty(id, fields) {
  const {
    listing_type, property_type, city, area, bedrooms, bathrooms,
    price_amount, price_period, description, is_fenced, has_water_tank, is_paved,
  } = fields;
  const result = await pool.query(
    `UPDATE properties SET
       listing_type = COALESCE($1, listing_type),
       property_type = COALESCE($2, property_type),
       city = COALESCE($3, city),
       area = COALESCE($4, area),
       bedrooms = COALESCE($5, bedrooms),
       bathrooms = COALESCE($6, bathrooms),
       price_amount = COALESCE($7, price_amount),
       price_period = COALESCE($8, price_period),
       description = COALESCE($9, description),
       is_fenced = COALESCE($10, is_fenced),
       has_water_tank = COALESCE($11, has_water_tank),
       is_paved = COALESCE($12, is_paved),
       updated_at = now()
     WHERE id = $13
     RETURNING *`,
    [listing_type, property_type, city, area, bedrooms, bathrooms, price_amount, price_period, description, is_fenced, has_water_tank, is_paved, id]
  );
  return result.rows[0];
}

async function deleteProperty(id) {
  const result = await pool.query('DELETE FROM properties WHERE id = $1 RETURNING *', [id]);
  return result.rows[0];
}

module.exports = {
  createProperty, getAllProperties, getPropertyById, updatePropertyStatus,
  getPropertiesByAgentId, updateProperty, deleteProperty,
};