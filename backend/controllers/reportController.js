const { createReport, getAllReports, getReportById, updateReportStatus } = require('../models/reportModel');

exports.create = async (req, res) => {
  try {
    const { reported_user_id, related_type, related_id, reason } = req.body;

    if (!reported_user_id || !reason) {
      return res.status(400).json({ error: 'reported_user_id and reason are required' });
    }
    if (reported_user_id === req.user.id) {
      return res.status(400).json({ error: 'You cannot report yourself' });
    }

    const report = await createReport({
      reporter_id: req.user.id,
      reported_user_id,
      related_type,
      related_id,
      reason,
    });

    res.status(201).json({ message: 'Report submitted. Our team will review it shortly.', report });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while submitting the report' });
  }
};

// Admin-only: view all reports, optionally filtered by status
exports.list = async (req, res) => {
  try {
    const { status } = req.query;
    const reports = await getAllReports({ status });
    res.json({ reports });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while fetching reports' });
  }
};

// Admin-only: mark a report as reviewed, or ban the reported user
exports.updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['reviewed', 'banned'].includes(status)) {
      return res.status(400).json({ error: 'status must be "reviewed" or "banned"' });
    }

    const report = await getReportById(id);
    if (!report) {
      return res.status(404).json({ error: 'Report not found' });
    }

    const updated = await updateReportStatus(id, status);
    res.json({ message: `Report marked as ${status}`, report: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Something went wrong while updating the report' });
  }
};