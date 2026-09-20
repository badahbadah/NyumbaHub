const path = require('path');
const fs = require('fs');
const { getPropertyById } = require('../models/propertyModel');
const { addPropertyMedia, getMediaByPropertyId, getMediaById, deleteMedia } = require('../models/propertyMediaModel');

exports.upload = async (req, res) => {
  try {
    const { propertyId } = req.params;
    const property = await getPropertyById(propertyId);
    if (!property) return res.status(404).json({ error: 'Property not found' });
    if (property.agent_id !== req.user.id) return res.status(403).json({ error: 'You can only upload photos to your own listing' });
    if (!req.files || req.files.length === 0) return res.status(400).json({ error: 'Please select at least one photo' });

    const mediaUrls = req.files.map((file) => `/uploads/properties/${propertyId}/${file.filename}`);
    const media = await addPropertyMedia(propertyId, mediaUrls);
    res.status(201).json({ message: 'Photos uploaded successfully', media });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while uploading photos' });
  }
};

exports.list = async (req, res) => {
  try {
    const { propertyId } = req.params;
    const media = await getMediaByPropertyId(propertyId);
    res.json({ media });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching photos' });
  }
};

exports.remove = async (req, res) => {
  try {
    const { propertyId, mediaId } = req.params;
    const property = await getPropertyById(propertyId);
    if (!property) return res.status(404).json({ error: 'Property not found' });
    if (property.agent_id !== req.user.id) return res.status(403).json({ error: 'You can only delete photos from your own listing' });

    const media = await getMediaById(mediaId);
    if (!media || media.property_id !== Number(propertyId)) return res.status(404).json({ error: 'Photo not found' });

    await deleteMedia(mediaId);
    const filePath = path.join(__dirname, '..', media.media_url);
    fs.unlink(filePath, () => {});

    res.json({ message: 'Photo deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while deleting the photo' });
  }
};