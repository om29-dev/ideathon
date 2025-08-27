# 🤖 AI Finance Assistant

> **A complete AI-powered personal finance management application with Flutter frontend and FastAPI backend**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com/)
[![Google Gemini](https://img.shields.io/badge/Google_Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)

## ✨ Features

- 🎯 **AI-Powered Chat Assistant** - Get personalized financial advice using Google Gemini AI
- 📊 **Expense Tracking** - Automatic expense detection and categorization
- 📈 **NIFTY 50 Integration** - Real-time stock market data and trends
- 📱 **Cross-Platform** - Works on Web, Android, iOS, Windows, macOS, and Linux
- 🌙 **Dual Themes** - Beautiful green light theme and purple dark theme
- 🔔 **Smart Notifications** - Daily financial tips and reminders
- 📋 **Export Data** - Download your financial data as Excel/CSV files
- 💰 **Budget Management** - Track income, expenses, and savings goals

## 🏗️ Project Structure

```
ideathon/
├── backend/                    # FastAPI Python backend
│   ├── main.py                # Main FastAPI application
│   ├── config.py              # Configuration settings
│   ├── requirements.txt       # Python dependencies
│   ├── tips/                  # Daily tips service
│   │   └── service.py         # Gemini AI tip generation
│   └── data/                  # Data storage
│       └── daily_tip_cache.json
│
├── frontend/                   # Flutter mobile/web app
│   ├── lib/
│   │   ├── main.dart          # Main Flutter application
│   │   ├── models/            # Data models
│   │   ├── providers/         # State management
│   │   ├── screens/           # UI screens
│   │   ├── widgets/           # Reusable UI components
│   │   ├── services/          # API and notification services
│   │   └── src/               # Helper utilities
│   ├── pubspec.yaml           # Flutter dependencies
│   ├── android/               # Android-specific configuration
│   ├── web/                   # Web-specific configuration
│   └── windows/               # Windows-specific configuration
│
├── Generated Data/            # Sample data files
├── setup.bat                 # Windows setup script
├── start.bat                 # Complete application launcher
├── start_backend.bat         # Backend-only launcher
├── start_flutter.bat         # Frontend-only launcher
└── README.md                 # This file
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/om29-dev/ideathon.git
   cd ideathon
   ```

2. **Run the setup script**
   ```cmd
   setup.bat
   ```

3. **Start the application**
   ```cmd
   start.bat
   ```

The app will be available at:
- **Web**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

### Option 2: Manual Setup

#### Prerequisites

- **Python 3.8+** - [Download Python](https://python.org/downloads/)
- **Flutter 3.8.1+** - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Git** - [Download Git](https://git-scm.com/downloads)
- **Google Gemini API Key** - [Get API Key](https://ai.google.dev/)

#### Backend Setup

1. **Navigate to backend directory**
   ```cmd
   cd backend
   ```

2. **Create virtual environment**
   ```cmd
   python -m venv venv
   venv\Scripts\activate
   ```

3. **Install dependencies**
   ```cmd
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```cmd
   # Create .env file or set environment variable
   set GEMINI_API_KEY=your_gemini_api_key_here
   ```

5. **Start the backend server**
   ```cmd
   python main.py
   ```

#### Frontend Setup

1. **Navigate to frontend directory**
   ```cmd
   cd frontend
   ```

2. **Get Flutter dependencies**
   ```cmd
   flutter pub get
   ```

3. **Run on different platforms**

   **Web (Recommended for development):**
   ```cmd
   flutter run -d web-server --web-port=3000
   ```

   **Android (requires Android Studio/emulator):**
   ```cmd
   flutter run -d android
   ```

   **Windows (requires Visual Studio):**
   ```cmd
   flutter run -d windows
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the `backend/` directory:

```env
GEMINI_API_KEY=your_google_gemini_api_key
DEBUG=true
HOST=0.0.0.0
PORT=8000
```

### Flutter Configuration

Update `frontend/lib/main.dart` if needed to change backend URL for different platforms.

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| 🌐 Web | ✅ Fully Supported | Recommended for development |
| 🤖 Android | ✅ Fully Supported | Requires Android Studio |
| 🍎 iOS | ✅ Supported | Requires Xcode (macOS only) |
| 🪟 Windows | ✅ Supported | Requires Visual Studio |
| 🐧 Linux | ✅ Supported | Native Linux support |
| 🍎 macOS | ✅ Supported | Native macOS support |

## 🎨 Themes

The app features two beautiful themes:

- **🌿 Light Theme**: Green-based color scheme for a fresh, modern look
- **🌙 Dark Theme**: Purple-based color scheme for comfortable night usage

Switch themes using the theme toggle button in the app header.

## 📋 Features in Detail

### 🤖 AI Chat Assistant
- Powered by Google Gemini AI
- Personalized financial advice
- Expense analysis and recommendations
- Budget planning assistance
- Investment guidance for students

### 📊 Expense Management
- Automatic expense detection from chat
- Category-based organization
- Monthly/yearly summaries
- Export to Excel/CSV formats

### 📈 Market Integration
- Real-time NIFTY 50 data
- Stock market trends
- Investment insights

### 🔔 Smart Notifications
- Daily financial tips
- Budget reminders
- Goal tracking alerts
- Customizable notification preferences

## 🚀 Deployment

### Backend Deployment (Heroku/Railway/DigitalOcean)

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY backend/requirements.txt .
RUN pip install -r requirements.txt

COPY backend/ .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Frontend Deployment (Netlify/Vercel)

```cmd
cd frontend
flutter build web
# Deploy the build/web folder to your hosting service
```

## 🛠️ Development

### Adding New Features

1. **Backend**: Add new endpoints in `backend/main.py`
2. **Frontend**: Create new screens in `frontend/lib/screens/`
3. **Models**: Add data models in `frontend/lib/models/`
4. **Services**: Add services in `frontend/lib/services/`

### Code Style

- **Python**: Follow PEP 8 guidelines
- **Dart/Flutter**: Follow official Dart style guide
- **Linting**: Use `flutter analyze` for Flutter code

## 🔍 API Documentation

Once the backend is running, visit http://localhost:8000/docs for interactive API documentation powered by FastAPI's automatic OpenAPI generation.

### Key Endpoints

- `GET /health` - Health check
- `POST /chat` - Send message to AI assistant
- `GET /daily-tip` - Get daily financial tip
- `POST /daily-tip` - Get category-specific tip
- `GET /download/csv` - Export data as CSV
- `POST /import-messages` - Import chat history

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

### Common Issues

**1. Backend won't start**
- Check if Python 3.8+ is installed
- Verify all dependencies are installed: `pip install -r requirements.txt`
- Ensure GEMINI_API_KEY is set

**2. Flutter build issues**
- Run `flutter clean && flutter pub get`
- Check Flutter version: `flutter --version`
- For Android: Ensure Android SDK is installed

**3. API connection issues**
- Verify backend is running on http://localhost:8000
- Check firewall settings
- For mobile: Use correct IP address (not localhost)

### Getting Help

- 📧 Email: [your-email@domain.com]
- 💬 Discord: [Your Discord Server]
- 🐛 Issues: [GitHub Issues](https://github.com/om29-dev/ideathon/issues)

## 🙏 Acknowledgments

- [Google Gemini AI](https://ai.google.dev/) for powerful AI capabilities
- [Flutter Team](https://flutter.dev/) for the amazing cross-platform framework
- [FastAPI](https://fastapi.tiangolo.com/) for the modern Python web framework
- NIFTY 50 data providers for market integration

---

<div align="center">
  <p>Made with ❤️ for financial empowerment</p>
  <p>⭐ Star this repo if you found it helpful!</p>
</div>

### Automatic Setup (Windows)

1. Get a Gemini API key:
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key

2. Create `.env` file in the `backend` directory:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   ```

3. Run the setup script:
   ```cmd
   setup.bat
   ```
   This will:
   - Create a Python virtual environment
   - Install backend dependencies
   - Install frontend dependencies

4. Start the application:
   ```cmd
   start.bat
   ```
   This will:
   - Start the backend server
   - Start the frontend development server

The frontend will be available at `http://localhost:3000` and the backend at `http://localhost:8003`

### Manual Setup

#### Backend Setup

1. Navigate to the backend directory:
   ```cmd
   cd backend
   ```

2. Create a virtual environment:
   ```cmd
   python -m venv venv
   venv\Scripts\activate
   ```

3. Install dependencies:
   ```cmd
   pip install -r requirements.txt
   ```

4. Create `.env` file with your Gemini API key:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   ```

5. Run the backend server:
   ```cmd
   python main.py
   ```

#### Frontend Setup

1. Navigate to the frontend directory:
   ```cmd
   cd frontend
   ```

2. Install dependencies:
   ```cmd
   npm install
   ```

3. Start the development server:
   ```cmd
   npm start
   ```

## API Endpoints

- `GET /` - Root endpoint
- `GET /health` - Health check and API configuration status
- `POST /chat` - Send message to Gemini AI and process expenses
- `GET /download_excel/{filename}` - Download generated Excel file

### Chat Request Format
```json
{
  "message": "Your question here",
  "max_tokens": 1000,
  "temperature": 0.7
}
```

### Chat Response Format
```json
{
  "response": "AI generated response",
  "status": "success",
  "has_expenses": true,
  "excel_data": "base64_encoded_excel_data"
}
```

## Features

- 🤖 Integration with Google's Gemini AI
- 💬 Real-time chat interface
- 📊 Automatic expense tracking and categorization
- 📑 Excel report generation from conversation
- 💸 Multiple currency format detection (₹, $, Rs.)
- 📋 Smart expense categorization
- 📅 Automatic date assignment for expenses
- ⬇️ One-click Excel report downloads
- 🎨 Modern, responsive UI design
- 📱 Mobile-friendly layout
- ⚡ Fast API backend with automatic documentation
- 🔄 Connection status indicators
- 📜 Message history
- 🛡️ Error handling and validation
- 🔔 **Daily Tip Notifications** - Receive personalized finance tips every day at 9 AM
- 💡 **Smart Tip Generation** - AI-powered tips based on different categories (saving, budgeting, investing)
- 🧪 **Test Notifications** - Try out notifications instantly with the test button
- 📲 **Background Scheduling** - Uses Android WorkManager for reliable daily notifications

## Technologies Used

### Backend
- **FastAPI** - Modern Python web framework
- **Google Generative AI** - Gemini API integration
- **Pandas** - Data manipulation and Excel generation
- **OpenPyXL** - Excel file creation
- **Uvicorn** - ASGI server
- **Pydantic** - Data validation

### Frontend
- **React** - UI framework
- **Axios** - HTTP client for data fetching and file downloads
- **CSS3** - Modern styling with gradients and animations

## Expense Tracking Features

### Supported Input Formats
- **Currency symbols**: ₹, $, Rs., rupees
- **Amount phrases**: "amount was", "cost", "paid", "spent", "for"
- **Time references**: "yesterday", "today", "last week"
- **Purchase verbs**: "bought", "purchased", "ate at", "went to"

### Excel Report Features
- **Date column** - Automatically determined from context
- **Description** - Extracted from the conversation
- **Amount** - Extracted and standardized
- **Category** - Auto-categorized into:
  - Food & Dining
  - Transportation
  - Personal Items
  - Healthcare
  - Entertainment
  - Other
- **Professional formatting** with headers and totals
- **Auto-sized columns** for better readability

## Development

### Running in Development Mode

1. Start the backend (runs on port 8003):
   ```cmd
   cd backend
   venv\Scripts\activate
   python main.py
   ```

2. Start the frontend (runs on port 3000):
   ```cmd
   cd frontend
   npm start
   ```

### Building for Production

1. Build the React app:
   ```cmd
   cd frontend
   npm run build
   ```

2. The backend can serve static files or you can deploy them separately.

## 🚀 Deployment

Multiple deployment options are available for the AI Finance Assistant:

### Quick Deployment Options

1. **GitHub Pages** (Frontend only)
   ```bash
   ./deploy.bat  # Windows
   ./deploy.sh   # Linux/Mac
   ```

2. **Railway** (Recommended - Full stack)
   - Connect GitHub repo to Railway
   - Deploy frontend and backend separately
   - Set `GEMINI_API_KEY` environment variable

3. **Docker Compose** (Local/VPS)
   ```bash
   docker-compose up --build -d
   ```

4. **Vercel + Railway**
   - Frontend on Vercel (Edge deployment)
   - Backend on Railway (Database support)

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

### Environment Variables for Production

#### Frontend
```env
VITE_API_URL=https://your-backend-url.com
```

#### Backend
```env
GEMINI_API_KEY=your_gemini_api_key_here
PORT=8000
CORS_ORIGINS=https://your-frontend-url.com
```

## Environment Variables

### Backend (.env)
- `GEMINI_API_KEY` - Your Google Gemini API key (required)
- `DEBUG` - Enable debug mode (optional)

## Example Expense Statements

Try these examples in the chat to test the expense tracking:

```
Yesterday I ate at a hotel for ₹200 and bought an umbrella for ₹300
```

```
Today I spent ₹150 on groceries, ₹50 on bus transport, and ₹80 on medicine
```

```
I paid $25 for lunch, bought clothes for ₹500, and spent 100 rupees on a movie ticket
```

```
Last week I went to the restaurant and the amount was ₹450, then I purchased a new shirt for ₹800, and got an Uber for ₹120
```

## How to Use Expense Tracking

1. **Chat naturally** about your expenses
2. **Wait for the AI to process** your expense information
3. **Click "Download Excel Report"** when it appears
4. **Open the Excel file** to view your formatted expense report

## Daily Tip Notifications

The app features an intelligent daily tip notification system to help you build better financial habits:

### How to Enable
1. Open the **Profile** menu (person icon in the top right)
2. Toggle **"Daily Tip Notifications"** to ON
3. Grant notification permission when prompted
4. Test immediately with the **"Test Notification"** button

### Features
- 📅 **Daily Schedule**: Automatically delivers tips at 9:00 AM every day
- 🤖 **AI-Powered Tips**: Uses Google Gemini to generate personalized finance advice
- 🎯 **Varied Categories**: Different tip types each day (saving, budgeting, investing, expense tracking)
- 💾 **Smart Caching**: Tips are cached daily to ensure consistency and reduce API calls
- 🔄 **Fallback System**: Works even when offline with pre-defined helpful tips
- ⚙️ **Background Processing**: Uses Android WorkManager for reliable delivery
- 🧪 **Instant Testing**: Test notifications immediately to see how they work

### Example Tips You Might Receive
- "Save ₹50 daily to have ₹18,250 in a year! Small habits matter."
- "Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings."
- "Track every expense for a week to understand your spending patterns."
- "Start a SIP with just ₹500 monthly to begin your investment journey."

### Technical Details
- **Backend API**: `/daily-tip` endpoint provides cached tips
- **Flutter Service**: `NotificationService` handles scheduling and permissions
- **Android Permissions**: Uses `POST_NOTIFICATIONS` and `WAKE_LOCK`
- **Scheduling**: Workmanager handles background task execution
- **Fallback**: 10+ pre-written tips available when AI is unavailable

## Troubleshooting

1. **Backend not starting**: Check if Python and pip are installed correctly
2. **API key errors**: Ensure your Gemini API key is valid and properly set in `.env`
3. **CORS issues**: The backend is configured to allow localhost:3000, adjust if needed
4. **Frontend not connecting**: Ensure backend is running on port 8003
5. **Excel not downloading**: Check browser's download settings and permissions

## License

This project is for educational and demonstration purposes.
