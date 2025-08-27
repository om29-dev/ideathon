import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
// ...existing code...

enum AppTheme { light, dark, market }

enum ConnectionStatus { checking, connected, noApiKey, disconnected }

class AppState extends ChangeNotifier {
  final SharedPreferences _prefs;

  // State variables
  List<Message> _messages = [];
  bool _isLoading = false;
  ConnectionStatus _connectionStatus = ConnectionStatus.checking;
  int _userTokens = 150;
  AppTheme _currentTheme = AppTheme.light;
  List<NiftyDataPoint> _niftyData = [];

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  ConnectionStatus get connectionStatus => _connectionStatus;
  int get userTokens => _userTokens;
  AppTheme get currentTheme => _currentTheme;
  List<NiftyDataPoint> get niftyData => _niftyData;

  AppState(this._prefs) {
    _loadUserData();
    _initializeApp();
  }

  void _loadUserData() {
    _userTokens = _prefs.getInt('user_tokens') ?? 150;
    final themeIndex = _prefs.getInt('current_theme') ?? 0;
    _currentTheme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  void _saveUserData() {
    _prefs.setInt('user_tokens', _userTokens);
    _prefs.setInt('current_theme', _currentTheme.index);
  }

  void _initializeApp() {
    _addWelcomeMessage();
    _generateNiftyData();
    _checkBackendHealth();
  }

  String _backendHost() {
    if (kIsWeb) return 'localhost';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      default:
        return 'localhost';
    }
  }

  String backendBaseUrl() => 'http://${_backendHost()}:8000';

  void _addWelcomeMessage() {
    final welcomeMessage = Message(
      id: 1,
      text:
          "Hello! I'm your AI Finance Assistant powered by Google's Gemini. I'm here to help you manage your finances as a student! 💰\n\n💡 **Features**:\n• Track your daily expenses\n• Get investment advice for students\n• Learn about SIP and stock market basics\n• Set financial goals\n\nTry saying: 'I spent ₹150 on books and ₹80 on snacks today'",
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      hasExpenses: false,
    );
    _messages.add(welcomeMessage);
    notifyListeners();
  }

  void _generateNiftyData() {
    _niftyData.clear();
    double value = 18500;
    for (int i = 0; i < 20; i++) {
      value += (0.5 - (i % 2)) * 100 + (i * 2);
      final hour = 9 + (i ~/ 4);
      final minute = (i % 4) * 15;
      final timeString =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      _niftyData.add(NiftyDataPoint(time: timeString, value: value.round()));
    }
    notifyListeners();
  }

  Future<void> _checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('${backendBaseUrl()}/health'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['gemini_configured'] == true) {
          _connectionStatus = ConnectionStatus.connected;
        } else {
          _connectionStatus = ConnectionStatus.noApiKey;
        }
      } else {
        _connectionStatus = ConnectionStatus.disconnected;
      }
    } catch (e) {
      _connectionStatus = ConnectionStatus.disconnected;
    }
    notifyListeners();
  }

  void cycleTheme() {
    final themes = AppTheme.values;
    final currentIndex = themes.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % themes.length;
    _currentTheme = themes[nextIndex];
    _saveUserData();
    notifyListeners();
  }

  String getThemeIcon() {
    switch (_currentTheme) {
      case AppTheme.light:
        return '☀️';
      case AppTheme.dark:
        return '🌙';
      case AppTheme.market:
        return '📈';
    }
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty || _isLoading) return;

    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      text: messageText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${backendBaseUrl()}/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': messageText,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final botMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch + 1,
          text: data['response'] ?? 'No response received',
          sender: MessageSender.bot,
          timestamp: DateTime.now(),
          hasExpenses: data['has_expenses'] ?? false,
          excelData: data['excel_data'],
        );

        _messages.add(botMessage);
        _userTokens += 5;
        _saveUserData();
      } else {
        final errorMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch + 1,
          text: 'Error: ${response.body}',
          sender: MessageSender.error,
          timestamp: DateTime.now(),
        );
        _messages.add(errorMessage);
      }
    } catch (e) {
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        text: 'Error: Failed to connect to server - $e',
        sender: MessageSender.error,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTokens(int tokens) {
    _userTokens += tokens;
    _saveUserData();
    notifyListeners();
  }

  void refreshNiftyData() {
    _generateNiftyData();
  }

  void checkHealth() {
    _checkBackendHealth();
  }
}

class NiftyDataPoint {
  final String time;
  final int value;

  NiftyDataPoint({required this.time, required this.value});
}
