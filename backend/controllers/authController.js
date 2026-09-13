const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { createUser, findUserByPhone, findUserByIdentifier, getUserById } = require('../models/userModel');

exports.register = async (req, res) => {
  try {
    const { full_name, phone_number, email, password, role } = req.body;

    if (!full_name || !phone_number || !password) {
      return res.status(400).json({ error: 'full_name, phone_number and password are required' });
    }

    const allowedPublicRoles = ['user', 'student', 'hostel_owner', 'agent', 'house_hunter'];
    const requestedRole = role || 'user';

    if (!allowedPublicRoles.includes(requestedRole)) {
      return res.status(400).json({ error: 'Invalid role selected' });
    }

    const existing = await findUserByPhone(phone_number);
    if (existing) {
      return res.status(409).json({ error: 'A user with this phone number already exists' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const newUser = await createUser({
      full_name,
      phone_number,
      email,
      password_hash,
      role: requestedRole,
    });

    res.status(201).json({ message: 'User registered successfully', user: newUser });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong during registration' });
  }
};

exports.login = async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({ error: 'identifier (phone or email) and password are required' });
    }

    const user = await findUserByIdentifier(identifier);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: { id: user.id, full_name: user.full_name, role: user.role },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong during login' });
  }
};

exports.getMe = async (req, res) => {
  try {
    const user = await getUserById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching your profile' });
  }
};

exports.createAdmin = async (req, res) => {
  try {
    const { full_name, phone_number, email, password } = req.body;

    if (!full_name || !phone_number || !password) {
      return res.status(400).json({ error: 'full_name, phone_number and password are required' });
    }

    const existing = await findUserByPhone(phone_number);
    if (existing) {
      return res.status(409).json({ error: 'A user with this phone number already exists' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const newAdmin = await createUser({
      full_name,
      phone_number,
      email,
      password_hash,
      role: 'admin',
    });

    res.status(201).json({ message: 'Admin account created successfully', user: newAdmin });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while creating the admin account' });
  }
};