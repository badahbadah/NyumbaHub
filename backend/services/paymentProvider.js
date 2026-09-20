// This file stands in for a real aggregator (e.g. PayChangu) API call.
// When you have real API keys, only this file needs to change —
// everything else in the app talks to it the same way either way.

function initiatePayment({ amount, phone_number, provider }) {
  // A real implementation would call fetch('https://api.paychangu.com/...') here.
  const provider_reference = 'SIM-' + Date.now() + '-' + Math.floor(Math.random() * 10000);

  console.log(`[SIMULATED] Requesting ${provider} payment of MWK ${amount} from ${phone_number}`);
  console.log(`[SIMULATED] Reference: ${provider_reference}`);
  console.log(`[SIMULATED] In real life, the student now gets a USSD prompt on their phone.`);

  return { provider_reference, status: 'pending' };
}

module.exports = { initiatePayment };