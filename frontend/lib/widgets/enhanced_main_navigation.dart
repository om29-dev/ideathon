import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_state.dart';
import '../screens/dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/expense_tracker_screen.dart';
import '../screens/investment_portfolio_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/financial_goals_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../widgets/app_drawer.dart';

class EnhancedMainNavigation extends StatefulWidget {
  const EnhancedMainNavigation({super.key});

  @override
  State<EnhancedMainNavigation> createState() => _EnhancedMainNavigationState();
}

class _EnhancedMainNavigationState extends State<EnhancedMainNavigation> {
  List<NavigationItem> get _navigationItems => [
    NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      screen: const DashboardScreen(),
    ),
    NavigationItem(
      title: 'AI Chat',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      screen: const HomeScreen(),
    ),
    NavigationItem(
      title: 'Expenses',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      screen: const ExpenseTrackerScreen(),
    ),
    NavigationItem(
      title: 'Investments',
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up,
      screen: const InvestmentPortfolioScreen(),
    ),
    NavigationItem(
      title: 'Budget',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      screen: const BudgetScreen(),
    ),
    NavigationItem(
      title: 'Goals',
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag,
      screen: const FinancialGoalsScreen(),
    ),
    NavigationItem(
      title: 'Analytics',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      screen: const AnalyticsScreen(),
    ),
    NavigationItem(
      title: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      screen: const ProfileScreen(),
    ),
    NavigationItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      screen: const SettingsScreen(),
    ),
    NavigationItem(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      screen: const NotificationsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationState>(
      builder: (context, navigationState, child) {
        final currentItem = _navigationItems[navigationState.currentIndex];
        final isWideScreen = MediaQuery.of(context).size.width >= 1024;

        if (isWideScreen) {
          return _buildDesktopLayout(navigationState);
        } else {
          return _buildMobileLayout(navigationState, currentItem);
        }
      },
    );
  }

  Widget _buildDesktopLayout(NavigationState navigationState) {
    final currentItem = _navigationItems[navigationState.currentIndex];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Finance Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your AI Financial Companion',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = index == navigationState.currentIndex;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade600,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade700,
                            ),
                          ),
                          onTap: () => navigationState.setIndex(index),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                // User Profile Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'John Doe',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Premium Member',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showProfileOptions(context),
                        icon: const Icon(Icons.more_vert),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(child: currentItem.screen),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    NavigationState navigationState,
    NavigationItem currentItem,
  ) {
    return Scaffold(
      drawer: AppDrawer(
        onNavigate: (index) => navigationState.setIndex(index),
        currentIndex: navigationState.currentIndex,
      ),
      body: currentItem.screen,
      bottomNavigationBar: _buildBottomNavigationBar(navigationState),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNavigationBar(NavigationState navigationState) {
    // Show only main items in bottom nav for mobile
    final mainItems = _navigationItems.take(5).toList();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: navigationState.currentIndex.clamp(0, 4),
      onTap: (index) => navigationState.setIndex(index),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      items: mainItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.title,
            ),
          )
          .toList(),
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}
