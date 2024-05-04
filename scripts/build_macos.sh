#!/bin/zsh
APP_EN_NAME="ExifHelper"
APP_CH_NAME="Exif小助手"
app="$(pwd)/build/macos/Build/Products/Release/exif_helper.app"
tmp="$(pwd)/tmp"
release="$(pwd)/release"
## Install create-dmg
#if [[ ! -x "$(command -v create-dmg)" ]]; then
#  brew install create-dmg
#fi
## Create release directory
#if [[ ! -d "$(pwd)/release" ]]; then
#  mkdir "$(pwd)/release"
#fi
## Cleanup
#rm -rf "$(pwd)/release/*"
#flutter clean
## Build MacOS
#flutter pub get
#flutter build macos
#if [[ ! -d $app ]]; then
#	exit 1
#fi

# Declare Packaging
function packaging() {
  if [[ ! -d $tmp ]]; then
     mkdir $tmp
  fi
  cp -r $app $tmp/
  mv $tmp/exif_helper.app $tmp/$1.app
  ln -s /Applications $tmp/Applications
  hdiutil create -srcfolder $tmp/ $release/$1.dmg
  rm -rf $tmp
}
# Packaging English version
packaging $APP_EN_NAME
# Packaging Chinese version
packaging $APP_CH_NAME