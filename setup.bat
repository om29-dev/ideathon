@echo off
echo Setting up Gemini Chat Application...
echo.

echo 1. Setting up Python backend...
cd backend

echo Creating virtual environment...
python -m venv venv
if %errorlevel% neq 0 (
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
echo 2. Setting up React frontend...
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
echo ✅ Setup complete!
echo.
echo Next steps:
echo 1. Get a Gemini API key from: https://makersuite.google.com/app/apikey
echo 2. Copy backend\.env.example to backend\.env
echo 3. Add your API key to backend\.env
echo 4. Run start.bat to launch the application
echo.
pause
