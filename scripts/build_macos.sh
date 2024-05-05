#!/bin/zsh
ORIGIN_NAME="exif_helper"
APP_EN_NAME="ExifHelper"
APP_CH_NAME="Exif小助手"
BACKGROUND_IMAGE="$(pwd)/macos/background.png"
APP_PATH="$(pwd)/build/macos/Build/Products/Release/exif_helper.app"
TMP_DIR="$(pwd)/tmp"
RELEASE_DIR="$(pwd)/release"
# Install create-dmg
if [[ ! -x "$(command -v create-dmg)" ]]; then
  brew install create-dmg
fi
# Create release directory
if [[ ! -d $RELEASE_DIR ]]; then
  mkdir $RELEASE_DIR
fi
# Cleanup
if [ -f $RELEASE_DIR/* ]; then
  rm -rf $RELEASE_DIR/*
fi
flutter clean
# Build MacOS
flutter pub get
flutter build macos
if [[ ! -d $APP_PATH ]]; then
	exit 1
fi

# Declare Packaging
function packaging() {
  if [[ ! -d $TMP_DIR ]]; then
     mkdir $TMP_DIR
  fi
  cp -r $APP_PATH $TMP_DIR
  mv $TMP_DIR/$ORIGIN_NAME.app $TMP_DIR/$1.app
  create-dmg \
    --background $BACKGROUND_IMAGE \
    --window-size 800 480 \
    --icon-size 100 \
    --icon $1.app 250 210 \
    --hide-extension "$1.app" \
    --app-drop-link 610 210 \
    "$RELEASE_DIR/$1.dmg" \
    "$TMP_DIR/$1.app"
    rm -rf $TMP_DIR
}
# Packaging English version
packaging $APP_EN_NAME
# Packaging Chinese version
packaging $APP_CH_NAME