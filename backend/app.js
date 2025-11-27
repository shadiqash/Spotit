// backend/app.js
const express = require('express');
const { execFile } = require('child_process');
const app = express();
const PORT = process.env.PORT || 3000;

// Simple health check
app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

// Proxy endpoint to fetch audio URL via yt-dlp
app.get('/api/audio/:videoId', (req, res) => {
    const videoId = req.params.videoId;
    const url = `https://www.youtube.com/watch?v=${videoId}`;
    // yt-dlp arguments: get best audio (m4a) URL only
    const args = [url, '--format', 'bestaudio[ext=m4a]/bestaudio', '--quiet', '--no-warnings', '--skip-download', '--print', 'url'];
    execFile('yt-dlp', args, (err, stdout, stderr) => {
        if (err) {
            console.error('yt-dlp error:', err);
            return res.status(500).json({ error: 'Failed to fetch audio URL' });
        }
        const audioUrl = stdout.trim();
        if (!audioUrl) {
            return res.status(404).json({ error: 'No audio stream found' });
        }
        res.json({ url: audioUrl });
    });
});

app.listen(PORT, () => console.log(`Audio proxy server listening on port ${PORT}`));
