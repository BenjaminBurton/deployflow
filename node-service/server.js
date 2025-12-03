const express = require('express');
const axios = require('axios');
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'node-service',
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    service: 'DeployFlow Node.js Service',
    version: '1.0.0',
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Call Go backend service
app.get('/api/backend', async (req, res) => {
  try {
    const goServiceUrl = process.env.GO_SERVICE_URL || 'http://go-service:8080';
    const response = await axios.get(`${goServiceUrl}/api/data`);
    
    res.json({
      message: 'Successfully called Go backend',
      backend_response: response.data,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to connect to Go backend',
      details: error.message
    });
  }
});

// Readiness probe
app.get('/ready', (req, res) => {
  res.status(200).json({ status: 'ready' });
});

// Liveness probe
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'alive' });
});

// Start server
const server = app.listen(port, () => {
  console.log(`🚀 Node.js service listening on port ${port}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

module.exports = app;
