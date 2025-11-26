# 🍎 iOS Deployment Without a Mac

This guide shows how to deploy your Spotit Flutter app to an iPhone without owning a Mac computer.

## 🎯 Recommended Method: Codemagic CI/CD

Codemagic is a CI/CD platform specifically designed for Flutter apps with a generous free tier.

### Prerequisites

1. ✅ **Apple Developer Account** (free or paid)
2. ✅ **GitHub/GitLab/Bitbucket account** with your code
3. ✅ **iPhone** with iOS 12.0 or higher
4. ✅ **Codemagic account** (free)

---

## Step 1: Prepare Your Apple Developer Account

### Create App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Go to **Security** → **App-Specific Passwords**
4. Click **Generate Password**
5. Name it "Codemagic" and save the password

### Get Your Team ID

1. Go to [developer.apple.com](https://developer.apple.com)
2. Sign in
3. Go to **Membership** section
4. Copy your **Team ID** (10-character code)

---

## Step 2: Configure Your Flutter Project

### Update Bundle Identifier

Edit `ios/Runner.xcodeproj/project.pbxproj` or use a unique identifier:

```bash
# You can search for PRODUCT_BUNDLE_IDENTIFIER in the file
# Change it to something unique like: com.yourname.spotit
```

Or create a `codemagic.yaml` file in your project root:

```yaml
workflows:
  ios-workflow:
    name: iOS Workflow
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      vars:
        BUNDLE_ID: "com.yourname.spotit"
        APP_STORE_CONNECT_ISSUER_ID: your_issuer_id
        APP_STORE_CONNECT_KEY_IDENTIFIER: your_key_id
        APP_STORE_CONNECT_PRIVATE_KEY: your_private_key
        CERTIFICATE_PRIVATE_KEY: your_cert_key
    scripts:
      - name: Set up code signing settings on Xcode project
        script: |
          xcode-project use-profiles
      - name: Get Flutter packages
        script: |
          flutter pub get
      - name: Build ipa for distribution
        script: |
          flutter build ipa --release \
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        apple_id: your_apple_id@email.com
        password: your_app_specific_password
```

---

## Step 3: Set Up Codemagic

### 1. Sign Up

1. Go to [codemagic.io](https://codemagic.io/)
2. Sign up with GitHub/GitLab/Bitbucket
3. Authorize Codemagic to access your repositories

### 2. Add Your App

1. Click **Add application**
2. Select your repository
3. Choose **Flutter App**
4. Codemagic will auto-detect your project

### 3. Configure iOS Code Signing

In Codemagic dashboard:

1. Go to **App settings** → **Code signing**
2. Click **iOS code signing**
3. Choose **Automatic** (Codemagic manages certificates)
4. Enter your Apple Developer credentials:
   - Apple ID
   - App-specific password
   - Team ID

### 4. Configure Build Settings

1. Go to **Build** section
2. Select **iOS** platform
3. Choose build mode: **Release**
4. Enable **Publish to App Store Connect** (optional)

---

## Step 4: Build Your App

### Trigger Build

1. Click **Start new build**
2. Select branch (e.g., `main`)
3. Wait for build to complete (10-20 minutes)

### Download IPA

Once build succeeds:
1. Go to **Builds** section
2. Click on your successful build
3. Download the `.ipa` file

---

## Step 5: Install on Your iPhone

### Method A: TestFlight (Recommended)

If you configured App Store Connect publishing:

1. Open **TestFlight** app on your iPhone
2. You'll receive an invitation email
3. Accept and install the app
4. App updates automatically with each build

### Method B: Direct Installation with Sideloadly

1. **Download Sideloadly:**
   - Visit [sideloadly.io](https://sideloadly.io/)
   - Download for Linux

2. **Install Sideloadly:**
   ```bash
   # Extract and run
   chmod +x Sideloadly
   ./Sideloadly
   ```

3. **Connect iPhone:**
   - Connect via USB
   - Trust computer on iPhone

4. **Install IPA:**
   - Open Sideloadly
   - Drag your `.ipa` file
   - Enter your Apple ID
   - Click **Start**

5. **Trust Certificate:**
   - On iPhone: **Settings** → **General** → **VPN & Device Management**
   - Trust your developer certificate

> **Note:** Free Apple Developer accounts require re-signing every 7 days

### Method C: AltStore (Alternative)

1. **Install AltStore:**
   - Visit [altstore.io](https://altstore.io/)
   - Follow installation instructions

2. **Install IPA:**
   - Open AltStore on iPhone
   - Add `.ipa` file
   - Sign with your Apple ID

---

## 🔧 Alternative: GitHub Actions (Free)

If you prefer GitHub Actions:

### Create `.github/workflows/ios.yml`:

```yaml
name: iOS Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.x'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
    
    - name: Upload IPA
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app
```

Then download the artifact and sign it manually.

---

## 📝 Important Notes

### Backend Configuration

Since your app connects to a backend server:

1. **Update API URL** for production:
   ```dart
   // lib/services/api_service.dart
   static const String baseUrl = 'https://your-production-server.com';
   ```

2. **Deploy backend** to a cloud service:
   - Heroku
   - Railway
   - Render
   - DigitalOcean

### Free vs Paid Apple Developer Account

| Feature | Free | Paid ($99/year) |
|---------|------|-----------------|
| TestFlight | ❌ No | ✅ Yes |
| App Store | ❌ No | ✅ Yes |
| Direct Install | ✅ Yes (7-day limit) | ✅ Yes (1-year) |
| Max Devices | 3 | 100 |

---

## 🚀 Quick Start Checklist

- [ ] Apple Developer account created
- [ ] App-specific password generated
- [ ] Code pushed to GitHub/GitLab
- [ ] Codemagic account created
- [ ] Repository connected to Codemagic
- [ ] iOS code signing configured
- [ ] Build triggered and successful
- [ ] IPA downloaded
- [ ] App installed on iPhone

---

## 🔧 Troubleshooting

### "Provisioning profile error"

**Solution:**
- Use Codemagic's automatic code signing
- Or manually create provisioning profile at developer.apple.com

### "Untrusted Developer"

**Solution:**
- Settings → General → VPN & Device Management
- Trust your developer certificate

### "Build failed"

**Solution:**
- Check build logs in Codemagic
- Ensure bundle identifier is unique
- Verify Apple credentials are correct

### "App crashes on launch"

**Solution:**
- Check backend URL is accessible from iPhone
- Verify all dependencies are included
- Check Xcode logs in Codemagic build output

---

## 💡 Tips

1. **Use TestFlight** if you have a paid developer account - it's the easiest method
2. **Keep builds small** - Remove unused dependencies to speed up builds
3. **Use environment variables** for API URLs to switch between dev/prod
4. **Monitor build minutes** - Free tier has limits (500 min/month on Codemagic)

---

## 📚 Resources

- [Codemagic Documentation](https://docs.codemagic.io/flutter/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [AltStore Guide](https://altstore.io/)
- [Sideloadly Guide](https://sideloadly.io/)

Good luck! 🎵
