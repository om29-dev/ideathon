import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform, File;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/download_helper.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'widgets/permission_dialog.dart';
import 'screens/auth_screen.dart';
import 'widgets/enhanced_main_navigation.dart';
import 'providers/app_state.dart';
import 'providers/theme_notifier.dart';
import 'providers/navigation_state.dart';

String _backendHost() {
  if (kIsWeb) return 'localhost';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // Android emulator (Android Studio AVD) uses 10.0.2.2 to reach host machine
      return '10.0.2.2';
    default:
      return 'localhost';
  }
}

String backendBaseUrl() => 'http://${_backendHost()}:8000';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService().database;

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState(widget.prefs)),
        ChangeNotifierProvider(
          create: (context) => ThemeNotifier(widget.prefs),
        ),
        ChangeNotifierProvider(create: (context) => NavigationState()),
      ],
      child: Selector<ThemeNotifier, ThemeMode>(
        selector: (context, themeNotifier) => themeNotifier.themeMode,
        builder: (context, themeMode, child) {
          return MaterialApp(
            title: 'AI Finance Assistant',
            debugShowCheckedModeBanner: false,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            themeMode: themeMode,
            home: child,
          );
        },
        child: FutureBuilder<bool>(
          future: _checkAuthenticationStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data == true) {
              return const AuthenticatedApp();
            } else {
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }

  Future<bool> _checkAuthenticationStatus() async {
    try {
      return await AuthService.hasAuthenticationSetup();
    } catch (e) {
      return false;
    }
  }

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    primaryColor: const Color(0xFF6366F1), // Indigo
    scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Very light gray
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6366F1), // Indigo
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6366F1), // Indigo
      secondary: Color(0xFF8B5CF6), // Purple
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      error: Color(0xFFEF4444),
      onError: Colors.white,
    ),
    // Input decoration theme for forms
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF6366F1),
      unselectedItemColor: Color(0xFF6B7280),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    ),
  );

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    primaryColor: const Color(0xFF6366F1), // Indigo
    scaffoldBackgroundColor: const Color(0xFF0F0F23), // Dark background
    cardColor: const Color(0xFF1E1E2E), // Dark surface
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6366F1), // Indigo
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1), // Indigo
      secondary: Color(0xFF8B5CF6), // Purple
      surface: Color(0xFF1E1E2E), // Dark surface
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      error: Color(0xFFEF4444),
      onError: Colors.white,
    ),
    // Improve text themes for dark mode
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white60),
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white70),
    ),
    // Input decoration theme for forms
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3A3A4E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3A3A4E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E2E),
      selectedItemColor: Color(0xFF6366F1),
      unselectedItemColor: Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}

class AuthenticatedApp extends StatelessWidget {
  const AuthenticatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const EnhancedMainNavigation();
  }
}

class FinanceAssistantHome extends StatefulWidget {
  const FinanceAssistantHome({super.key});

  @override
  State<FinanceAssistantHome> createState() => _FinanceAssistantHomeState();
}

class _FinanceAssistantHomeState extends State<FinanceAssistantHome> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _userTokens = 150;
  String _connectionStatus = 'checking';
  List<Map<String, dynamic>> _importedMessages = [];
  bool _isImportingMessages = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _checkBackendHealth();
    _initializeNotifications();
  }

  /// Initialize notification service and load preferences
  Future<void> _initializeNotifications() async {
    try {
      // Initialize notification service
      final initialized = await NotificationService.initialize();

      if (initialized) {
        debugPrint('Notification service initialized successfully');

        // Load user preferences
        final enabled = await NotificationService.isDailyNotificationsEnabled();
        setState(() {
          _dailyTipEnabled = enabled;
        });

        // Request permissions if notifications are enabled
        if (enabled) {
          await NotificationService.requestPermissions();
          debugPrint(
            'Notification permissions requested for enabled notifications',
          );
        }
      } else {
        debugPrint('Failed to initialize notification service');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  bool _dailyTipEnabled = false;

  /// Toggle daily tip notifications on/off
  Future<void> _setDailyTipEnabled(bool enabled) async {
    if (enabled) {
      // Show permission dialog first
      final bool? userConsent = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => NotificationPermissionDialog(
          onAllow: () => Navigator.of(context).pop(true),
          onDeny: () => Navigator.of(context).pop(false),
        ),
      );

      if (userConsent != true) {
        // User denied permission
        setState(() {
          _dailyTipEnabled = false;
        });
        return;
      }

      // User allowed, now request system permissions
      try {
        debugPrint('Requesting notification permissions...');
        final granted = await NotificationService.requestPermissions();
        debugPrint('Permission granted: $granted');

        if (granted) {
          setState(() {
            _dailyTipEnabled = true;
          });

          // Enable daily notifications
          await NotificationService.enableDailyNotifications();
          debugPrint('Daily notifications enabled');

          // Show immediate test notification
          await NotificationService.ensurePermissionThenTest();
          debugPrint('Test notification sent');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Daily tips enabled! Test notification sent.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Permission denied at system level
          setState(() {
            _dailyTipEnabled = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please enable notifications in your device settings to receive daily tips.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error requesting permissions: $e');
        setState(() {
          _dailyTipEnabled = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // Disable notifications
      setState(() {
        _dailyTipEnabled = false;
      });

      await NotificationService.disableDailyNotifications();
      debugPrint('Daily notifications disabled');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily tip notifications disabled.')),
        );
      }
    }
  }

  static const MethodChannel _smsChannel = MethodChannel('app/sms');

  Future<void> _importMessages() async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import messages is only supported on Android.'),
        ),
      );
      return;
    }

    setState(() {
      _isImportingMessages = true;
    });

    try {
      final result = await _smsChannel.invokeMethod('getSms');
      // Expecting a List<Map<String, dynamic>> serialized from Android
      final List<dynamic> list = result as List<dynamic>;
      _importedMessages = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // save temporarily to cache
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/imported_messages.json');
      await file.writeAsString(json.encode(_importedMessages));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported ${_importedMessages.length} messages'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to import messages: $e')));
    } finally {
      setState(() {
        _isImportingMessages = false;
      });
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "Hello! I'm your AI Finance Assistant powered by Google's Gemini. I'm here to help you manage your finances as a student! 💰\n\n💡 **Features**:\n• Track your daily expenses\n• Get investment advice for students\n• Learn about SIP and stock market basics\n• Set financial goals\n\nTry saying: 'I spent ₹150 on books and ₹80 on snacks today'",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('${backendBaseUrl()}/health'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _connectionStatus = data['gemini_configured']
              ? 'connected'
              : 'no-api-key';
        });
      } else {
        setState(() {
          _connectionStatus = 'disconnected';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'disconnected';
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('${backendBaseUrl()}/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add(
            ChatMessage(
              text: data['response'] ?? 'No response received',
              isUser: false,
              timestamp: DateTime.now(),
              hasExpenses: data['has_expenses'] ?? false,
            ),
          );
          _userTokens += 5;
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Error: ${response.body}',
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Error: Failed to connect to server - $e',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    switch (_connectionStatus) {
      case 'connected':
        color = Colors.green;
        text = 'Connected';
        icon = Icons.check_circle;
        break;
      case 'no-api-key':
        color = Colors.orange;
        text = 'API Key Required';
        icon = Icons.warning;
        break;
      case 'disconnected':
        color = Colors.red;
        text = 'Backend Offline';
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        text = 'Checking...';
        icon = Icons.refresh;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      drawer: isNarrow
          ? Drawer(child: SafeArea(child: _buildUserProfile()))
          : null,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            // Make title flexible so it truncates on narrow screens instead of overflowing
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'AI Finance Assistant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              context.read<ThemeNotifier>().toggleTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    Theme.of(context).brightness == Brightness.dark
                        ? '☀️ Switched to Light Mode!'
                        : '🌙 Switched to Dark Mode!',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _showProfileDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Make sidebar responsive based on screen width
          double sidebarWidth = constraints.maxWidth > 1200
              ? 280
              : constraints.maxWidth > 800
              ? 250
              : 200;

          return Row(
            children: [
              // Left Sidebar (visible on wide screens)
              if (!isNarrow)
                Container(
                  width: sidebarWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // User Profile Section
                        _buildUserProfile(),

                        const SizedBox(height: 16),

                        // NIFTY 50 Chart
                        _buildNiftyChart(),

                        const SizedBox(height: 16),

                        // Daily Tip
                        _buildDailyTip(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

              // Main Chat Area
              Expanded(
                child: Column(
                  children: [
                    // Connection Status Warning
                    if (_connectionStatus != 'connected')
                      _buildConnectionWarning(),

                    // Messages List
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
                    ),

                    // Input Section
                    _buildInputSection(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserProfile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Connection status + tokens at top to avoid AppBar overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '$_userTokens',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF6C63FF), const Color(0xFF9C27B0)]
                    : [const Color(0xFF4361ee), const Color(0xFF7209b7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),

          const SizedBox(height: 12),

          // Name and Title
          Text(
            'Student User',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          Text(
            'Finance Enthusiast',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 16),

          // Messages import
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Import Messages'),
            subtitle: Text(
              _importedMessages.isEmpty
                  ? 'No messages imported'
                  : '${_importedMessages.length} messages',
            ),
            onTap: _importMessages,
            trailing: _isImportingMessages
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),

          // Daily Tip Notifications switch
          SwitchListTile(
            title: const Text('Daily Tip Notifications'),
            subtitle: const Text('Receive daily finance tips as notifications'),
            secondary: const Icon(Icons.notifications),
            value: _dailyTipEnabled,
            onChanged: (v) => _setDailyTipEnabled(v),
          ),

          // Test notification button (only show if notifications are enabled)
          if (_dailyTipEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.ensurePermissionThenTest();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.notification_add),
                label: const Text('Test Notification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Tokens
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2D4A22).withOpacity(0.5)
                  : const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF4A6741)
                    : const Color(0xFFFFEC8B),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on,
                  color: isDark
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFB7950B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_userTokens Tokens',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFB7950B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Level Progress
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level 2',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${(_userTokens * 0.6).toInt()}/300',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (_userTokens * 0.6) / 300,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? const Color(0xFF9C27B0) : const Color(0xFF7209b7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNiftyChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NIFTY 50',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    '18548',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '↗',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Simple Chart Representation
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: SimpleLineChartPainter(isDark: isDark),
              child: Container(),
            ),
          ),

          const SizedBox(height: 6),

          // Chart Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '9:0',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '10:0',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '11:0',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '12:0',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '13:0',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2A1F) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF4A4530)
              : const Color(0xFFFFE082).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: isDark
                    ? const Color(0xFFFFC107)
                    : const Color(0xFFFF8F00),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Daily Tip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFFFC107)
                      : const Color(0xFFFF8F00),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Save ₹50 daily to have ₹18,250 in a year!',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionWarning() {
    if (_connectionStatus == 'connected') return const SizedBox.shrink();

    String message;
    Color color;
    IconData icon;

    switch (_connectionStatus) {
      case 'no-api-key':
        message =
            'To use this app, you need to set up your Gemini API key in the backend.';
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'disconnected':
        message =
            'Backend server is not running. Please start it with: cd backend && python main.py';
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 60),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AI is thinking'),
            SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isError
              ? Colors.red.withOpacity(0.1)
              : isUser
              ? (isDark ? const Color(0xFF6C63FF) : const Color(0xFF4361ee))
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormattedText(message.text, isUser, message.isError),
            if (message.hasExpenses) _buildExpenseActions(),
            const SizedBox(height: 8),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color:
                    (message.isError
                            ? Colors.red
                            : isUser
                            ? Colors.white
                            : Colors.black87)
                        .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text, bool isUser, bool isError) {
    final textColor = isError
        ? Colors.red
        : isUser
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return RichText(text: _parseMarkdownToSpans(text, textColor));
  }

  TextSpan _parseMarkdownToSpans(String text, Color baseColor) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Handle bullet points
      if (line.startsWith('• ')) {
        spans.add(
          TextSpan(
            text: line + (i < lines.length - 1 ? '\n' : ''),
            style: TextStyle(color: baseColor, fontSize: 14),
          ),
        );
        continue;
      }

      // Handle bold text
      final boldRegex = RegExp(r'\*\*(.*?)\*\*');
      int lastEnd = 0;

      for (final match in boldRegex.allMatches(line)) {
        // Add text before bold
        if (match.start > lastEnd) {
          spans.add(
            TextSpan(
              text: line.substring(lastEnd, match.start),
              style: TextStyle(color: baseColor, fontSize: 14),
            ),
          );
        }

        // Add bold text
        spans.add(
          TextSpan(
            text: match.group(1)!,
            style: TextStyle(
              color: baseColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        );

        lastEnd = match.end;
      }

      // Add remaining text
      if (lastEnd < line.length) {
        spans.add(
          TextSpan(
            text: line.substring(lastEnd),
            style: TextStyle(color: baseColor, fontSize: 14),
          ),
        );
      }

      // Add newline except for last line
      if (i < lines.length - 1) {
        spans.add(
          TextSpan(
            text: '\n',
            style: TextStyle(color: baseColor, fontSize: 14),
          ),
        );
      }
    }

    return TextSpan(
      children: spans.isEmpty
          ? [
              TextSpan(
                text: text,
                style: TextStyle(color: baseColor, fontSize: 14),
              ),
            ]
          : spans,
    );
  }

  Widget _buildExpenseActions() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildActionButton('📊 XLSX', Colors.green, () async {
            await _downloadFile('excel');
          }),
          _buildActionButton('📝 CSV', Colors.blue, () async {
            await _downloadFile('csv');
          }),
          _buildActionButton('👁️ Summary', Colors.purple, () {
            _showExpenseSummary();
          }),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String format) async {
    try {
      final response = await http.get(
        Uri.parse('${backendBaseUrl()}/download/$format'),
      );

      if (response.statusCode == 200) {
        // For Flutter web, we need to use a different approach to download files
        final bytes = response.bodyBytes;
        // Use .xlsx extension for Excel downloads
        final filename = format == 'excel' ? 'expenses.xlsx' : 'expenses.csv';
        await downloadBytes(bytes, filename);

        setState(() {
          _userTokens += format == 'excel' ? 10 : 5;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${format.toUpperCase()} downloaded successfully! +${format == 'excel' ? 10 : 5} tokens',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showExpenseSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Expense Summary'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📱 Gaming: ₹3,883'),
            Text('🍕 Food & Dining: ₹2,020'),
            Text('🎬 Entertainment: ₹1,148'),
            SizedBox(height: 10),
            Text(
              '💰 Total: ₹7,051',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    final isDisabled = _isLoading || _connectionStatus == 'disconnected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !isDisabled,
                  decoration: InputDecoration(
                    hintText:
                        'Ask about student budgeting, investments, or track expenses...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: !isDisabled ? (_) => _sendMessage() : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed:
                    !isDisabled && _messageController.text.trim().isNotEmpty
                    ? _sendMessage
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: Icon(_isLoading ? Icons.hourglass_empty : Icons.send),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Try: ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildSuggestionChip(
                      'Track Expense',
                      const Color(0xFF4361ee),
                    ),
                    _buildSuggestionChip(
                      'Saving Tips',
                      const Color(0xFF4361ee),
                    ),
                    _buildSuggestionChip(
                      'SIP Explanation',
                      const Color(0xFF4361ee),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, Color color) {
    final suggestions = {
      'Track Expense': 'I spent ₹150 on books and ₹80 on snacks today',
      'Saving Tips': 'How can I save money as a student?',
      'SIP Explanation': 'Explain SIP in simple terms',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: _isLoading
            ? null
            : () {
                _messageController.text = suggestions[text] ?? text;
                _sendMessage();
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, color: Color(0xFF4361ee)),
            SizedBox(width: 8),
            Text('👤 User Profile'),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361ee).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Investor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('🪙 Tokens: '),
                              Text(
                                '$_userTokens',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Text('📊 Portfolio Value: ₹2,45,000'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // NIFTY 50 Section
                const Text(
                  '📈 NIFTY 50 Performance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current: 22,326.90'),
                          Text(
                            '+2.1%',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Simple chart representation
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('📊', style: TextStyle(fontSize: 40)),
                              SizedBox(height: 8),
                              Text(
                                'NIFTY 50 Chart',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Trending Upward ↗️',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '52W High',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '22,794',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '52W Low',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '19,281',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'P/E Ratio',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '22.8',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Text('💰 Total Savings'),
                            Text(
                              '₹78,450',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Text('📊 Investments'),
                            Text(
                              '₹1,66,550',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class SimpleLineChartPainter extends CustomPainter {
  final bool isDark;

  SimpleLineChartPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF6C63FF) : const Color(0xFF00BCD4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Sample data points for an upward trending line
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.9),
      Offset(size.width * 0.35, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.65, size.height * 0.65),
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width * 0.85, size.height * 0.5),
      Offset(size.width, size.height * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw dots at data points
    final dotPaint = Paint()
      ..color = isDark ? const Color(0xFF6C63FF) : const Color(0xFF00BCD4)
      ..style = PaintingStyle.fill;

    for (final point in points.skip(1).take(points.length - 2)) {
      canvas.drawCircle(point, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasExpenses;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.hasExpenses = false,
    this.isError = false,
  });
}
