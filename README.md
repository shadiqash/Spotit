# Spotit - YouTube Music Streaming App

<div align="center">
  <h3>🎵 A Spotify-like music streaming app powered by YouTube</h3>
  <p>Built with Flutter & Node.js</p>
</div>

---

## 📱 Features

- **🔍 Search** - Search for any song on YouTube
- **▶️ Stream** - Stream audio directly from YouTube
- **⬇️ Download** - Download songs as MP3 for offline playback
- **📚 Library** - Manage your downloaded music collection
- **🎛️ Full Player** - Beautiful full-screen player with seek controls
- **🎨 Mini Player** - Persistent bottom player (Spotify-style)
- **📱 Cross-Platform** - Works on iOS and Android

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│          Flutter Mobile App             │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ Search  │  │ Player  │  │ Library │ │
│  └─────────┘  └─────────┘  └─────────┘ │
│         │           │           │       │
│         └───────────┴───────────┘       │
│                  │                      │
│            Provider State                │
│                  │                      │
└──────────────────┼──────────────────────┘
                   │ HTTP/REST
┌──────────────────┼──────────────────────┐
│                  │                      │
│         Node.js Backend API             │
│  ┌──────────────────────────────────┐  │
│  │  Express + yt-dlp + ffmpeg       │  │
│  └──────────────────────────────────┘  │
│                  │                      │
└──────────────────┼──────────────────────┘
                   │
            ┌──────┴──────┐
            │   YouTube   │
            └─────────────┘
```

## 🚀 Quick Start

### Prerequisites

1. **Node.js** (v14+)
2. **Flutter** (v3.0+)
3. **yt-dlp** - [Installation Guide](https://github.com/yt-dlp/yt-dlp#installation)
4. **ffmpeg** - [Installation Guide](https://ffmpeg.org/download.html)

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Start the server
npm start
```

The backend will run on `http://localhost:3000`

For detailed backend documentation, see [backend/README.md](backend/README.md)

### Flutter App Setup

```bash
# Install Flutter dependencies
flutter pub get

# Update API URL in lib/services/api_service.dart
# For Android emulator: http://10.0.2.2:3000
# For iOS simulator: http://localhost:3000
# For physical device: http://YOUR_COMPUTER_IP:3000

# Run the app
flutter run
```

## 📂 Project Structure

```
spotit/
├── backend/                    # Node.js backend
│   ├── app.js                 # Express server
│   ├── routes/                # API routes
│   ├── controllers/           # Request handlers
│   ├── services/              # Business logic (yt-dlp)
│   └── downloads/             # Downloaded MP3 files
│
├── lib/                       # Flutter app
│   ├── main.dart             # App entry point
│   ├── models/               # Data models
│   │   ├── song.dart
│   │   └── player_state.dart
│   ├── services/             # API & audio services
│   │   ├── api_service.dart
│   │   ├── audio_player_service.dart
│   │   ├── download_service.dart
│   │   └── local_storage_service.dart
│   ├── providers/            # State management
│   │   ├── player_provider.dart
│   │   ├── library_provider.dart
│   │   └── search_provider.dart
│   ├── pages/                # UI screens
│   │   ├── search_page.dart
│   │   ├── player_page.dart
│   │   └── library_page.dart
│   └── widgets/              # Reusable components
│       ├── song_tile.dart
│       ├── player_controls.dart
│       └── mini_player.dart
│
└── ios/Runner/Info.plist     # iOS permissions
```

## 🔧 Configuration

### Backend API URL

Update the `baseUrl` in `lib/services/api_service.dart`:

```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// For iOS simulator
static const String baseUrl = 'http://localhost:3000';

// For physical device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.100:3000';
```

### iOS Permissions

The app requires the following iOS permissions (already configured in `Info.plist`):

- **App Transport Security** - Allow HTTP connections to localhost
- **Background Audio** - Continue playing music in background
- **File Access** - Save downloaded MP3 files

## 📖 API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/search?q=<query>` | Search YouTube for songs |
| GET | `/stream?videoId=<id>` | Get direct audio stream URL |
| POST | `/download` | Download song as MP3 |
| GET | `/library` | List downloaded songs |
| GET | `/song/:filename` | Stream/download MP3 file |
| DELETE | `/song/:filename` | Delete downloaded song |

For detailed API documentation with examples, see [backend/README.md](backend/README.md)

## 🎨 UI Screenshots

The app features a Spotify-inspired design with:

- **Green accent color** (#4CAF50)
- **Dark theme** for player
- **Material Design** components
- **Smooth animations** and transitions

## ⚡ Performance & Best Practices

### Caching
- **Images**: Cached using `cached_network_image`
- **Audio**: Streamed directly, no local caching for online playback
- **Downloads**: Stored in app documents directory

### State Management
- Uses **Provider** pattern for reactive state updates
- Separate providers for player, library, and search
- Efficient rebuilds with `Consumer` widgets

### Audio Playback
- **just_audio** package for robust playback
- Supports both streaming and local file playback
- Background audio support on iOS

### Downloads
- **Dio** for progress tracking
- Downloads happen on backend first, then transferred to device
- Prevents duplicate downloads

## 🐛 Troubleshooting

### Backend Issues

**yt-dlp not found**
```bash
# Install yt-dlp
pip install yt-dlp

# Verify installation
yt-dlp --version
```

**ffmpeg not found**
```bash
# macOS
brew install ffmpeg

# Linux
sudo apt install ffmpeg
```

### Flutter Issues

**Connection refused**
- Ensure backend is running on port 3000
- Check `baseUrl` in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`

**Audio not playing**
- Check internet connection for streaming
- Verify stream URL is valid
- Check device volume and audio output

**Downloads failing**
- Ensure backend has write permissions for `downloads/` folder
- Check available storage space
- Verify ffmpeg is installed

## ⚠️ Legal Notice

**IMPORTANT**: This application is for **educational purposes only**.

- Downloading copyrighted content from YouTube may violate YouTube's Terms of Service
- This app is intended for personal use with content you have rights to
- Use at your own risk and ensure compliance with applicable laws
- The developers are not responsible for misuse of this software

## 🛠️ Built With

### Backend
- [Node.js](https://nodejs.org/) - JavaScript runtime
- [Express](https://expressjs.com/) - Web framework
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube downloader
- [ffmpeg](https://ffmpeg.org/) - Audio processing

### Frontend
- [Flutter](https://flutter.dev/) - UI framework
- [just_audio](https://pub.dev/packages/just_audio) - Audio playback
- [dio](https://pub.dev/packages/dio) - HTTP client
- [provider](https://pub.dev/packages/provider) - State management
- [cached_network_image](https://pub.dev/packages/cached_network_image) - Image caching

## 📝 License

This project is licensed for educational use only. See legal notice above.

## 🤝 Contributing

This is an educational project. Feel free to fork and modify for your own learning purposes.

---

<div align="center">
  Made with ❤️ using Flutter & Node.js
</div>
