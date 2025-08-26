@echo off
echo ========================================
echo   AI Finance Assistant Flutter App
echo ========================================
echo.
echo Please choose a platform:
echo 1. Windows Desktop
echo 2. Android Emulator
echo 3. Web Browser
echo 4. Check available devices
echo.
set /p choice="Enter your choice (1-4): "

cd /d "%~dp0frontend"

if "%choice%"=="1" goto windows
if "%choice%"=="2" goto android
if "%choice%"=="3" goto web
if "%choice%"=="4" goto devices
goto invalid

:windows
echo.
echo Starting on Windows Desktop...
echo Note: Make sure Windows Developer Mode is enabled
echo (run: start ms-settings:developers)
flutter run -d windows
goto end

:android
echo.
echo Starting on Android Emulator...
echo Checking available emulators...
flutter emulators
echo.
flutter emulators --launch Pixel_9_Pro_Fold
echo Waiting for emulator to start...
timeout /t 10 /nobreak > nul
flutter run
goto end

:web
echo.
echo Starting in Web Browser...
flutter run -d chrome
goto end

:devices
echo.
echo Available devices:
flutter devices
echo.
echo Available emulators:
flutter emulators
goto end

:invalid
echo Invalid choice. Please run the script again.
goto end

:end
echo.
pause
