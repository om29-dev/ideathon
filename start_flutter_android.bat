@echo off
echo Starting AI Finance Assistant Flutter App on Android Emulator...
echo.
echo This will:
echo 1. Launch Android emulator if not running
echo 2. Build and run the Flutter app on Android
echo.
cd /d "%~dp0frontend"

echo Checking available emulators...
flutter emulators
echo.

echo Starting emulator if needed...
flutter emulators --launch Pixel_9_Pro_Fold
echo.

echo Building and running Flutter app...
flutter run
echo.
pause
