const express = require('express');
const Rock = require('../models/Rock');
const auth = require('../middleware/auth');
const {diskStorage} = require("multer");
const {mkdirSync, existsSync} = require("node:fs");
const {join, extname} = require("node:path");
const multer = require("multer");

const router = express.Router();

// Setup multer to store images in a directory within the container
const storage = diskStorage({
  destination: (req, file, cb) => {
    // Define where to store the image (inside the container's filesystem)
    const uploadPath = join(__dirname, '../uploads/'); // You can modify this path
    if (!existsSync(uploadPath)) {
      mkdirSync(uploadPath);
    }
    cb(null, uploadPath);  // Destination folder for image files
  },
  filename: (req, file, cb) => {
    // Define the filename for the uploaded image (you could use a UUID or timestamp to avoid overwriting)
    const fileName = Date.now() + extname(file.originalname);  // Example: timestamp-based filename
    cb(null, fileName);
  }
});

const upload = multer({ storage: storage });

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
router.post('/', auth, upload.single('image'), async (req, res, next) => {
  try {
    const imageUrl = `/uploads/${req.file.filename}`;

    const rock = await Rock.create({
      name: req.body.name,
      category: req.body.category,
      description: req.body.description,
      properties: req.body.properties,
      color: req.body.color,
      imageUrl: imageUrl,
      common_uses: req.body.common_uses,
      imageQuality: req.body.imageQuality,
      confidenceLevel: req.body.confidenceLevel,
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

router.get('/uploads/:filepath', (req, res) => {
  const filePath = req.params.filepath;
  const fullPath = join(__dirname, '../uploads', filePath);
  console.log(`Serving file: ${fullPath}`); // Log the full path of the file being served
  res.sendFile(fullPath, (err) => {
    if (err) {
      console.error(`Error serving file: ${err.message}`);
      res.status(404).json({ message: 'File not found' });
    }
  });
});


module.exports = router;
