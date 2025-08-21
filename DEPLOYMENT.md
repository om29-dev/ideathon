# 🚀 AI Finance Assistant - Deployment Guide

This guide covers multiple deployment options for the AI Finance Assistant application.

## 📋 Prerequisites

- Node.js 18+ and npm
- Python 3.9+
- Docker (for containerized deployment)
- Git and GitHub account
- Gemini API key from Google AI Studio

## 🎯 Deployment Options

### 1. GitHub Pages (Frontend Only) 📄

**Best for**: Static demo, portfolio showcase

```bash
# Build and deploy to GitHub Pages
cd frontend
npm install
npm run build

# Enable GitHub Pages in repository settings
# Deploy the 'dist' folder contents
```

**Setup Steps**:
1. Go to GitHub repository → Settings → Pages
2. Select "Deploy from a branch"
3. Choose `gh-pages` branch
4. The GitHub Action will automatically deploy on push to main

### 2. Railway (Recommended) 🚄

**Best for**: Full-stack deployment with database

**Frontend Deployment**:
1. Connect your GitHub repo to Railway
2. Create a new project for frontend
3. Set environment variables:
   ```
   NODE_ENV=production
   ```
4. Railway will auto-deploy on git push

**Backend Deployment**:
1. Create separate Railway project for backend
2. Set environment variables:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   PORT=8000
   ```
3. Update frontend API calls to use Railway backend URL

### 3. Docker Compose (Local/VPS) 🐳

**Best for**: VPS deployment, local development

```bash
# Clone and deploy
git clone https://github.com/om29-dev/ideathon.git
cd ideathon

# Set environment variables
echo "GEMINI_API_KEY=your_api_key_here" > .env

# Deploy with Docker
docker-compose up --build -d

# Access application
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
```

### 4. Vercel + Railway 🌐

**Best for**: Edge deployment with CDN

**Frontend (Vercel)**:
```bash
npm install -g vercel
cd frontend
vercel --prod
```

**Backend (Railway)**:
- Deploy backend to Railway as described above
- Update frontend environment to point to Railway backend

### 5. Netlify + Heroku 🌍

**Frontend (Netlify)**:
```bash
cd frontend
npm run build
# Drag and drop 'dist' folder to Netlify dashboard
```

**Backend (Heroku)**:
```bash
# Create Procfile in backend folder
echo "web: python main.py" > backend/Procfile

# Deploy to Heroku
heroku create your-app-name
git subtree push --prefix backend heroku main
```

## ⚙️ Environment Variables

### Frontend
```env
VITE_API_URL=http://localhost:8000  # Development
VITE_API_URL=https://your-backend.railway.app  # Production
```

### Backend
```env
GEMINI_API_KEY=your_gemini_api_key_here
PORT=8000
CORS_ORIGINS=http://localhost:3000,https://your-frontend.vercel.app
```

## 🔧 Configuration Files

The following files are configured for deployment:

- `.github/workflows/deploy.yml` - GitHub Actions workflow
- `Dockerfile` - Multi-stage Docker build
- `docker-compose.yml` - Local development with Docker
- `nginx.conf` - Nginx reverse proxy configuration
- `railway.json` - Railway deployment configuration

## 🚀 Quick Deploy Commands

### GitHub Pages
```bash
npm run deploy:gh
```

### Railway
```bash
# Push to main branch - auto-deploys
git push origin main
```

### Docker
```bash
# Local deployment
./deploy.bat  # Windows
./deploy.sh   # Linux/Mac
```

### Manual Build
```bash
# Frontend
cd frontend && npm run build

# Backend  
cd backend && pip install -r requirements.txt
```

## 📊 Monitoring & Logs

- **Railway**: Built-in logs and metrics dashboard
- **Vercel**: Analytics and performance monitoring
- **Docker**: Use `docker logs container_name`

## 🔒 Security Considerations

1. **API Keys**: Never commit API keys to repository
2. **CORS**: Configure appropriate origins for production
3. **HTTPS**: Use SSL certificates for production deployments
4. **Rate Limiting**: Implement API rate limiting for production

## 🆘 Troubleshooting

### Common Issues:

**Build Failures**:
- Check Node.js version (requires 18+)
- Verify all dependencies are installed
- Check for syntax errors in code

**API Connection Issues**:
- Verify backend is running and accessible
- Check CORS configuration
- Confirm API endpoints are correct

**Environment Variables**:
- Ensure all required variables are set
- Check variable names (case-sensitive)
- Verify API key is valid

### Getting Help:

1. Check deployment logs for specific errors
2. Verify all environment variables are set correctly
3. Test locally before deploying to production
4. Check the GitHub Issues for common problems

## 📝 Post-Deployment Checklist

- [ ] Frontend loads correctly
- [ ] Backend API is accessible
- [ ] Chat functionality works
- [ ] Excel/CSV download works
- [ ] Expense tracking functions properly
- [ ] Mobile responsiveness verified
- [ ] All themes work correctly

---

🎉 **Your AI Finance Assistant is now deployed and ready to help users manage their finances!**
