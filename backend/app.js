/**
 * Spotit Backend Server
 * 
 * Express server providing API endpoints for YouTube-based music streaming.
 * 
 * Features:
 * - Search YouTube for songs
 * - Get direct audio stream URLs
 * - Download songs as MP3
 * - Serve downloaded MP3 files
 * - Manage local music library
 * 
 * Requirements:
 * - yt-dlp installed and in PATH
 * - ffmpeg installed and in PATH
 */

const express = require('express');
const cors = require('cors');
const path = require('path');
const apiRoutes = require('./routes/api');
const { DOWNLOADS_DIR } = require('./services/youtubeService');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
// Enable CORS for all origins (adjust in production for security)
app.use(cors());

// Parse JSON request bodies
app.use(express.json());

// Log all requests
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// API Routes
app.use('/', apiRoutes);

/**
 * Serve MP3 files
 * GET /song/:filename
 * 
 * This endpoint serves the downloaded MP3 files.
 * Files are served with proper headers for audio streaming.
 */
app.get('/song/:filename', (req, res) => {
    const { filename } = req.params;

    // Security: Ensure filename doesn't contain path traversal
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        return res.status(400).json({
            error: 'Invalid filename'
        });
    }

    // Ensure it's an MP3 file
    if (!filename.endsWith('.mp3')) {
        return res.status(400).json({
            error: 'Only MP3 files are supported'
        });
    }

    const filePath = path.join(DOWNLOADS_DIR, filename);

    // Set headers for audio streaming
    res.setHeader('Content-Type', 'audio/mpeg');
    res.setHeader('Accept-Ranges', 'bytes');

    // Send file (Express handles streaming automatically)
    res.sendFile(filePath, (err) => {
        if (err) {
            console.error('Error serving file:', err);
            if (!res.headersSent) {
                res.status(404).json({
                    error: 'File not found'
                });
            }
        }
    });
});

/**
 * Health check endpoint
 * GET /health
 */
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        service: 'spotit-backend'
    });
});

/**
 * Root endpoint - API information
 * GET /
 */
app.get('/', (req, res) => {
    res.json({
        name: 'Spotit Backend API',
        version: '1.0.0',
        endpoints: {
            search: 'GET /search?q=<query>&limit=<number>',
            stream: 'GET /stream?videoId=<id>',
            download: 'POST /download (body: {videoId, title})',
            library: 'GET /library',
            deleteSong: 'DELETE /song/:filename',
            serveSong: 'GET /song/:filename',
            health: 'GET /health'
        }
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({
        error: 'Internal server error',
        message: err.message
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Endpoint not found',
        path: req.url
    });
});

// Start server
app.listen(PORT, () => {
    console.log('=================================');
    console.log('🎵 Spotit Backend Server');
    console.log('=================================');
    console.log(`Server running on port ${PORT}`);
    console.log(`API URL: http://localhost:${PORT}`);
    console.log(`Downloads directory: ${DOWNLOADS_DIR}`);
    console.log('=================================');
    console.log('Available endpoints:');
    console.log(`  GET  /search?q=<query>`);
    console.log(`  GET  /stream?videoId=<id>`);
    console.log(`  POST /download`);
    console.log(`  GET  /library`);
    console.log(`  GET  /song/:filename`);
    console.log('=================================');
});

module.exports = app;
