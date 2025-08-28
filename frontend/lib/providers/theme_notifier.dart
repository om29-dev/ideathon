import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }

class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  late SharedPreferences _prefs;
  AppThemeMode _currentTheme = AppThemeMode.light;

  AppThemeMode get currentTheme => _currentTheme;

  ThemeNotifier(SharedPreferences prefs) {
    _prefs = prefs;
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _currentTheme = AppThemeMode.values.firstWhere(
        (theme) => theme.toString() == savedTheme,
        orElse: () => AppThemeMode.light,
      );
    }
  }

  void toggleTheme() {
    _currentTheme = _currentTheme == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  void _saveTheme() {
    _prefs.setString(_themeKey, _currentTheme.toString());
  }

  ThemeMode get themeMode {
    return _currentTheme == AppThemeMode.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}
