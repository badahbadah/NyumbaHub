const { getBookingById, updateBookingPaymentStatus } = require('../models/bookingModel');
const { createTransaction, findTransactionByReference, updateTransactionStatus } = require('../models/transactionModel');
const { requestMobileMoneyPayment } = require('../services/paymentService');

exports.initiate = async (req, res) => {
  try {
    const { id } = req.params;
    const { phone_number, provider } = req.body;

    if (!phone_number || !provider) {
      return res.status(400).json({ error: 'phone_number and provider are required' });
    }
    if (!['airtel_money', 'tnm_mpamba'].includes(provider)) {
      return res.status(400).json({ error: 'provider must be "airtel_money" or "tnm_mpamba"' });
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

    const { provider_reference } = await requestMobileMoneyPayment({
      phone_number,
      amount: booking.deposit_amount,
      provider,
    });

    const transaction = await createTransaction({
      user_id: req.user.id,
      related_type: 'booking',
      related_id: booking.id,
      amount: booking.deposit_amount,
      provider,
      provider_reference,
      status: 'pending',
    });

    res.status(202).json({
      message: 'Payment request sent — check your phone to approve it',
      transaction,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while initiating payment' });
  }
};

// This is the endpoint the aggregator calls once the user approves/rejects on their phone.
// No verifyToken here — the aggregator isn't a logged-in user, it's an external server.
exports.handleWebhook = async (req, res) => {
  try {
    const { provider_reference, status } = req.body; // 'success' or 'failed'

    const transaction = await findTransactionByReference(provider_reference);
    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found for this reference' });
    }

    await updateTransactionStatus(provider_reference, status);

    if (status === 'success' && transaction.related_type === 'booking') {
      await updateBookingPaymentStatus(transaction.related_id, {
        payment_status: 'paid',
        status: 'confirmed',
        payment_method: transaction.provider,
      });
    }

    res.status(200).json({ message: 'Webhook processed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while processing the webhook' });
  }
};