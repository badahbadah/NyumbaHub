const { createHostel, getAllHostels, getHostelById, updateHostelStatus } = require('../models/hostelModel');

exports.create = async (req, res) => {
  try {
    const { name, institution_id, description, latitude, longitude,
            has_water_backup, has_electricity_backup, has_security, has_wifi, has_study_area } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'name is required' });
    }

    const hostel = await createHostel({
      owner_id: req.user.id, // comes from the verified token, not the request body
      name,
      institution_id,
      description,
      latitude,
      longitude,
      has_water_backup,
      has_electricity_backup,
      has_security,
      has_wifi,
      has_study_area,
    });

    res.status(201).json({ message: 'Hostel created successfully', hostel });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while creating the hostel' });
  }
};

exports.list = async (req, res) => {
  try {
    const { institution_id, status } = req.query;
    const hostels = await getAllHostels({ institution_id, status });
    res.json({ hostels });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching hostels' });
  }
};

exports.markFull = async (req, res) => {
  try {
    const { id } = req.params;

    const hostel = await getHostelById(id);
    if (!hostel) {
      return res.status(404).json({ error: 'Hostel not found' });
    }

    if (hostel.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'You can only update your own hostel' });
    }

    const updated = await updateHostelStatus(id, 'full');
    res.json({ message: 'Hostel marked as full', hostel: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the hostel' });
  }
};