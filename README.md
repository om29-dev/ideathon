# 🤖 AI Finance Assistant

> AI-powered personal finance assistant with a Flutter frontend and FastAPI backend.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com/)

One-line TL;DR

- Flutter app (web + mobile + desktop) that talks to a FastAPI backend which uses Google Gemini to provide AI-driven finance tips and chat-based expense tracking.

Why this README was updated

- This repo ships a Flutter frontend. Previous docs referenced Node/React; those steps have been removed. Use `setup.bat` on Windows for automated setup.

## ✨ Key features

- AI chat assistant (Google Gemini) for financial guidance
- Expense detection and categorization
- Export data to CSV/Excel
- Cross-platform Flutter frontend (Web, Android, iOS, Windows, macOS, Linux)
- Daily tips and smart notifications

## Project layout (important files)

```
ideathon/
├── backend/                 # FastAPI backend (Python)
│   ├── main.py
│   ├── config.py
│   └── requirements.txt
├── frontend/                # Flutter app
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
├── setup.bat                # Windows automated setup script
├── start.bat                # Launch both backend and frontend (Windows)
└── README.md
```

## Quick start (Windows)

Recommended: use the automated script which creates a Python venv, installs backend packages, and runs `flutter pub get` for the frontend when Flutter/Dart is available.

1. Clone the repo and open PowerShell in the repo root

```powershell
git clone https://github.com/om29-dev/ideathon.git
cd ideathon
.\setup.bat
```

If everything completes you can run the app with:

```powershell
.\start.bat
```

Notes:
- `setup.bat` expects Python (for the backend) and Flutter or Dart (for fetching frontend packages). It no longer tries to run npm.
- If you prefer manual setup, see the sections below.

## Manual setup

Prerequisites

- Python 3.8+
- Flutter SDK (for frontend)
- Git
- A Google Gemini API key

Backend (manual)

```powershell
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
set GEMINI_API_KEY=your_gemini_api_key_here
python main.py
```

Frontend (manual)

```powershell
cd frontend
flutter pub get
# Example: run web-server on port 3000
flutter run -d web-server --web-port=3000
```

## Configuration

- Create `backend/.env` or set `GEMINI_API_KEY` in your environment. Example `.env` contents:

```
GEMINI_API_KEY=your_google_gemini_api_key
DEBUG=true
HOST=0.0.0.0
PORT=8000
```

Change the backend URL in `frontend/lib/main.dart` if you need to point the app to a different host/port when running on device.

## Running locally

- Backend API: http://localhost:8000 (default)
- API docs: http://localhost:8000/docs
- Flutter web (if run with web-server): http://localhost:3000

## Troubleshooting

- Backend fails to start: ensure Python 3.8+, install requirements, and set `GEMINI_API_KEY`.
- Flutter issues: run `flutter clean && flutter pub get`, check `flutter --version`, and ensure required platform tools are installed.

## Contributing

- Fork, create a branch, make changes, open a PR. See GitHub issues for discussions.

## License

This project is licensed under the MIT License — see `LICENSE`.

---

If you'd like, I can also trim other docs that still mention React/Vite or add a short Windows Flutter install link. Which would you prefer?
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
