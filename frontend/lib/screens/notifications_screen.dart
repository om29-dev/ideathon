import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Local state for category toggles (future persistence via SharedPreferences)
  final Map<String, bool> _categoryToggles = {
    'Budget Alerts': true,
    'Goal Updates': true,
    'Investment Updates': false,
    'Bill Reminders': true,
    'Weekly Reports': true,
    'Promotional': false,
  };

  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: '1',
      title: 'Budget Alert',
      message: 'You\'ve spent 80% of your food budget this month.',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.warning,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Goal Achievement!',
      message:
          'Congratulations! You\'ve reached your savings goal for this month.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.success,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Investment Update',
      message: 'Your portfolio is up 5.2% today. Great job!',
      time: DateTime.now().subtract(const Duration(hours: 4)),
      type: NotificationType.info,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Bill Reminder',
      message: 'Your electricity bill of ₹2,450 is due in 3 days.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.reminder,
      isRead: false,
    ),
    NotificationItem(
      id: '5',
      title: 'Expense Added',
      message: 'New expense of ₹450 added for Coffee & Snacks.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.info,
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: 'Weekly Report',
      message: 'Your weekly financial report is ready to view.',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.info,
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      title: 'Unusual Spending',
      message: 'We noticed unusual spending on entertainment this week.',
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.warning,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showNotificationSettings,
            tooltip: 'Notification settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(child: _buildTabWithBadge('All', _allNotifications.length)),
            Tab(
              child: _buildTabWithBadge(
                'Unread',
                _allNotifications.where((n) => !n.isRead).length,
              ),
            ),
            Tab(
              child: _buildTabWithBadge(
                'Alerts',
                _allNotifications
                    .where((n) => n.type == NotificationType.warning)
                    .length,
              ),
            ),
            Tab(
              child: _buildTabWithBadge(
                'Updates',
                _allNotifications
                    .where((n) => n.type == NotificationType.info)
                    .length,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(_allNotifications),
          _buildNotificationsList(
            _allNotifications.where((n) => !n.isRead).toList(),
          ),
          _buildNotificationsList(
            _allNotifications
                .where((n) => n.type == NotificationType.warning)
                .toList(),
          ),
          _buildNotificationsList(
            _allNotifications
                .where((n) => n.type == NotificationType.info)
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications here',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildNotificationItem(notifications[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.isRead ? 2 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: InkWell(
          onTap: () => _markAsRead(notification.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getNotificationTypeColor(
                      notification.type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationTypeIcon(notification.type),
                    color: _getNotificationTypeColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.time),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_read':
                        _markAsRead(notification.id);
                        break;
                      case 'delete':
                        _deleteNotification(notification.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(
                            notification.isRead
                                ? Icons.mark_email_unread
                                : Icons.mark_email_read,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            notification.isRead
                                ? 'Mark as unread'
                                : 'Mark as read',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.purple;
    }
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.reminder:
        return Icons.alarm;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _allNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _allNotifications[index].isRead = !_allNotifications[index].isRead;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _allNotifications.removeWhere((n) => n.id == notificationId);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notification deleted')));
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Notification Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (final entry in _categoryToggles.entries)
                        _buildNotificationSetting(
                          entry.key,
                          _describeCategory(entry.key),
                          _iconForCategory(entry.key),
                          entry.value,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _describeCategory(String title) {
    switch (title) {
      case 'Budget Alerts':
        return 'Get notified when you approach budget limits';
      case 'Goal Updates':
        return 'Updates about your financial goals';
      case 'Investment Updates':
        return 'Portfolio and market update alerts';
      case 'Bill Reminders':
        return 'Reminders for upcoming bills';
      case 'Weekly Reports':
        return 'Weekly financial summaries';
      case 'Promotional':
        return 'Offers and promotional content';
      default:
        return 'Notification toggle';
    }
  }

  IconData _iconForCategory(String title) {
    switch (title) {
      case 'Budget Alerts':
        return Icons.account_balance_wallet;
      case 'Goal Updates':
        return Icons.flag;
      case 'Investment Updates':
        return Icons.trending_up;
      case 'Bill Reminders':
        return Icons.receipt;
      case 'Weekly Reports':
        return Icons.assessment;
      case 'Promotional':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildNotificationSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
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
          onChanged: (newValue) {
            setState(() => _categoryToggles[title] = newValue);
          },
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { success, warning, info, reminder }
