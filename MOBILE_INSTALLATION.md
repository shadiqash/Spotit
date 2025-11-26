# 📱 Mobile Installation Guide

This guide will walk you through installing the Spotit app on your Android or iOS device.

## Prerequisites

Before you begin, ensure you have:

1. ✅ **Flutter SDK** installed on your computer ([Install Flutter](https://docs.flutter.dev/get-started/install))
2. ✅ **Backend server** running (see main README.md)
3. ✅ **USB cable** to connect your phone to computer (or wireless debugging enabled)
4. ✅ **Developer mode** enabled on your phone

---

## 🤖 Android Installation

### Step 1: Enable Developer Mode

1. Open **Settings** on your Android device
2. Go to **About Phone**
3. Tap **Build Number** 7 times
4. You'll see "You are now a developer!"

### Step 2: Enable USB Debugging

1. Go to **Settings** → **Developer Options**
2. Enable **USB Debugging**
3. Enable **Install via USB** (if available)

### Step 3: Connect Your Device

1. Connect your Android device to your computer via USB
2. On your phone, tap **Allow** when prompted for USB debugging
3. Verify connection:
   ```bash
   flutter devices
   ```
   You should see your device listed

### Step 4: Configure Backend URL

Since your phone and computer are on the same network, you need to use your computer's IP address:

1. **Find your computer's IP address:**
   
   **On Linux/Mac:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
   
   **On Windows:**
   ```bash
   ipconfig
   ```
   
   Look for something like `192.168.1.100`

2. **Update the API URL:**
   
   Open `lib/services/api_service.dart` and change:
   ```dart
   static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000';
   ```
   
   For example:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000';
   ```

### Step 5: Install the App

```bash
# Make sure you're in the project directory
cd /home/shadiq/dc/spotit

# Get dependencies
flutter pub get

# Run the app on your connected device
flutter run
```

The app will be installed and launched on your phone!

### Step 6: Build APK (Optional)

To create an installable APK file:

```bash
# Build release APK
flutter build apk --release

# The APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

You can then:
- Copy the APK to your phone
- Install it directly
- Share it with others

---

## 🍎 iOS Installation

### Step 1: Requirements

1. **Mac computer** (required for iOS development)
2. **Xcode** installed from App Store
3. **Apple Developer Account** (free account works for testing)
4. **iOS device** with iOS 12.0 or higher

### Step 2: Configure Xcode

1. Open Xcode
2. Go to **Xcode** → **Preferences** → **Accounts**
3. Add your Apple ID
4. Sign in

### Step 3: Connect Your Device

1. Connect your iPhone/iPad via USB
2. Trust your computer on the device
3. Verify connection:
   ```bash
   flutter devices
   ```

### Step 4: Configure Backend URL

1. **Find your computer's IP address:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. **Update the API URL:**
   
   Open `lib/services/api_service.dart` and change:
   ```dart
   static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000';
   ```

### Step 5: Configure Code Signing

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode:
   - Select **Runner** in the project navigator
   - Go to **Signing & Capabilities**
   - Select your **Team** (your Apple ID)
   - Xcode will automatically create a provisioning profile

### Step 6: Install the App

```bash
# Make sure you're in the project directory
cd /home/shadiq/dc/spotit

# Get dependencies
flutter pub get

# Run on your iOS device
flutter run
```

### Step 7: Trust Developer Certificate

1. On your iOS device, go to **Settings** → **General** → **VPN & Device Management**
2. Find your developer certificate
3. Tap **Trust**

The app should now run on your iPhone/iPad!

---

## 🔧 Troubleshooting

### "Device not found"

**Solution:**
```bash
# Check connected devices
flutter devices

# If not listed, try:
adb devices  # For Android
```

### "Connection refused" errors in app

**Problem:** App can't reach the backend server

**Solution:**
1. Verify backend is running: `curl http://localhost:3000/health`
2. Check firewall settings - allow port 3000
3. Verify IP address is correct in `api_service.dart`
4. Make sure phone and computer are on the same WiFi network

### Android: "Installation failed"

**Solution:**
```bash
# Uninstall previous version
adb uninstall com.example.spotit

# Try again
flutter run
```

### iOS: "Code signing error"

**Solution:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Change the **Bundle Identifier** to something unique (e.g., `com.yourname.spotit`)
3. Select your Team in Signing & Capabilities
4. Try again

### "yt-dlp not found" errors

**Problem:** Backend can't find yt-dlp

**Solution:**
Make sure yt-dlp and ffmpeg are installed on the computer running the backend:
```bash
# Install yt-dlp
pip install yt-dlp

# Install ffmpeg
# macOS
brew install ffmpeg

# Linux
sudo apt install ffmpeg
```

---

## 📶 Testing Without USB (Wireless)

### Android Wireless Debugging (Android 11+)

1. Enable **Wireless Debugging** in Developer Options
2. Connect via WiFi:
   ```bash
   adb pair <IP>:<PORT>
   adb connect <IP>:<PORT>
   flutter run
   ```

### iOS Wireless Debugging

1. In Xcode, go to **Window** → **Devices and Simulators**
2. Select your device
3. Check **Connect via network**
4. Disconnect USB cable

---

## 🚀 Quick Start Checklist

- [ ] Backend server running on computer
- [ ] Developer mode enabled on phone
- [ ] USB debugging enabled (Android) or device trusted (iOS)
- [ ] Phone connected to computer
- [ ] API URL updated with computer's IP address
- [ ] `flutter devices` shows your device
- [ ] Run `flutter run`

---

## 📝 Important Notes

### Network Requirements

- Your **phone** and **computer** must be on the **same WiFi network**
- The backend server must be accessible from your phone
- Port 3000 must not be blocked by firewall

### Backend Server

The backend must be running on your computer:
```bash
cd backend
npm start
```

Keep this running while using the app!

### First Launch

The first time you run the app:
1. It may take a few minutes to build
2. Grant permissions when prompted
3. Test search functionality
4. Try downloading a song

---

## 🎯 Next Steps

Once installed:

1. **Test Search** - Search for a song
2. **Test Streaming** - Play a song
3. **Test Download** - Download a song for offline playback
4. **Test Library** - Check your downloaded songs

Enjoy your music! 🎵
