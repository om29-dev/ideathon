@echo off
echo ========================================
echo   AI Finance Assistant - Flutter App
echo ========================================
echo.

echo [1/3] Setting up Python Virtual Environment...
cd backend
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing Python dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo Installing basic dependencies...
    pip install fastapi uvicorn python-multipart google-generativeai python-dotenv pandas openpyxl
)

echo [2/3] Starting Python FastAPI Backend...
start "Backend Server" cmd /k "cd /d %cd% && venv\Scripts\activate.bat && python main.py"

cd ..
echo Waiting for backend to start...
timeout /t 5 /nobreak > nul

echo [3/3] Starting Flutter Frontend...
start "Flutter Frontend" cmd /k "cd frontend && flutter run"

echo.
echo ✅ Flutter Application is starting!
echo.
echo Backend: http://localhost:8000
echo Frontend: Will open in Chrome browser
echo.
echo Features enabled:
• AI-powered chat interface with Gemini AI
• Real-time expense tracking and categorization
• Multi-theme support (Light, Dark, Market)
• Token-based gamification system
• Export functionality (Excel/CSV)
• Cross-platform Flutter UI
• Virtual environment isolation
echo.
echo Note: Make sure to set GEMINI_API_KEY in backend/.env file
echo.
echo Press any key to exit...
pause > nul
