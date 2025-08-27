@echo off
echo ========================================
echo   AI Finance Assistant - Initial Setup
echo ========================================
echo.

echo This script will set up your development environment.
echo.
pause

echo [1/4] Setting up Python Virtual Environment...
cd backend
python -m venv venv
if errorlevel 1 (
    echo Error: Failed to create virtual environment
    echo Make sure Python 3.8+ is installed
    pause
    exit /b 1
) else if errorlevel 2 (
    echo Error creating virtual environment
    pause
    exit /b 1
)

echo Activating virtual environment...
call venv\Scripts\activate
if %errorlevel% neq 0 (
    echo Error activating virtual environment
    pause
    exit /b 1
)

echo Installing Python dependencies...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo Error installing Python dependencies
    pause
    exit /b 1
)

echo.
echo 2. Setting up frontend dependencies...
cd ..\frontend

echo Installing Flutter/Dart dependencies for frontend...
where flutter >nul 2>&1
if %errorlevel%==0 (
    echo Found Flutter SDK, running "flutter pub get"...
    flutter pub get
    if %errorlevel% neq 0 (
        echo Error: flutter pub get failed
        pause
        exit /b 1
    )
) else (
    where dart >nul 2>&1
    if %errorlevel%==0 (
        echo Flutter not found, running "dart pub get"...
        dart pub get
        if %errorlevel% neq 0 (
            echo Error: dart pub get failed
            pause
            exit /b 1
        )
    ) else (
        echo Warning: Neither Flutter nor Dart CLI found. Skipping pub get.
        echo Install Flutter or Dart SDK to fetch frontend dependencies.
    )
)

cd ..

echo.
echo ✅ Setup complete! Your Flutter frontend is ready!
echo.
echo Next steps:
echo 1. Get a Gemini API key from: https://makersuite.google.com/app/apikey
echo 2. Copy backend\.env.example to backend\.env
echo 3. Add your API key to backend\.env
echo 4. Run start.bat to launch the application
echo.
echo Features:
echo • Flutter frontend ready
echo • Dart package resolution performed (if Flutter/Dart CLI available)
echo.
pause
