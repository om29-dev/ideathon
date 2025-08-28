# 🤖 AI Finance Assistant

> Complete personal finance management app with AI chat assistant and expense tracking.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com/)

**Flutter app with AI-powered finance features:** expense tracking, investment portfolio, analytics, and Google Gemini chat assistant.

## 🚀 Quick Start

**Windows (Recommended):**
```bash
git clone https://github.com/om29-dev/ideathon.git
cd ideathon
.\setup.bat    # Installs everything
.\start.bat    # Runs both frontend and backend
```

**Manual Setup:**
```bash
# Backend (Python 3.8+)
cd backend && python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
set GEMINI_API_KEY=your_api_key
python main.py

# Frontend (Flutter)
cd frontend
flutter pub get
flutter run -d web-server --web-port=3000
```

## ✨ Features

**📱 Complete Finance App:**
- Beautiful dashboard with spending analytics
- **SMS expense auto-import** - Automatically extracts expenses from bank SMS
- Expense tracking with receipt scanning
- Investment portfolio management
- AI chat assistant (Google Gemini)
- **Daily tip notifications** at 9 AM with AI-generated advice
- Export reports (Excel/CSV)

**🤖 Smart Automation:**
- Auto-categorizes SMS transactions
- AI-powered financial insights
- Intelligent expense detection from messages
- Background notification scheduling

**🎨 Modern UI:**
- Material Design 3
- Responsive (mobile/tablet/desktop)
- Dark/light themes
- Smooth animations

## 🌐 Access

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs

## � Requirements

- Python 3.8+
- Flutter SDK
- Google Gemini API key

## ⚙️ Configuration

Create `backend/.env`:
```env
GEMINI_API_KEY=your_api_key_here
```

## 🚀 Deployment

Ready for deployment on Railway, Vercel, or any cloud platform. See `FEATURES.md` for complete feature documentation.

## 📄 License

MIT License
