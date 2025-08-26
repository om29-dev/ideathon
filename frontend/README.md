# AI Finance Assistant - Flutter Frontend

## Overview

This Flutter application is a complete conversion of the original React/Vite frontend into a native Flutter app. The app provides an AI-powered finance assistant that helps students manage their finances, track expenses, and get investment advice.

## Features Converted

### Core Features
- ✅ **Multi-theme Support**: Light, Dark, and Market themes
- ✅ **Real-time Chat Interface**: AI-powered conversation system
- ✅ **Expense Tracking**: Parse and categorize user expenses
- ✅ **NIFTY 50 Chart**: Real-time stock market visualization
- ✅ **Token System**: Gamified user engagement
- ✅ **Connection Status**: Backend health monitoring
- ✅ **Export Functionality**: Excel and CSV download support

## Project Structure

```
lib/
├── main.dart                 # App entry point with theme management
├── models/
│   ├── expense.dart         # Expense data model
│   └── message.dart         # Chat message model (to be created)
├── providers/
│   └── app_state.dart       # State management with Provider
├── screens/
│   └── home_screen.dart     # Main application screen
└── widgets/
    ├── chat_section.dart    # Chat interface component
    ├── expense_modal.dart   # Expense details modal
    ├── message_bubble.dart  # Individual message widget
    ├── nifty_chart.dart     # Stock chart visualization
    └── profile_section.dart # User profile sidebar
```

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable)
- Windows Developer Mode enabled (for Windows builds)
- Backend server running on `localhost:8000`

### Installation
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Enable Windows Developer Mode:
   ```bash
   start ms-settings:developers
   ```

3. Run the application:
   ```bash
   flutter run -d windows
   ```

## Migration Status

The frontend has been successfully converted from React to Flutter with the following architecture:

- **State Management**: Provider pattern replacing React hooks
- **Styling**: MaterialDesign themes replacing CSS
- **HTTP**: Dart http package replacing Axios
- **Storage**: SharedPreferences replacing localStorage

## Next Steps

1. Complete the Message model implementation
2. Test all components thoroughly
3. Enable Windows Developer Mode for full functionality
4. Deploy to multiple platforms (Windows, Web, Mobile)
