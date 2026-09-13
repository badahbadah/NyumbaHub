require('dotenv').config();
const express = require('express');
const pool = require('./models/db');
const authRoutes = require('./routes/authRoutes');
const hostelRoutes = require('./routes/hostelRoutes');
const roomRoutes = require('./routes/roomRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const propertyRoutes = require('./routes/propertyRoutes');
const requestRoutes = require('./routes/requestRoutes');
const matchRoutes = require('./routes/matchRoutes');
const app = express();
const conversationRoutes = require('./routes/conversationRoutes');
const webhookRoutes = require('./routes/webhookRoutes');
const reportRoutes = require('./routes/reportRoutes');

app.use(express.json()); // lets Express read JSON request bodies

app.get('/', async (req, res) => {
  const result = await pool.query('SELECT NOW()');
  res.send(`Server is running. DB time: ${result.rows[0].now}`);
});

app.use('/api/auth', authRoutes);
app.use('/api/hostels', hostelRoutes);
app.use('/api/hostels/:hostelId/rooms', roomRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/hostels/:hostelId/reviews', reviewRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/matches', matchRoutes);
app.use('/api/conversations', conversationRoutes);
app.use('/api/webhooks', webhookRoutes);
app.use('/api/reports', reportRoutes);

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});