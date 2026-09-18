const { getUserBasicById } = require('../models/userModel');

exports.getBasic = async (req, res) => {
  try {
    const user = await getUserBasicById(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching the user' });
  }
};