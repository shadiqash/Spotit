# 🍎 Build iOS IPA with Sideloadly

This guide shows you how to build an IPA file for your Spotit app and install it on your iPhone using Sideloadly.

## 📋 Prerequisites

- ✅ **Sideloadly** installed on your computer
- ✅ **Apple ID** (free account works)
- ✅ **iPhone** connected via USB
- ✅ **GitHub account** (free)

---

## 🚀 Method 1: GitHub Actions (Recommended)

GitHub Actions provides free macOS runners that can build iOS apps automatically.

### Step 1: Push Your Code to GitHub

If you haven't already initialized git:

```bash
cd /home/shadiq/dc/spotit

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Spotit music app"

# Create a new repository on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/spotit.git
git branch -M main
git push -u origin main
```

### Step 2: Trigger the Build

The GitHub Actions workflow is already configured in `.github/workflows/build-ios.yml`.

**Automatic builds:**
- Every time you push to `main` branch, a build will trigger automatically

**Manual build:**
1. Go to your GitHub repository
2. Click **Actions** tab
3. Click **Build iOS IPA** workflow
4. Click **Run workflow** → **Run workflow**

### Step 3: Download the IPA

1. Wait for the build to complete (~10-15 minutes)
2. Go to the **Actions** tab
3. Click on the completed workflow run
4. Scroll down to **Artifacts** section
5. Download **spotit-ios-app.zip**
6. Extract to get `spotit.ipa`

### Step 4: Install with Sideloadly

Since you already have experience with Sideloadly:

1. **Open Sideloadly**
2. **Connect your iPhone** via USB
3. **Select your device** from the dropdown
4. **Drag `spotit.ipa`** into Sideloadly
5. **Enter your Apple ID** credentials
6. **Click Start**
7. **Wait for installation** to complete

### Step 5: Trust the Certificate

On your iPhone:
1. Go to **Settings** → **General** → **VPN & Device Management**
2. Find your Apple ID certificate
3. Tap **Trust**

### Step 6: Configure Backend URL

Before using the app, update the backend URL:

1. **Find your computer's IP address:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
   
2. **Edit the API service:**
   Open `lib/services/api_service.dart` and update:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:3000';
   ```
   Example: `http://192.168.1.100:3000`

3. **Rebuild and reinstall** (push to GitHub, download new IPA, install with Sideloadly)

---

## 🔧 Method 2: Local Build (If You Have Flutter Installed)

If you have Flutter installed locally:

```bash
cd /home/shadiq/dc/spotit

# Get dependencies
flutter pub get

# Build iOS (no codesign)
flutter build ios --release --no-codesign

# Create IPA manually
mkdir -p Payload
cp -r build/ios/iphoneos/Runner.app Payload/
zip -r spotit.ipa Payload
rm -rf Payload

# Your IPA is now at: spotit.ipa
```

Then install with Sideloadly as described above.

---

## ⚙️ Configuration Tips

### Update Bundle Identifier (Optional)

To avoid conflicts with other apps, you can change the bundle identifier:

1. Edit `ios/Runner/Info.plist` (already exists)
2. The bundle ID is set in the Xcode project (requires Mac to change easily)
3. Or use the default: `com.example.spotit`

### Backend Deployment

For production use, deploy your backend to a cloud service:

**Free Options:**
- **[Render](https://render.com)** - Free tier available
- **[Railway](https://railway.app)** - $5 free credit monthly
- **[Fly.io](https://fly.io)** - Free tier available

Then update `baseUrl` to your production URL:
```dart
static const String baseUrl = 'https://your-app.onrender.com';
```

---

## 📝 Important Notes

### Free Apple Developer Account Limitations

- **Apps expire after 7 days** - You'll need to reinstall weekly
- **Maximum 3 apps** at a time
- **No TestFlight** access

### Paid Account ($99/year) Benefits

- **Apps valid for 1 year**
- **Up to 100 devices**
- **TestFlight** for easier distribution
- **App Store** publishing

### Network Requirements

- Your iPhone and computer must be on the **same WiFi network**
- Backend server must be running: `cd backend && npm start`
- Port 3000 must not be blocked

---

## 🔄 Updating the App

When you make changes:

1. **Commit and push** to GitHub
   ```bash
   git add .
   git commit -m "Update: description of changes"
   git push
   ```

2. **Wait for GitHub Actions** to build new IPA

3. **Download new IPA** from Artifacts

4. **Reinstall with Sideloadly**

---

## 🐛 Troubleshooting

### "Build failed" in GitHub Actions

**Check the logs:**
1. Go to Actions tab
2. Click on the failed workflow
3. Check the error message
4. Common issues:
   - Missing dependencies in `pubspec.yaml`
   - Syntax errors in Dart code
   - iOS configuration issues

### "Sideloadly error: Provisioning profile"

**Solution:**
- Make sure you're using your Apple ID
- Try removing and re-adding your Apple ID in Sideloadly
- Check that your Apple ID is verified

### "App crashes on launch"

**Solution:**
1. Check backend is running and accessible
2. Verify API URL is correct in `api_service.dart`
3. Check iOS logs in Xcode (requires Mac)
4. Ensure all permissions are granted

### "Untrusted Developer"

**Solution:**
- Settings → General → VPN & Device Management
- Trust your developer certificate

---

## 📊 Build Status

You can check your build status at:
```
https://github.com/YOUR_USERNAME/spotit/actions
```

Add a badge to your README:
```markdown
![iOS Build](https://github.com/YOUR_USERNAME/spotit/workflows/Build%20iOS%20IPA/badge.svg)
```

---

## 💡 Pro Tips

1. **Keep builds small** - Remove unused dependencies to speed up builds
2. **Use release mode** - Always build with `--release` for better performance
3. **Monitor build minutes** - GitHub gives 2000 free minutes/month for macOS runners
4. **Cache dependencies** - The workflow already caches Flutter SDK
5. **Set up notifications** - Get email alerts when builds complete

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Sideloadly Official Site](https://sideloadly.io/)
- [Sideloadly FAQ](https://sideloadly.io/#faq)

---

## ✅ Quick Checklist

- [ ] Code pushed to GitHub
- [ ] GitHub Actions workflow running
- [ ] Build completed successfully
- [ ] IPA downloaded from Artifacts
- [ ] Sideloadly installed
- [ ] iPhone connected via USB
- [ ] IPA installed with Sideloadly
- [ ] Developer certificate trusted on iPhone
- [ ] Backend URL configured
- [ ] Backend server running
- [ ] App tested and working

---

Enjoy your music! 🎵
