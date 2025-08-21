#!/bin/bash

echo "🚀 AI Finance Assistant - Deployment Script"
echo "=========================================="

# Build and deploy options
echo "Select deployment option:"
echo "1. GitHub Pages (Frontend only)"
echo "2. Docker Compose (Full stack)"
echo "3. Railway/Heroku (Cloud deployment)"
echo "4. Build for production"

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "📦 Building for GitHub Pages..."
        cd frontend
        npm install
        npm run build
        echo "✅ Build complete! Deploy the 'dist' folder to GitHub Pages"
        ;;
    2)
        echo "🐳 Starting with Docker Compose..."
        docker-compose up --build -d
        echo "✅ Application running at:"
        echo "   Frontend: http://localhost:3000"
        echo "   Backend: http://localhost:8000"
        ;;
    3)
        echo "☁️  Cloud deployment setup..."
        echo "For Railway:"
        echo "1. Connect your GitHub repo to Railway"
        echo "2. Add GEMINI_API_KEY environment variable"
        echo "3. Deploy both frontend and backend services"
        echo ""
        echo "For Heroku:"
        echo "1. Create two apps (frontend and backend)"
        echo "2. Set buildpacks appropriately"
        echo "3. Configure environment variables"
        ;;
    4)
        echo "🏗️  Building for production..."
        
        # Build frontend
        echo "Building frontend..."
        cd frontend
        npm install
        npm run build
        cd ..
        
        # Prepare backend
        echo "Preparing backend..."
        cd backend
        pip install -r requirements.txt
        cd ..
        
        echo "✅ Production build complete!"
        echo "Frontend build: ./frontend/dist"
        echo "Backend ready: ./backend"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎉 Deployment process completed!"
