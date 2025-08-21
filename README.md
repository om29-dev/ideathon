# AI Finance Buddy

A full-stack application using React frontend and FastAPI backend with Google's Gemini AI integration and automatic expense tracking capabilities.

## Project Structure

```
ideathon/
├── backend/
│   ├── main.py              # FastAPI server with Gemini AI & expense tracking
│   ├── requirements.txt     # Python dependencies
│   └── test_server.py       # Server tests
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── App.js          # Main React component
│   │   ├── App.css         # Styles
│   │   ├── index.js        # React entry point
│   │   └── index.css       # Global styles
│   └── package.json        # Node.js dependencies
├── setup.bat               # Setup script for Windows
├── start.bat               # Start script for Windows
└── README.md
```

## Quick Setup with Scripts

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

## Troubleshooting

1. **Backend not starting**: Check if Python and pip are installed correctly
2. **API key errors**: Ensure your Gemini API key is valid and properly set in `.env`
3. **CORS issues**: The backend is configured to allow localhost:3000, adjust if needed
4. **Frontend not connecting**: Ensure backend is running on port 8003
5. **Excel not downloading**: Check browser's download settings and permissions

## License

This project is for educational and demonstration purposes.
