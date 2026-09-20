require('dotenv').config();
const express = require('express');
const path = require('path');
const pool = require('./models/db');

const authRoutes = require('./routes/authRoutes');
const hostelRoutes = require('./routes/hostelRoutes');
const roomRoutes = require('./routes/roomRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const propertyRoutes = require('./routes/propertyRoutes');
const propertyMediaRoutes = require('./routes/propertyMediaRoutes');
const requestRoutes = require('./routes/requestRoutes');
const matchRoutes = require('./routes/matchRoutes');
const conversationRoutes = require('./routes/conversationRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const webhookRoutes = require('./routes/webhookRoutes');
const reportRoutes = require('./routes/reportRoutes');
const institutionRoutes = require('./routes/institutionRoutes');
const userRoutes = require('./routes/userRoutes');
const hostelMediaRoutes = require('./routes/hostelMediaRoutes');

const app = express();
app.use(express.json());

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.get('/', async (req, res) => {
  const result = await pool.query('SELECT NOW()');
  res.send(`Server is running. DB time: ${result.rows[0].now}`);
});

app.use('/api/auth', authRoutes);
app.use('/api/institutions', institutionRoutes);
app.use('/api/users', userRoutes);
app.use('/api/hostels/:hostelId/media', hostelMediaRoutes);
app.use('/api/hostels/:hostelId/rooms', roomRoutes);
app.use('/api/hostels/:hostelId/reviews', reviewRoutes);
app.use('/api/hostels', hostelRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/properties/:propertyId/media', propertyMediaRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/matches', matchRoutes);
app.use('/api/conversations', conversationRoutes);
app.use('/api', transactionRoutes);
app.use('/api/webhooks', webhookRoutes);
app.use('/api/reports', reportRoutes);

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});