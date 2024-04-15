#!/bin/bash
# Create release directory
if [ ! -d "$(pwd)/release" ]; then
  mkdir "$(pwd)/release"
fi
chmod 755 "$(pwd)/release"
# Cleanup
rm -rf "$(pwd)/release/*"
flutter clean
# Build Linux
flutter pub get
flutter build linux
# Compress English version
tar -czvf ExifHelper.tar.gz -C build/linux/x64/release/bundle .
mv ExifHelper.tar.gz release/
if [ -f "$(pwd)/release/ExifHelper.tar.gz" ]; then
  echo "ExifHelper.tar.gz created successfully"
else
  echo "ExifHelper.tar.gz creation failed"
fi
# Compress Chinese version
tar -czvf Exif小助手.tar.gz -C build/linux/x64/release/bundle .
mv Exif小助手.tar.gz release/
if [ -f "$(pwd)/release/Exif小助手.tar.gz" ]; then
  echo "Exif小助手.tar.gz created successfully"
else
  echo "Exif小助手.tar.gz creation failed"
fi

