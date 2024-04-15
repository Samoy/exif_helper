#!/bin/bash
# Create release directory
if [ ! -d "$(pwd)/release" ]; then
  mkdir "$(pwd)/release"
fi
chmod 755 "$(pwd)/release"
# Cleanup
rm -rf "$(pwd)/release"
flutter clean
# Build APK
flutter pub get
flutter build apk --target-platform=android-arm64
# Copy APKs
cp "$(pwd)"/build/app/outputs/flutter-apk/app-release.apk "$(pwd)"/release/ExifHelper.apk
cp "$(pwd)"/build/app/outputs/flutter-apk/app-release.apk "$(pwd)"/release/Exif小助手.apk