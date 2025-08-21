@echo off
echo 🚀 AI Finance Assistant - Deployment Script
echo ==========================================

echo Select deployment option:
echo 1. GitHub Pages (Frontend only)
echo 2. Docker Compose (Full stack)  
echo 3. Railway/Heroku (Cloud deployment)
echo 4. Build for production

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto github_pages
if "%choice%"=="2" goto docker_compose
if "%choice%"=="3" goto cloud_deploy
if "%choice%"=="4" goto production_build
goto invalid_choice

:github_pages
echo 📦 Building for GitHub Pages...
cd frontend
call npm install
call npm run build
echo ✅ Build complete! Deploy the 'dist' folder to GitHub Pages
goto end

:docker_compose
echo 🐳 Starting with Docker Compose...
docker-compose up --build -d
echo ✅ Application running at:
echo    Frontend: http://localhost:3000
echo    Backend: http://localhost:8000
goto end

:cloud_deploy
echo ☁️ Cloud deployment setup...
echo For Railway:
echo 1. Connect your GitHub repo to Railway
echo 2. Add GEMINI_API_KEY environment variable
echo 3. Deploy both frontend and backend services
echo.
echo For Heroku:
echo 1. Create two apps (frontend and backend)
echo 2. Set buildpacks appropriately  
echo 3. Configure environment variables
goto end

:production_build
echo 🏗️ Building for production...

REM Build frontend
echo Building frontend...
cd frontend
call npm install
call npm run build
cd ..

REM Prepare backend
echo Preparing backend...
cd backend
pip install -r requirements.txt
cd ..

echo ✅ Production build complete!
echo Frontend build: ./frontend/dist
echo Backend ready: ./backend
goto end

:invalid_choice
echo ❌ Invalid choice
pause
exit /b 1

:end
echo.
echo 🎉 Deployment process completed!
pause
