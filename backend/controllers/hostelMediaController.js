const path = require('path');
const fs = require('fs');
const { getHostelById } = require('../models/hostelModel');
const { addHostelMedia, getMediaByHostelId, getMediaById, deleteMedia } = require('../models/hostelMediaModel');

exports.upload = async (req, res) => {
  try {
    const { hostelId } = req.params;
    const hostel = await getHostelById(hostelId);
    if (!hostel) return res.status(404).json({ error: 'Hostel not found' });
    if (hostel.owner_id !== req.user.id) return res.status(403).json({ error: 'You can only upload photos to your own hostel' });
    if (!req.files || req.files.length === 0) return res.status(400).json({ error: 'Please select at least one photo' });

    const mediaUrls = req.files.map((file) => `/uploads/hostels/${hostelId}/${file.filename}`);
    const media = await addHostelMedia(hostelId, mediaUrls);
    res.status(201).json({ message: 'Photos uploaded successfully', media });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while uploading photos' });
  }
};

exports.list = async (req, res) => {
  try {
    const { hostelId } = req.params;
    const media = await getMediaByHostelId(hostelId);
    res.json({ media });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching photos' });
  }
};

exports.remove = async (req, res) => {
  try {
    const { hostelId, mediaId } = req.params;
    const hostel = await getHostelById(hostelId);
    if (!hostel) return res.status(404).json({ error: 'Hostel not found' });
    if (hostel.owner_id !== req.user.id) return res.status(403).json({ error: 'You can only delete photos from your own hostel' });

    const media = await getMediaById(mediaId);
    if (!media || media.hostel_id !== Number(hostelId)) return res.status(404).json({ error: 'Photo not found' });

    await deleteMedia(mediaId);
    const filePath = path.join(__dirname, '..', media.media_url);
    fs.unlink(filePath, () => {}); // best-effort cleanup

    res.json({ message: 'Photo deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while deleting the photo' });
  }
};