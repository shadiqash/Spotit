/**
 * API Routes
 * 
 * Defines all API endpoints and maps them to controller functions.
 */

const express = require('express');
const router = express.Router();
const musicController = require('../controllers/musicController');

/**
 * GET /search
 * Search for songs on YouTube
 * Query params: q (query), limit (optional)
 */
router.get('/search', musicController.search);

/**
 * GET /stream
 * Get direct audio stream URL for a video
 * Query params: videoId
 */
router.get('/stream', musicController.stream);

/**
 * POST /download
 * Download a YouTube video as MP3
 * Body: { videoId, title }
 */
router.post('/download', musicController.download);

/**
 * GET /library
 * Get list of all downloaded songs
 */
router.get('/library', musicController.library);

/**
 * DELETE /song/:filename
 * Delete a downloaded song
 * Params: filename
 */
router.delete('/song/:filename', musicController.deleteSong);

module.exports = router;
