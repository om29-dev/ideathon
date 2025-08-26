@echo off
echo ========================================
echo   Starting Backend with Virtual Environment
echo ========================================
echo.

cd /d "%~dp0backend"

echo [1/3] Checking Python Virtual Environment...
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo Error: Failed to create virtual environment
        echo Make sure Python is installed and in PATH
        pause
        exit /b 1
    )
)

echo [2/3] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo Error: Failed to activate virtual environment
    pause
    exit /b 1
)

echo [3/3] Installing dependencies...
if exist "requirements.txt" (
    pip install -r requirements.txt
) else (
    echo Installing essential dependencies...
    pip install fastapi uvicorn python-multipart google-generativeai python-dotenv pandas openpyxl
)

echo.
echo ✅ Starting FastAPI Backend Server...
echo.
echo Server will be available at: http://localhost:8000
echo Health check: http://localhost:8000/health
echo API docs: http://localhost:8000/docs
echo.

python main.py

echo.
echo Backend server stopped.
pause
