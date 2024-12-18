const express = require('express');
const Rock = require('../models/Rock');
const auth = require('../middleware/auth');

const router = express.Router();

// Get all rocks for a user
router.get('/', auth, async (req, res, next) => {
  try {
    const rocks = await Rock.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']]
    });
    res.json(rocks);
  } catch (error) {
    next(error);
  }
});

// Add a new rock
router.post('/', auth, async (req, res, next) => {
  try {
    const rock = await Rock.create({
      ...req.body,
      userId: req.user.id
    });
    res.status(201).json(rock);
  } catch (error) {
    next(error);
  }
});

// Delete a rock
router.delete('/:id', auth, async (req, res, next) => {
  try {
    const deleted = await Rock.destroy({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!deleted) {
      return res.status(404).json({ message: 'Rock not found' });
    }
    
    res.json({ message: 'Rock deleted' });
  } catch (error) {
    next(error);
  }
});

module.exports = router; 