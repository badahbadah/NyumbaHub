const { createRequest, getAllRequests, getRequestById, updateRequestStatus } = require('../models/requestModel');

exports.create = async (req, res) => {
  try {
    const { property_type, target_area, city, budget_amount, budget_period, notes } = req.body;

    if (!property_type || !city || !budget_amount) {
      return res.status(400).json({ error: 'property_type, city and budget_amount are required' });
    }

    const request = await createRequest({
      hunter_id: req.user.id,
      property_type,
      target_area,
      city,
      budget_amount,
      budget_period,
      notes,
    });

    res.status(201).json({ message: 'Request broadcast successfully', request });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while creating the request' });
  }
};

exports.list = async (req, res) => {
  try {
    const { city, property_type, status } = req.query;
    const requests = await getAllRequests({ city, property_type, status });
    res.json({ requests });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching requests' });
  }
};

exports.close = async (req, res) => {
  try {
    const { id } = req.params;

    const request = await getRequestById(id);
    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }
    if (request.hunter_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only close your own request' });
    }

    const updated = await updateRequestStatus(id, 'closed');
    res.json({ message: 'Request closed', request: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while closing the request' });
  }
};