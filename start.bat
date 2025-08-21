@echo off
echo Starting Gemini Chat Application...
echo.

echo Starting backend server...
start "Backend Server" cmd /c "cd backend && venv\Scripts\activate && python main.py"

echo Waiting for backend to start...
timeout /t 3 /nobreak > nul

echo Starting frontend development server...
start "Frontend Server" cmd /c "cd frontend && npm start"

echo.
echo ✅ Application is starting...
echo.
echo Backend: http://localhost:8004
echo Frontend: http://localhost:3000
echo.
echo Press any key to exit...
pause > nul
pause > nul
