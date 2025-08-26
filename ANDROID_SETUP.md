# Android Emulator Setup Guide

## Quick Start
Run the Flutter app on Android emulator:
```bash
cd frontend
flutter emulators --launch Pixel_9_Pro_Fold
flutter run
```

## Available Scripts
- `start_flutter_android.bat` - Launch on Android emulator specifically
- `start_flutter.bat` - Interactive launcher with platform choice

## Troubleshooting

### Emulator Issues
1. **Emulator won't start:**
   - Check if Android Studio is installed
   - Verify ANDROID_HOME environment variable
   - Try: `flutter doctor` to check setup

2. **"Android emulator exited with code 1":**
   - Emulator might already be running
   - Check Task Manager for "qemu" processes
   - Try closing and restarting

3. **No emulators found:**
   ```bash
   # Create a new emulator
   flutter emulators --create
   ```

### Build Issues
1. **Gradle build fails:**
   - Make sure Android SDK is properly installed
   - Run: `flutter clean && flutter pub get`

2. **Dependencies not found:**
   - Ensure internet connection
   - Try: `flutter pub get --verbose`

### Performance Tips
1. **Speed up emulator:**
   - Enable Hardware Acceleration (HAXM/Hyper-V)
   - Allocate more RAM in AVD Manager
   - Use x86_64 system images

2. **Hot reload:**
   - Press `r` to hot reload
   - Press `R` to hot restart
   - Press `q` to quit

## Alternative: Physical Device
Connect Android device via USB:
1. Enable Developer Options on device
2. Enable USB Debugging
3. Run: `flutter devices` to verify connection
4. Run: `flutter run` (will auto-detect device)

## Emulator Commands
```bash
# List all emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>

# Create new emulator
flutter emulators --create --name MyEmulator

# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```
