# Spotit Backend

Backend API server for Spotit - a YouTube-based music streaming application.

## Prerequisites

Before running the backend, ensure you have the following installed:

### Required Software

1. **Node.js** (v14 or higher)
   ```bash
   node --version
   ```

2. **yt-dlp** (YouTube downloader)
   ```bash
   # Install using pip
   pip install yt-dlp
   
   # Or using your package manager
   # macOS
   brew install yt-dlp
   
   # Linux (Ubuntu/Debian)
   sudo apt install yt-dlp
   
   # Verify installation
   yt-dlp --version
   ```

3. **ffmpeg** (Audio/video processing)
   ```bash
   # macOS
   brew install ffmpeg
   
   # Linux (Ubuntu/Debian)
   sudo apt install ffmpeg
   
   # Verify installation
   ffmpeg -version
   ```

## Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install Node.js dependencies:
   ```bash
   npm install
   ```

## Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:3000` by default.

## API Endpoints

### 1. Search YouTube
Search for songs on YouTube.

**Endpoint:** `GET /search`

**Query Parameters:**
- `q` (required): Search query
- `limit` (optional): Maximum number of results (default: 10)

**Example:**
```bash
curl "http://localhost:3000/search?q=imagine%20dragons&limit=5"
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "results": [
    {
      "videoId": "ktvTqknDobU",
      "title": "Imagine Dragons - Radioactive",
      "artist": "ImagineDragonsVEVO",
      "duration": 187,
      "thumbnail": "https://i.ytimg.com/vi/ktvTqknDobU/maxresdefault.jpg",
      "url": "https://www.youtube.com/watch?v=ktvTqknDobU"
    }
  ]
}
```

### 2. Get Stream URL
Get a direct audio stream URL for a YouTube video.

**Endpoint:** `GET /stream`

**Query Parameters:**
- `videoId` (required): YouTube video ID

**Example:**
```bash
curl "http://localhost:3000/stream?videoId=ktvTqknDobU"
```

**Response:**
```json
{
  "success": true,
  "streamUrl": "https://rr3---sn-...",
  "videoId": "ktvTqknDobU",
  "title": "Imagine Dragons - Radioactive",
  "artist": "ImagineDragonsVEVO",
  "duration": 187,
  "thumbnail": "https://i.ytimg.com/vi/ktvTqknDobU/maxresdefault.jpg"
}
```

### 3. Download Song
Download a YouTube video as MP3.

**Endpoint:** `POST /download`

**Body Parameters:**
```json
{
  "videoId": "ktvTqknDobU",
  "title": "Radioactive"
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/download \
  -H "Content-Type: application/json" \
  -d '{"videoId":"ktvTqknDobU","title":"Radioactive"}'
```

**Response:**
```json
{
  "success": true,
  "message": "Download complete",
  "filename": "ktvTqknDobU_Radioactive.mp3",
  "url": "/song/ktvTqknDobU_Radioactive.mp3"
}
```

### 4. Get Library
Get list of all downloaded songs.

**Endpoint:** `GET /library`

**Example:**
```bash
curl "http://localhost:3000/library"
```

**Response:**
```json
{
  "success": true,
  "count": 3,
  "songs": [
    {
      "videoId": "ktvTqknDobU",
      "title": "Radioactive",
      "filename": "ktvTqknDobU_Radioactive.mp3",
      "url": "/song/ktvTqknDobU_Radioactive.mp3"
    }
  ]
}
```

### 5. Serve MP3 File
Stream or download an MP3 file.

**Endpoint:** `GET /song/:filename`

**Example:**
```bash
# Stream in browser
http://localhost:3000/song/ktvTqknDobU_Radioactive.mp3

# Download with curl
curl "http://localhost:3000/song/ktvTqknDobU_Radioactive.mp3" --output song.mp3
```

### 6. Delete Song
Delete a downloaded song.

**Endpoint:** `DELETE /song/:filename`

**Example:**
```bash
curl -X DELETE "http://localhost:3000/song/ktvTqknDobU_Radioactive.mp3"
```

**Response:**
```json
{
  "success": true,
  "message": "Song deleted successfully"
}
```

### 7. Health Check
Check if the server is running.

**Endpoint:** `GET /health`

**Example:**
```bash
curl "http://localhost:3000/health"
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-11-25T06:30:00.000Z",
  "service": "spotit-backend"
}
```

## Project Structure

```
backend/
├── app.js                 # Main Express application
├── package.json           # Node.js dependencies
├── routes/
│   └── api.js            # API route definitions
├── controllers/
│   └── musicController.js # Request handlers
├── services/
│   └── youtubeService.js  # YouTube/yt-dlp integration
└── downloads/             # Downloaded MP3 files (created automatically)
```

## Environment Variables

You can customize the server port using environment variables:

```bash
PORT=8080 npm start
```

## Troubleshooting

### yt-dlp not found
If you get "yt-dlp: command not found", ensure yt-dlp is installed and in your PATH:
```bash
which yt-dlp
```

### ffmpeg not found
If downloads fail with ffmpeg errors, ensure ffmpeg is installed:
```bash
which ffmpeg
```

### Permission errors
If you get permission errors when creating the downloads directory:
```bash
mkdir -p downloads
chmod 755 downloads
```

### CORS errors from Flutter app
The server has CORS enabled for all origins. If you still face CORS issues, check that the Flutter app is making requests to the correct URL.

## Performance Tips

1. **Caching**: yt-dlp caches video information. Clear cache if you experience stale data:
   ```bash
   yt-dlp --rm-cache-dir
   ```

2. **Download Speed**: Download speed depends on your internet connection and YouTube's servers.

3. **Concurrent Downloads**: The server can handle multiple download requests, but they will be processed sequentially by yt-dlp.

## Security Considerations

⚠️ **Important**: This backend is designed for personal/educational use only.

- The server allows downloads from YouTube, which may violate YouTube's Terms of Service
- In production, implement authentication and rate limiting
- Restrict CORS to specific origins
- Add input validation and sanitization
- Consider implementing user quotas for downloads

## Legal Notice

This software is provided for educational purposes only. Downloading copyrighted content from YouTube may violate YouTube's Terms of Service and copyright laws. Use at your own risk and ensure you have the right to download and use any content.
