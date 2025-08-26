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
echo 2. Setting up React frontend with Vite...
cd ..\frontend

echo Installing Node.js dependencies...
npm install
if %errorlevel% neq 0 (
    echo Error installing Node.js dependencies
    pause
    exit /b 1
)

cd ..

echo.
echo ✅ Setup complete! Your React + Vite application is ready!
echo.
echo Next steps:
echo 1. Get a Gemini API key from: https://makersuite.google.com/app/apikey
echo 2. Copy backend\.env.example to backend\.env
echo 3. Add your API key to backend\.env
echo 4. Run start.bat to launch the application
echo.
echo Features:
echo • Lightning-fast development with Vite
echo • Hot Module Replacement (HMR)
echo • Optimized build process
echo • Modern React development experience
echo.
pause
