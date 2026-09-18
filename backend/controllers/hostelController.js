const { createHostel, getAllHostels, getHostelById, updateHostelStatus, getHostelsByOwnerId, updateHostel } = require('../models/hostelModel');

exports.create = async (req, res) => {
  try {
    const {
      name, institution_id, description, latitude, longitude,
      has_water_backup, has_electricity_backup, has_security, has_wifi, has_study_area,
    } = req.body;

    if (!name) return res.status(400).json({ error: 'name is required' });

    const hostel = await createHostel({
      owner_id: req.user.id, name, institution_id, description, latitude, longitude,
      has_water_backup, has_electricity_backup, has_security, has_wifi, has_study_area,
    });

    res.status(201).json({ message: 'Hostel created successfully', hostel });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while creating the hostel' });
  }
};

exports.list = async (req, res) => {
  try {
    const { institution_id, status, search } = req.query;
    const hostels = await getAllHostels({ institution_id, status, search });
    res.json({ hostels });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching hostels' });
  }
};

exports.listMine = async (req, res) => {
  try {
    const hostels = await getHostelsByOwnerId(req.user.id);
    res.json({ hostels });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching your hostels' });
  }
};

exports.markFull = async (req, res) => {
  try {
    const { id } = req.params;
    const hostel = await getHostelById(id);
    if (!hostel) return res.status(404).json({ error: 'Hostel not found' });
    if (hostel.owner_id !== req.user.id) return res.status(403).json({ error: 'You can only update your own hostel' });

    const updated = await updateHostelStatus(id, 'full');
    res.json({ message: 'Hostel marked as full', hostel: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the hostel' });
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const hostel = await getHostelById(id);
    if (!hostel) return res.status(404).json({ error: 'Hostel not found' });
    if (hostel.owner_id !== req.user.id) return res.status(403).json({ error: 'You can only edit your own hostel' });

    const updated = await updateHostel(id, req.body);
    res.json({ message: 'Hostel updated successfully', hostel: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the hostel' });
  }
};

exports.markActive = async (req, res) => {
  try {
    const { id } = req.params;
    const hostel = await getHostelById(id);
    if (!hostel) return res.status(404).json({ error: 'Hostel not found' });
    if (hostel.owner_id !== req.user.id) return res.status(403).json({ error: 'You can only update your own hostel' });

    const updated = await updateHostelStatus(id, 'active');
    res.json({ message: 'Hostel marked as active', hostel: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the hostel' });
  }
};