/**
 * YouTube Service
 * 
 * This service provides functionality to interact with YouTube using yt-dlp.
 * It handles searching, extracting audio URLs, and downloading MP3 files.
 * 
 * Requirements:
 * - yt-dlp must be installed and available in system PATH
 * - ffmpeg must be installed for audio conversion
 */

const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const path = require('path');

const execAsync = promisify(exec);

// Directory where downloaded MP3 files are stored
const DOWNLOADS_DIR = path.join(__dirname, '../downloads');

/**
 * Search YouTube for videos matching the query
 * 
 * @param {string} query - Search query string
 * @param {number} limit - Maximum number of results (default: 10)
 * @returns {Promise<Array>} Array of video objects with id, title, duration, thumbnail
 */
async function searchYouTube(query, limit = 10) {
    try {
        // Use yt-dlp to search YouTube
        // --dump-json: Output video info as JSON
        // --skip-download: Don't download the video
        // ytsearch{limit}: Search YouTube for {limit} results
        const command = `yt-dlp --dump-json --skip-download "ytsearch${limit}:${query}"`;

        const { stdout, stderr } = await execAsync(command);

        if (stderr && !stderr.includes('WARNING')) {
            console.error('yt-dlp stderr:', stderr);
        }

        // Parse JSON output - each line is a separate JSON object
        const lines = stdout.trim().split('\n').filter(line => line.trim());
        const results = lines.map(line => {
            const data = JSON.parse(line);
            return {
                videoId: data.id,
                title: data.title,
                artist: data.uploader || data.channel || 'Unknown Artist',
                duration: data.duration || 0,
                thumbnail: data.thumbnail || data.thumbnails?.[0]?.url || '',
                url: `https://www.youtube.com/watch?v=${data.id}`
            };
        });

        return results;
    } catch (error) {
        console.error('Error searching YouTube:', error);
        throw new Error(`YouTube search failed: ${error.message}`);
    }
}

/**
 * Extract direct audio stream URL from a YouTube video
 * 
 * @param {string} videoId - YouTube video ID
 * @returns {Promise<Object>} Object containing streamUrl and video metadata
 */
async function getAudioStreamUrl(videoId) {
    try {
        // Use yt-dlp to get the best audio format URL
        // -f bestaudio: Select best audio quality
        // --get-url: Print the direct URL
        // --dump-json: Also get metadata
        const command = `yt-dlp -f bestaudio --get-url --dump-json "https://www.youtube.com/watch?v=${videoId}"`;

        const { stdout, stderr } = await execAsync(command);

        if (stderr && !stderr.includes('WARNING')) {
            console.error('yt-dlp stderr:', stderr);
        }

        const lines = stdout.trim().split('\n');

        // First line is the direct URL, second line is JSON metadata
        const streamUrl = lines[0];
        const metadata = lines.length > 1 ? JSON.parse(lines[1]) : {};

        return {
            streamUrl,
            videoId: metadata.id || videoId,
            title: metadata.title || 'Unknown Title',
            artist: metadata.uploader || metadata.channel || 'Unknown Artist',
            duration: metadata.duration || 0,
            thumbnail: metadata.thumbnail || metadata.thumbnails?.[0]?.url || ''
        };
    } catch (error) {
        console.error('Error getting stream URL:', error);
        throw new Error(`Failed to get stream URL: ${error.message}`);
    }
}

/**
 * Download YouTube video as MP3 file
 * 
 * @param {string} videoId - YouTube video ID
 * @param {string} title - Song title (used for filename)
 * @returns {Promise<Object>} Object containing filename and file path
 */
async function downloadAsMp3(videoId, title) {
    try {
        // Sanitize filename - remove special characters
        const sanitizedTitle = title.replace(/[^a-zA-Z0-9\s-]/g, '').replace(/\s+/g, '_');
        const filename = `${videoId}_${sanitizedTitle}.mp3`;
        const outputPath = path.join(DOWNLOADS_DIR, filename);

        // Check if file already exists
        try {
            await fs.access(outputPath);
            console.log(`File already exists: ${filename}`);
            return { filename, path: outputPath, alreadyExists: true };
        } catch {
            // File doesn't exist, proceed with download
        }

        // Ensure downloads directory exists
        await fs.mkdir(DOWNLOADS_DIR, { recursive: true });

        // Download and convert to MP3 using yt-dlp with ffmpeg
        // -x: Extract audio
        // --audio-format mp3: Convert to MP3
        // --audio-quality 0: Best audio quality
        // -o: Output filename template
        const command = `yt-dlp -x --audio-format mp3 --audio-quality 0 -o "${outputPath.replace('.mp3', '.%(ext)s')}" "https://www.youtube.com/watch?v=${videoId}"`;

        console.log(`Downloading: ${title} (${videoId})`);
        const { stdout, stderr } = await execAsync(command, { maxBuffer: 10 * 1024 * 1024 });

        if (stderr && !stderr.includes('WARNING')) {
            console.error('yt-dlp stderr:', stderr);
        }

        console.log(`Download complete: ${filename}`);

        return { filename, path: outputPath, alreadyExists: false };
    } catch (error) {
        console.error('Error downloading MP3:', error);
        throw new Error(`Download failed: ${error.message}`);
    }
}

/**
 * Get list of all downloaded MP3 files
 * 
 * @returns {Promise<Array>} Array of song objects with metadata
 */
async function getDownloadedSongs() {
    try {
        // Ensure downloads directory exists
        await fs.mkdir(DOWNLOADS_DIR, { recursive: true });

        const files = await fs.readdir(DOWNLOADS_DIR);
        const mp3Files = files.filter(file => file.endsWith('.mp3'));

        // Extract metadata from filenames
        const songs = mp3Files.map(filename => {
            // Filename format: {videoId}_{title}.mp3
            const match = filename.match(/^([^_]+)_(.+)\.mp3$/);

            if (match) {
                const [, videoId, titlePart] = match;
                const title = titlePart.replace(/_/g, ' ');

                return {
                    videoId,
                    title,
                    filename,
                    url: `/song/${filename}`
                };
            }

            // Fallback for files that don't match expected format
            return {
                videoId: filename.replace('.mp3', ''),
                title: filename.replace('.mp3', '').replace(/_/g, ' '),
                filename,
                url: `/song/${filename}`
            };
        });

        return songs;
    } catch (error) {
        console.error('Error getting downloaded songs:', error);
        throw new Error(`Failed to get library: ${error.message}`);
    }
}

/**
 * Delete a downloaded MP3 file
 * 
 * @param {string} filename - Name of the file to delete
 * @returns {Promise<boolean>} True if deleted successfully
 */
async function deleteSong(filename) {
    try {
        const filePath = path.join(DOWNLOADS_DIR, filename);
        await fs.unlink(filePath);
        console.log(`Deleted: ${filename}`);
        return true;
    } catch (error) {
        console.error('Error deleting song:', error);
        throw new Error(`Delete failed: ${error.message}`);
    }
}

module.exports = {
    searchYouTube,
    getAudioStreamUrl,
    downloadAsMp3,
    getDownloadedSongs,
    deleteSong,
    DOWNLOADS_DIR
};
