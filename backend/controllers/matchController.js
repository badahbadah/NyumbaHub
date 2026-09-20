const { getRequestById } = require('../models/requestModel');
const { getPropertyById } = require('../models/propertyModel');
const {
  createMatch, getMatchesByRequestId, getMatchById, updateMatchStatus,
  getMatchesByAgentId, countPendingMatchesForAgent, countPendingOffersForHunter,
} = require('../models/matchModel');

exports.create = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { property_id } = req.body;

    if (!property_id) return res.status(400).json({ error: 'property_id is required' });

    const request = await getRequestById(requestId);
    if (!request) return res.status(404).json({ error: 'Request not found' });

    const property = await getPropertyById(property_id);
    if (!property) return res.status(404).json({ error: 'Property not found' });
    if (property.agent_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only submit your own property listings as a match' });
    }

    const match = await createMatch({ request_id: requestId, property_id, agent_id: req.user.id });
    res.status(201).json({ message: 'Property submitted as a match', match });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while submitting the match' });
  }
};

exports.listForRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const request = await getRequestById(requestId);
    if (!request) return res.status(404).json({ error: 'Request not found' });
    if (request.hunter_id !== req.user.id) return res.status(403).json({ error: 'You can only view offers on your own request' });

    const matches = await getMatchesByRequestId(requestId);
    res.json({ matches });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching matches' });
  }
};

exports.listMine = async (req, res) => {
  try {
    const matches = await getMatchesByAgentId(req.user.id);
    res.json({ matches });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching your matches' });
  }
};

exports.updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['accepted', 'declined'].includes(status)) {
      return res.status(400).json({ error: 'status must be either "accepted" or "declined"' });
    }

    const match = await getMatchById(id);
    if (!match) return res.status(404).json({ error: 'Match not found' });

    const request = await getRequestById(match.request_id);
    if (request.hunter_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only respond to offers on your own request' });
    }

    const updated = await updateMatchStatus(id, status);
    res.json({ message: `Match ${status}`, match: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the match' });
  }
};

// Role-aware: an agent sees how many of their own submitted offers are
// still pending; a house hunter sees how many new offers await their decision.
exports.getPendingCount = async (req, res) => {
  try {
    let count = 0;
    if (req.user.role === 'agent') {
      count = await countPendingMatchesForAgent(req.user.id);
    } else if (req.user.role === 'house_hunter') {
      count = await countPendingOffersForHunter(req.user.id);
    }
    res.json({ pending_count: count });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching pending count' });
  }
};