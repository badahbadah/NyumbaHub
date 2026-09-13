const { createProperty, getAllProperties, getPropertyById, updatePropertyStatus } = require('../models/propertyModel');

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
      agent_id: req.user.id, // from the verified token, not the request body
      listing_type,
      property_type,
      city,
      area,
      latitude,
      longitude,
      bedrooms,
      bathrooms,
      price_amount,
      price_period,
      description,
      is_fenced,
      has_water_tank,
      is_paved,
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

exports.markTaken = async (req, res) => {
  try {
    const { id } = req.params;

    const property = await getPropertyById(id);
    if (!property) {
      return res.status(404).json({ error: 'Property not found' });
    }
    if (property.agent_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only update your own property listing' });
    }

    const updated = await updatePropertyStatus(id, 'taken');
    res.json({ message: 'Property marked as taken', property: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the property' });
  }
};