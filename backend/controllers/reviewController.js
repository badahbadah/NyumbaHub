const { getHostelById } = require('../models/hostelModel');
const { findBookingByStudentAndHostel } = require('../models/bookingModel');
const { createReview, getReviewsByHostelId, getAverageRatings } = require('../models/reviewModel');

exports.create = async (req, res) => {
  try {
    const { hostelId } = req.params;
    const { water_rating, electricity_rating, safety_rating, responsiveness_rating, comment } = req.body;

    if (!water_rating || !electricity_rating || !safety_rating || !responsiveness_rating) {
      return res.status(400).json({ error: 'water_rating, electricity_rating, safety_rating and responsiveness_rating are required' });
    }

    const ratings = [water_rating, electricity_rating, safety_rating, responsiveness_rating];
    if (ratings.some((r) => r < 1 || r > 5)) {
      return res.status(400).json({ error: 'Ratings must be between 1 and 5' });
    }

    const hostel = await getHostelById(hostelId);
    if (!hostel) {
      return res.status(404).json({ error: 'Hostel not found' });
    }

    const booking = await findBookingByStudentAndHostel(req.user.id, hostelId);
    if (!booking) {
      return res.status(403).json({ error: 'You can only review a hostel you have booked' });
    }

    const review = await createReview({
      hostel_id: hostelId,
      student_id: req.user.id,
      booking_id: booking.id,
      water_rating,
      electricity_rating,
      safety_rating,
      responsiveness_rating,
      comment,
    });

    res.status(201).json({ message: 'Review submitted successfully', review });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while submitting the review' });
  }
};

exports.list = async (req, res) => {
  try {
    const { hostelId } = req.params;
    const reviews = await getReviewsByHostelId(hostelId);
    const averages = await getAverageRatings(hostelId);
    res.json({ averages, reviews });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching reviews' });
  }
};