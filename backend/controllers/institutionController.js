const { getAllInstitutions } = require('../models/institutionModel');

exports.list = async (req, res) => {
  try {
    const institutions = await getAllInstitutions();
    res.json({ institutions });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching institutions' });
  }
};