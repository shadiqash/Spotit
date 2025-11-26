#!/bin/bash

# 🍎 Build iOS IPA for Sideloadly
# This script builds an unsigned IPA that you can install with Sideloadly

set -e

echo "🚀 Building iOS IPA for Spotit..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")"

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🔨 Building iOS app (this may take a few minutes)..."
flutter build ios --release --no-codesign

echo ""
echo "📱 Creating IPA file..."

# Clean up any previous build
rm -rf Payload
rm -f spotit.ipa

# Create Payload directory and copy app
mkdir -p Payload
cp -r build/ios/iphoneos/Runner.app Payload/

# Create IPA
zip -r -q spotit.ipa Payload

# Clean up
rm -rf Payload

# Get file size
FILE_SIZE=$(ls -lh spotit.ipa | awk '{print $5}')

echo ""
echo "✅ IPA created successfully!"
echo "📦 File: spotit.ipa"
echo "📏 Size: $FILE_SIZE"
echo ""
echo "🎯 Next steps:"
echo "1. Open Sideloadly on your computer"
echo "2. Connect your iPhone via USB"
echo "3. Drag spotit.ipa into Sideloadly"
echo "4. Enter your Apple ID and click Start"
echo "5. Trust the certificate on your iPhone (Settings → General → VPN & Device Management)"
echo ""
echo "🎵 Enjoy your music!"
