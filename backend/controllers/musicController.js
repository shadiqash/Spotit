/**
 * Music Controller
 * 
 * Handles HTTP requests for music-related operations.
 * Acts as the intermediary between routes and services.
 */

const youtubeService = require('../services/youtubeService');

/**
 * Search for songs on YouTube
 * 
 * Query params:
 * - q: Search query (required)
 * - limit: Max results (optional, default: 10)
 * 
 * Response: Array of song objects
 */
async function search(req, res) {
    try {
        const { q, limit } = req.query;

        if (!q) {
            return res.status(400).json({
                error: 'Missing required parameter: q (query)'
            });
        }

        const results = await youtubeService.searchYouTube(q, parseInt(limit) || 10);

        res.json({
            success: true,
            count: results.length,
            results
        });
    } catch (error) {
        console.error('Search error:', error);
        res.status(500).json({
            error: 'Search failed',
            message: error.message
        });
    }
}

/**
 * Get direct audio stream URL for a video
 * 
 * Query params:
 * - videoId: YouTube video ID (required)
 * 
 * Response: Object with streamUrl and metadata
 */
async function stream(req, res) {
    try {
        const { videoId } = req.query;

        if (!videoId) {
            return res.status(400).json({
                error: 'Missing required parameter: videoId'
            });
        }

        const streamData = await youtubeService.getAudioStreamUrl(videoId);

        res.json({
            success: true,
            ...streamData
        });
    } catch (error) {
        console.error('Stream error:', error);
        res.status(500).json({
            error: 'Failed to get stream URL',
            message: error.message
        });
    }
}

/**
 * Download a YouTube video as MP3
 * 
 * Body params:
 * - videoId: YouTube video ID (required)
 * - title: Song title (required)
 * 
 * Response: Object with download info
 */
async function download(req, res) {
    try {
        const { videoId, title } = req.body;

        if (!videoId || !title) {
            return res.status(400).json({
                error: 'Missing required parameters: videoId and title'
            });
        }

        const result = await youtubeService.downloadAsMp3(videoId, title);

        res.json({
            success: true,
            message: result.alreadyExists ? 'File already exists' : 'Download complete',
            filename: result.filename,
            url: `/song/${result.filename}`
        });
    } catch (error) {
        console.error('Download error:', error);
        res.status(500).json({
            error: 'Download failed',
            message: error.message
        });
    }
}

/**
 * Get list of all downloaded songs
 * 
 * Response: Array of downloaded song objects
 */
async function library(req, res) {
    try {
        const songs = await youtubeService.getDownloadedSongs();

        res.json({
            success: true,
            count: songs.length,
            songs
        });
    } catch (error) {
        console.error('Library error:', error);
        res.status(500).json({
            error: 'Failed to get library',
            message: error.message
        });
    }
}

/**
 * Delete a downloaded song
 * 
 * Params:
 * - filename: Name of the file to delete (required)
 * 
 * Response: Success confirmation
 */
async function deleteSong(req, res) {
    try {
        const { filename } = req.params;

        if (!filename) {
            return res.status(400).json({
                error: 'Missing required parameter: filename'
            });
        }

        await youtubeService.deleteSong(filename);

        res.json({
            success: true,
            message: 'Song deleted successfully'
        });
    } catch (error) {
        console.error('Delete error:', error);
        res.status(500).json({
            error: 'Delete failed',
            message: error.message
        });
    }
}

module.exports = {
    search,
    stream,
    download,
    library,
    deleteSong
};
