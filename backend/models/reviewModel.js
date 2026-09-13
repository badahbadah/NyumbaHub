const pool = require('./db');

async function createReview({ hostel_id, student_id, booking_id, water_rating, electricity_rating, safety_rating, responsiveness_rating, comment }) {
  const result = await pool.query(
    `INSERT INTO hostel_reviews
      (hostel_id, student_id, booking_id, water_rating, electricity_rating, safety_rating, responsiveness_rating, comment)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING *`,
    [hostel_id, student_id, booking_id || null, water_rating, electricity_rating, safety_rating, responsiveness_rating, comment || null]
  );
  return result.rows[0];
}

async function getReviewsByHostelId(hostel_id) {
  const result = await pool.query(
    'SELECT * FROM hostel_reviews WHERE hostel_id = $1 ORDER BY created_at DESC',
    [hostel_id]
  );
  return result.rows;
}

async function getAverageRatings(hostel_id) {
  const result = await pool.query(
    `SELECT
       ROUND(AVG(water_rating), 1) AS avg_water,
       ROUND(AVG(electricity_rating), 1) AS avg_electricity,
       ROUND(AVG(safety_rating), 1) AS avg_safety,
       ROUND(AVG(responsiveness_rating), 1) AS avg_responsiveness,
       COUNT(*) AS review_count
     FROM hostel_reviews WHERE hostel_id = $1`,
    [hostel_id]
  );
  return result.rows[0];
}

module.exports = { createReview, getReviewsByHostelId, getAverageRatings };