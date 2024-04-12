# ExifHelper

Read or write image exif without internet

## Features
### 💻 Cross Platform  
Support Windows, Linux, Macos, Android and iOS
### 📶 No Internet Required  
Use it without internet, which effectively protects your privacy.
### ✨ Open Source  
The source code is open and free, you can modify it according to your needs.

## Screenshots
<img alt="Android screenshot" src="https://www.samoy.site/exif_helper/screenshot_android.png"  height="400">

## Building

These commands are intended for maintainers only.

### Windows

**Traditional**

```bash
flutter build windows
```


**Local Executable App**

```bash
iscc scripts/build_windows.iss 
```

**Local MSIX App**

```bash
dart run msix:create
```
**Store ready**

```bash
dart run msix:create --store
```

### MacOS

```bash
flutter build macos
```

### Linux


Traditional Linux

```bash
flutter build linux
```

### Android

Traditional APK

```bash
flutter build apk
```

AppBundle for Google Play

```bash
flutter build appbundle
```

### iOS

```bash
flutter build ipa
```
