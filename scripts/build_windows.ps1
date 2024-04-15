$CHINESE_NAME='Exif小助手'
$ENGLISHE_NAME='ExifHelper'
$BUILDE_PATH="${pwd}\build\windows\x64\runner\Release"

# Define Clean Function
function Clean
{
    param (
        $path
    )

    if (Test-Path $path)
    {
        Remove-Item -Path $path -Recurse
    }
}

# Create Release Directory
if (Test-Path "${pwd}/release")
{
    Remove-Item -Path "${pwd}/release" -Recurse
}
mkdir "${pwd}/release"
# ======================================= Build EXE and ZIP =============================================
# Set USE_CHINESE_SIMPLIFIED=1 to build Chinese zip version
$env:USE_CHINESE_SIMPLIFIED=1
# Build Chinese version
Clean $BUILDE_PATH
flutter clean
flutter pub get
flutter build windows
# Build EXE
iscc "${pwd}\scripts\build_windows_cn.iss"
# Compress to ZIP
$compress = @{
    Path = "${BUILDE_PATH}\*"
    DestinationPath = "${pwd}\release\${CHINESE_NAME}_windows_x64.zip"
}
if ($env:USE_CHINESE_SIMPLIFIED -eq 1)
{
    Compress-Archive @compress
}
# Remove ENV:USE_CHINESE_SIMPLIFIED
Remove-Item -Path "ENV:USE_CHINESE_SIMPLIFIED"
# Wait 1 second
Start-Sleep 1
# Build English version
Clean $BUILDE_PATH
flutter pub get
flutter build windows
# Build EXE
iscc "${pwd}\scripts\build_windows.iss"
# Compress to ZIP
$compress = @{
    Path = "${BUILDE_PATH}\*"
    DestinationPath = "${pwd}\release\${ENGLISHE_NAME}_windows_x64.zip"
}
Compress-Archive @compress
# ======================================= Build EXE and ZIP =============================================

# ======================================= Build MSIX ============================================
# Build English version
Clean $BUILDE_PATH
flutter pub get
dart run msix:create
Copy-Item -Path "${BUILDE_PATH}\${ENGLISHE_NAME}.msix" -Destination "${pwd}\release\${ENGLISHE_NAME}_windows_x64.msix"
Start-Sleep 1

# Build Chinese version
Clean $BUILDE_PATH
flutter pub get
dart run msix:create -d ${CHINESE_NAME} -n ${CHINESE_NAME}
Copy-Item -Path "${BUILDE_PATH}\${CHINESE_NAME}.msix" -Destination "${pwd}\release\${CHINESE_NAME}_windows_x64.msix"
# ======================================= Build MSIX ============================================