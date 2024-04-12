#!/bin/bash
# Setup Apk name
ENGLISH_NAME="ExifHelper"
CHINESE_NAME="Exif小助手"

# Create release directory
if [ ! -d "$(pwd)/release" ]; then
  mkdir "$(pwd)/release"
fi

# Build APK
flutter clean
flutter pub get
flutter build apk --split-per-abi

# Copy APKs
for abi in  "$(pwd)"/build/app/outputs/flutter-apk/*.apk
do
  mv "$abi" "${abi/app-/${ENGLISH_NAME}-}"
done
for abi in  "$(pwd)"/build/app/outputs/flutter-apk/*.apk
do
  cp "$abi" "${abi/${ENGLISH_NAME}-/${CHINESE_NAME}-}"
done
for abi in  "$(pwd)"/build/app/outputs/flutter-apk/*.apk
do
  cp "$abi" "$(pwd)/release/"
done