#!/bin/bash
ENGLISH_NAME="ExifHelper"
CHINESE_NAME="Exif小助手"
# Create release directory
if [ ! -d "$(pwd)/release" ]; then
  mkdir "$(pwd)/release"
fi
chmod 755 "$(pwd)/release"
# Build APK
flutter clean
flutter pub get
flutter build apk --split-per-abi --verbose
# Copy APKs
for file in "$(pwd)"/build/app/outputs/flutter-apk/*.apk
do
  rename "app-" "$ENGLISH_NAME-" "$file"
done
for file in "$(pwd)"/build/app/outputs/flutter-apk/*.apk
do
  cp "$file" "$(pwd)/release"
  rename "$ENGLISH_NAME-" "$CHINESE_NAME-" "$file"
done
for file in "$(pwd)"/build/app/outputs/flutter-apk/*.apk
do
  cp "$file" "$(pwd)/release"
done
