import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' as math;

class NotificationService {
  static const String _notificationChannelId = 'daily_tip_channel';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Different notification categories with titles and emojis
  static const List<Map<String, String>> _notificationTypes = [
    {'title': '💰 Daily Finance Tip', 'category': 'saving', 'emoji': '💰'},
    {'title': '📊 Budget Wisdom', 'category': 'budgeting', 'emoji': '📊'},
    {'title': '📈 Investment Insight', 'category': 'investing', 'emoji': '📈'},
    {'title': '🎯 Money Goal', 'category': 'goals', 'emoji': '🎯'},
    {'title': '⚡ Quick Money Tip', 'category': 'quick_tip', 'emoji': '⚡'},
    {'title': '🧠 Smart Spending', 'category': 'spending', 'emoji': '🧠'},
    {'title': '🏦 Banking Advice', 'category': 'banking', 'emoji': '🏦'},
  ];

  static String _backendHost() {
    if (kIsWeb) return 'localhost';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      default:
        return 'localhost';
    }
  }

  static String _backendBaseUrl() => 'http://${_backendHost()}:8000';

  /// Initialize the notification service
  static Future<bool> initialize() async {
    if (kIsWeb) return true;

    try {
      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(initializationSettings);

      // Create notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _notificationChannelId,
        'Daily Tips',
        description: 'Daily finance tips and reminders',
        importance: Importance.defaultImportance,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      debugPrint('Notification service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
      return false;
    }
  }

  /// Request notification permissions with in-app dialog
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    // For now, we'll use flutter_local_notifications to request permissions
    // This avoids the MissingPluginException from the custom MethodChannel
    try {
      if (Platform.isAndroid) {
        // Try to use flutter_local_notifications permission request
        final bool? granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

        debugPrint('Notification permission granted: $granted');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notification_permission_granted', granted ?? true);
        return granted ?? true; // Default to true if permission check fails
      }
      return true;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return true; // Default to true to allow testing
    }
  }

  /// Ensure permission then show a test notification; prompts if first time
  static Future<void> ensurePermissionThenTest() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyGranted =
        prefs.getBool('notification_permission_granted') ?? false;
    if (!alreadyGranted) {
      await requestPermissions();
    }
    await showTestNotification();
  }

  /// Enable daily tip notifications
  static Future<void> enableDailyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_tip_notifications', true);
    debugPrint('Daily notifications enabled');
  }

  /// Disable daily tip notifications
  static Future<void> disableDailyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_tip_notifications', false);
    await _notificationsPlugin.cancelAll();
    debugPrint('Daily notifications disabled');
  }

  /// Check if daily notifications are enabled
  static Future<bool> isDailyNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('daily_tip_notifications') ?? false;
  }

  /// Show immediate notification for testing
  static Future<void> showTestNotification() async {
    await _fetchAndShowVariedTip();
  }

  /// Generate different types of notifications using Gemini
  static Future<void> _fetchAndShowVariedTip() async {
    try {
      // Get a random notification type
      final random = math.Random();
      final notificationType =
          _notificationTypes[random.nextInt(_notificationTypes.length)];

      // Fetch tip from backend with category context
      final response = await http
          .post(
            Uri.parse('${_backendBaseUrl()}/daily-tip'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'category': notificationType['category'],
              'notification_type': 'varied',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tipData = data['tip'] ?? data;
        final tipText = tipData['tip'] ?? tipData.toString();

        await _showVariedNotification(
          notificationType['title']!,
          tipText,
          notificationType['emoji']!,
        );
      } else {
        // Fallback to varied fallback tips
        await _showFallbackVariedTip();
      }
    } catch (e) {
      debugPrint('Failed to fetch varied tip: $e');
      await _showFallbackVariedTip();
    }
  }

  /// Show fallback varied tip when backend is unavailable
  static Future<void> _showFallbackVariedTip() async {
    final random = math.Random();
    final notificationType =
        _notificationTypes[random.nextInt(_notificationTypes.length)];

    final fallbackTips = {
      'saving': [
        'Save ₹50 daily to have ₹18,250 in a year!',
        'Use the 52-week savings challenge to build your emergency fund.',
        'Round up purchases to the nearest ₹10 and save the difference.',
      ],
      'budgeting': [
        'Follow the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
        'Track every expense for a week to understand spending patterns.',
        'Set weekly spending limits for different categories.',
      ],
      'investing': [
        'Start a SIP with just ₹500 monthly to begin investing.',
        'Diversify across equity, debt, and gold for balanced growth.',
        'Time in the market beats timing the market.',
      ],
      'goals': [
        'Write down 3 financial goals and review them monthly.',
        'Break big goals into smaller, achievable milestones.',
        'Celebrate small wins to stay motivated on your money journey.',
      ],
      'quick_tip': [
        'Compare prices before buying anything above ₹1000.',
        'Use cash instead of cards to limit impulse purchases.',
        'Cook meals at home to save ₹100+ daily.',
      ],
      'spending': [
        'Wait 24 hours before making non-essential purchases.',
        'Question every purchase: "Do I need this or want this?"',
        'Review and cancel unused subscriptions monthly.',
      ],
      'banking': [
        'Choose a zero-balance savings account to avoid fees.',
        'Set up automatic transfers to your savings account.',
        'Use UPI for small transactions to track spending digitally.',
      ],
    };

    final category = notificationType['category']!;
    final tips = fallbackTips[category] ?? fallbackTips['saving']!;
    final selectedTip = tips[random.nextInt(tips.length)];

    await _showNotification(selectedTip);
  }

  /// Fetch daily tip from backend and show notification
  /// Show local notification
  static Future<void> _showNotification(String tipText) async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _notificationChannelId,
            'Daily Tips',
            channelDescription: 'Daily finance tips and reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        '💰 Daily Finance Tip',
        tipText,
        platformDetails,
      );

      debugPrint('Daily tip notification shown: $tipText');
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Show varied notification with custom title and emoji
  static Future<void> _showVariedNotification(
    String title,
    String body,
    String emoji,
  ) async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _notificationChannelId,
            'Daily Tips',
            channelDescription: 'Daily finance tips and reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      // Add emoji to the title for visual appeal
      final notificationTitle = '$emoji $title';

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        notificationTitle,
        body,
        platformDetails,
      );

      debugPrint('Varied tip notification shown: $notificationTitle - $body');
    } catch (e) {
      debugPrint('Failed to show varied notification: $e');
    }
  }
}
