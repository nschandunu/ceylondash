require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');

const parcelRoutes = require('./routes/parcelRoutes');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

// Connect to MongoDB
mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.error('MongoDB connection error:', err));

// Basic health check route
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/parcels', parcelRoutes);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
