import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../providers/app_state.dart';
import '../services/notification_service.dart';
import '../widgets/custom_app_bar.dart';
import '../screens/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyTipEnabled = false;
  bool _biometricEnabled = false;
  String _selectedCurrency = 'INR';
  String _selectedLanguage = 'English';

  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY'];
  final List<String> _languages = ['English', 'Hindi', 'Spanish', 'French'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
      body: Consumer2<ThemeNotifier, AppState>(
        builder: (context, themeNotifier, appState, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSectionHeader('Preferences'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    icon: Icons.dark_mode,
                    value: themeNotifier.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeNotifier.toggleTheme();
                    },
                  ),
                  _buildChipSelector(
                    title: 'Currency',
                    subtitle: 'Select your preferred currency',
                    icon: Icons.currency_rupee,
                    value: _selectedCurrency,
                    items: _currencies,
                    onChanged: (val) => setState(() => _selectedCurrency = val),
                  ),
                  _buildChipSelector(
                    title: 'Language',
                    subtitle: 'Choose your language',
                    icon: Icons.language,
                    value: _selectedLanguage,
                    items: _languages,
                    onChanged: (val) => setState(() => _selectedLanguage = val),
                  ),
                ]),
                _buildSectionHeader('Security'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: 'Biometric Authentication',
                    subtitle: 'Use fingerprint or face ID',
                    icon: Icons.fingerprint,
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() => _biometricEnabled = value);
                    },
                  ),
                  _buildTile(
                    title: 'Change PIN',
                    subtitle: 'Update your security PIN',
                    icon: Icons.lock,
                    onTap: () => _showChangePinDialog(),
                  ),
                  _buildTile(
                    title: 'Privacy Settings',
                    subtitle: 'Manage your privacy preferences',
                    icon: Icons.privacy_tip,
                    onTap: () => _showPrivacySettings(),
                  ),
                ]),
                _buildSectionHeader('Notifications'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive app notifications',
                    icon: Icons.notifications,
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                  FutureBuilder<bool>(
                    future: NotificationService.isDailyNotificationsEnabled(),
                    builder: (context, snapshot) {
                      _dailyTipEnabled = snapshot.data ?? _dailyTipEnabled;
                      return _buildSwitchTile(
                        title: 'Daily Tip Notifications',
                        subtitle: 'Receive daily finance tips',
                        icon: Icons.lightbulb,
                        value: _dailyTipEnabled,
                        onChanged: (value) async {
                          setState(() => _dailyTipEnabled = value);
                          _handleDailyTipToggle(value);
                        },
                      );
                    },
                  ),
                  _buildTile(
                    title: 'Test Daily Tip',
                    subtitle: 'Send a test notification now',
                    icon: Icons.send,
                    onTap: _sendTestNotification,
                  ),
                  _buildTile(
                    title: 'Notification Categories',
                    subtitle: 'Choose which notifications to receive',
                    icon: Icons.category,
                    onTap: () => _showNotificationCategories(),
                  ),
                ]),
                _buildSectionHeader('Data & Backup'),
                _buildSettingsCard([
                  _buildTile(
                    title: 'Export Data',
                    subtitle: 'Download your financial data',
                    icon: Icons.download,
                    onTap: () => _exportData(),
                  ),
                  _buildTile(
                    title: 'Import Data',
                    subtitle: 'Import transactions from files',
                    icon: Icons.upload,
                    onTap: () => _importData(),
                  ),
                  _buildTile(
                    title: 'Cloud Backup',
                    subtitle: 'Sync data to cloud storage',
                    icon: Icons.cloud_upload,
                    onTap: () => _showCloudBackupSettings(),
                  ),
                ]),
                _buildSectionHeader('About'),
                _buildSettingsCard([
                  _buildTile(
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    icon: Icons.help,
                    onTap: () => _showHelpSupport(),
                  ),
                  _buildTile(
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    icon: Icons.policy,
                    onTap: () => _showPrivacyPolicy(),
                  ),
                  _buildTile(
                    title: 'Terms of Service',
                    subtitle: 'Review terms of service',
                    icon: Icons.description,
                    onTap: () => _showTermsOfService(),
                  ),
                  _buildTile(
                    title: 'About App',
                    subtitle: 'App version and information',
                    icon: Icons.info,
                    onTap: () => _showAboutApp(),
                  ),
                ]),
                _buildSectionHeader('Danger Zone'),
                _buildSettingsCard([
                  _buildTile(
                    title: 'Clear Cache',
                    subtitle: 'Clear app cache data',
                    icon: Icons.cached,
                    onTap: () => _clearCache(),
                    textColor: Colors.orange,
                  ),
                  _buildTile(
                    title: 'Reset App',
                    subtitle: 'Reset all app data (irreversible)',
                    icon: Icons.restore,
                    onTap: () => _showResetConfirmation(),
                    textColor: Colors.red,
                  ),
                  _buildTile(
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    icon: Icons.delete_forever,
                    onTap: () => _showDeleteAccountConfirmation(),
                    textColor: Colors.red,
                  ),
                ]),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
      onTap: () => onChanged(!value),
    );
  }

  // Removed legacy _buildDropdownTile (replaced by chip selector)

  Widget _buildChipSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            title: Text(title),
            subtitle: Text(subtitle),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 72, right: 8, bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                final selected = item == value;
                return ChoiceChip(
                  label: Text(item),
                  selected: selected,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => onChanged(item),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current PIN'),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New PIN'),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN updated successfully!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Privacy settings will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationCategories() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Categories'),
        content: const Text(
          'Notification categories will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data... Please wait')),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import data feature coming soon!')),
    );
  }

  void _showCloudBackupSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cloud Backup'),
        content: const Text('Cloud backup settings will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Help and support features will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy policy content will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of service content will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'AI Finance Assistant',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Finance Assistant Team',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Your AI-powered financial companion for better money management.',
          ),
        ),
      ],
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text(
          'This will permanently delete all your data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App reset successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion initiated!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleDailyTipToggle(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.requestPermissions();
      if (granted) {
        await NotificationService.enableDailyNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily tips enabled!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _dailyTipEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied for notifications'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      await NotificationService.disableDailyNotifications();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Daily tips disabled')));
      }
    }
  }

  void _sendTestNotification() async {
    await NotificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification fired'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}
