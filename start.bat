@echo off
echo Starting AI Finance Assistant Application...
echo.

echo Starting backend server...
start "Backend Server" cmd /c "cd backend && venv\Scripts\activate && python main.py"

echo Waiting for backend to start...
timeout /t 3 /nobreak > nul

echo Starting frontend with Vite...
start "Vite Frontend Server" cmd /c "cd frontend && npm run dev"

echo.
echo ✅ Application is starting with Vite!
echo.
echo Backend: http://localhost:8000
echo Frontend: http://localhost:3000
echo.
echo Features enabled:
echo • Lightning-fast Hot Module Replacement
echo • Instant code changes reflection
echo • Optimized development experience
echo.
echo Press any key to exit...
pause > nul
