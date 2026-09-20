const { getBookingById, updateBookingPaymentStatus } = require('../models/bookingModel');
const { createTransaction, getTransactionByReference, updateTransactionStatus } = require('../models/transactionModel');
const { initiatePayment } = require('../services/paymentProvider');

exports.payForBooking = async (req, res) => {
  try {
    const { id } = req.params; // booking id
    const { phone_number, provider } = req.body;

    if (!phone_number || !provider) {
      return res.status(400).json({ error: 'phone_number and provider are required' });
    }
    if (!['TNM Mpamba', 'Airtel Money'].includes(provider)) {
      return res.status(400).json({ error: 'provider must be "TNM Mpamba" or "Airtel Money"' });
    }

    const booking = await getBookingById(id);
    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }
    if (booking.student_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only pay for your own booking' });
    }
    if (booking.payment_status === 'paid') {
      return res.status(409).json({ error: 'This booking has already been paid' });
    }

    const { provider_reference } = initiatePayment({
      amount: booking.deposit_amount,
      phone_number,
      provider,
    });

    const transaction = await createTransaction({
      user_id: req.user.id,
      related_type: 'booking',
      related_id: booking.id,
      amount: booking.deposit_amount,
      provider,
      provider_reference,
    });

    res.status(202).json({
      message: 'Payment request sent. Approve it on your phone to complete the booking.',
      transaction,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while initiating payment' });
  }
};

exports.paymentWebhook = async (req, res) => {
  try {
    const { provider_reference, status } = req.body;

    if (!provider_reference || !['success', 'failed'].includes(status)) {
      return res.status(400).json({ error: 'provider_reference and a valid status are required' });
    }

    const transaction = await getTransactionByReference(provider_reference);
    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    const updatedTransaction = await updateTransactionStatus(provider_reference, status);

    if (status === 'success' && transaction.related_type === 'booking') {
      await updateBookingPaymentStatus(transaction.related_id, 'paid', 'confirmed');
    } else if (status === 'failed' && transaction.related_type === 'booking') {
      await updateBookingPaymentStatus(transaction.related_id, 'failed', 'cancelled');
    }

    res.json({ message: 'Webhook processed', transaction: updatedTransaction });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while processing the webhook' });
  }
};