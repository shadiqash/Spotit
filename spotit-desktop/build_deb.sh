#!/bin/bash

# Exit on error
set -e

echo "Building Spotit for Linux..."
flutter build linux --release

echo "Preparing DEB package..."
# Clean previous build
rm -rf debian/usr/lib/spotit/*

# Copy build artifacts
cp -r build/linux/x64/release/bundle/* debian/usr/lib/spotit/

# Create symlink script
cat > debian/usr/bin/spotit << EOL
#!/bin/bash
/usr/lib/spotit/spotit "\$@"
EOL

chmod +x debian/usr/bin/spotit

# Set permissions
chmod -R 755 debian/DEBIAN
chmod -R 755 debian/usr

# Build package
dpkg-deb --build debian spotit_1.0.0_amd64.deb

echo "Build complete! Package saved as spotit_1.0.0_amd64.deb"
echo "To install: sudo dpkg -i spotit_1.0.0_amd64.deb"
