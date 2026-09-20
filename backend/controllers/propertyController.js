const {
  createProperty, getAllProperties, getPropertyById, updatePropertyStatus,
  getPropertiesByAgentId, updateProperty, deleteProperty,
} = require('../models/propertyModel');
const { hasAcceptedMatchForProperty } = require('../models/matchModel');

exports.create = async (req, res) => {
  try {
    const {
      listing_type, property_type, city, area, latitude, longitude,
      bedrooms, bathrooms, price_amount, price_period, description,
      is_fenced, has_water_tank, is_paved,
    } = req.body;

    if (!listing_type || !property_type || !city || !price_amount) {
      return res.status(400).json({ error: 'listing_type, property_type, city and price_amount are required' });
    }
    if (!['rent', 'sale'].includes(listing_type)) {
      return res.status(400).json({ error: 'listing_type must be either "rent" or "sale"' });
    }

    const property = await createProperty({
      agent_id: req.user.id, listing_type, property_type, city, area, latitude, longitude,
      bedrooms, bathrooms, price_amount, price_period, description, is_fenced, has_water_tank, is_paved,
    });

    res.status(201).json({ message: 'Property listed successfully', property });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while creating the property listing' });
  }
};

exports.list = async (req, res) => {
  try {
    const { city, property_type, listing_type, status } = req.query;
    const properties = await getAllProperties({ city, property_type, listing_type, status });
    res.json({ properties });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching properties' });
  }
};

exports.listMine = async (req, res) => {
  try {
    const properties = await getPropertiesByAgentId(req.user.id);
    res.json({ properties });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching your listings' });
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const property = await getPropertyById(id);
    if (!property) return res.status(404).json({ error: 'Property not found' });
    if (property.agent_id !== req.user.id) return res.status(403).json({ error: 'You can only edit your own listing' });

    const updated = await updateProperty(id, req.body);
    res.json({ message: 'Listing updated successfully', property: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the listing' });
  }
};

exports.markTaken = async (req, res) => {
  try {
    const { id } = req.params;
    const property = await getPropertyById(id);
    if (!property) return res.status(404).json({ error: 'Property not found' });
    if (property.agent_id !== req.user.id) return res.status(403).json({ error: 'You can only update your own property listing' });

    const updated = await updatePropertyStatus(id, 'taken');
    res.json({ message: 'Property marked as taken', property: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the property' });
  }
};

exports.remove = async (req, res) => {
  try {
    const { id } = req.params;
    const property = await getPropertyById(id);
    if (!property) return res.status(404).json({ error: 'Property not found' });
    if (property.agent_id !== req.user.id) return res.status(403).json({ error: 'You can only delete your own listing' });

    const hasAccepted = await hasAcceptedMatchForProperty(id);
    if (hasAccepted) {
      return res.status(409).json({ error: 'This listing has an accepted match and cannot be deleted' });
    }

    await deleteProperty(id);
    res.json({ message: 'Listing deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while deleting the listing' });
  }
};