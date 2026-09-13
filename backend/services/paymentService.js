const crypto = require('crypto');

// MOCK IMPLEMENTATION — replace the inside of this function once you have real aggregator credentials.
// Everything that CALLS this function stays exactly the same.
async function requestMobileMoneyPayment({ phone_number, amount, provider }) {
  const provider_reference = 'MOCK-' + crypto.randomBytes(6).toString('hex').toUpperCase();

  console.log(`[MOCK PAYMENT] Would call ${provider} for MWK ${amount} from ${phone_number}`);
  console.log(`[MOCK PAYMENT] Generated reference: ${provider_reference}`);
  console.log(`[MOCK PAYMENT] In real life, the aggregator now sends a webhook later with the result.`);

  /*
  REAL VERSION (once you have PayChangu keys), roughly:

  const axios = require('axios');
  const response = await axios.post('https://api.paychangu.com/payments/initiate', {
    amount,
    phone_number,
    provider, // 'airtel_money' or 'tnm_mpamba'
    callback_url: process.env.WEBHOOK_URL,
  }, {
    headers: { Authorization: `Bearer ${process.env.PAYCHANGU_SECRET_KEY}` },
  });
  return { provider_reference: response.data.reference };
  */

  return { provider_reference };
}

module.exports = { requestMobileMoneyPayment };