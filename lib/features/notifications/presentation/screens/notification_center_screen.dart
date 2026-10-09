import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum NotificationCategory {
  all,
  examReminders,
  studyReminders,
  mockTests,
  currentAffairs,
  achievements,
  subscription,
  system,
}

enum NotificationReadFilter {
  all,
  unread,
  read,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final bool isImportant;
  final String? actionRoute;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.isImportant = false,
    this.actionRoute,
  });
  
  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      category: category,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isImportant: isImportant,
      actionRoute: actionRoute,
    );
  }
}

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  NotificationCategory _selectedCategory = NotificationCategory.all;
  NotificationReadFilter _readFilter = NotificationReadFilter.all;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final now = DateTime.now();
      _notifications = [
        AppNotification(
          id: 'notif_1',
          title: 'TNPSC Group 4 Exam Date Announced',
          message: 'The official notification for Group 4 has been released. Check your readiness dashboard.',
          category: NotificationCategory.examReminders,
          timestamp: now.subtract(const Duration(hours: 2)),
          isRead: false,
          isImportant: true,
          actionRoute: '/dashboard',
        ),
        AppNotification(
          id: 'notif_2',
          title: 'Daily Study Goal Reached! 🌟',
          message: 'You have completed your 4-hour study goal today. Keep up the momentum!',
          category: NotificationCategory.achievements,
          timestamp: now.subtract(const Duration(hours: 6)),
          isRead: false,
        ),
        AppNotification(
          id: 'notif_3',
          title: 'Subscription Active',
          message: 'Your GovPrep Pro subscription has been successfully renewed. Thank you!',
          category: NotificationCategory.subscription,
          timestamp: now.subtract(const Duration(days: 1)),
          isRead: true,
          actionRoute: '/subscription-management',
        ),
        AppNotification(
          id: 'notif_4',
          title: 'New Mock Test Available',
          message: 'A new full-length mock test for SSC CGL Tier 1 is now available.',
          category: NotificationCategory.mockTests,
          timestamp: now.subtract(const Duration(days: 2)),
          isRead: true,
        ),
        AppNotification(
          id: 'notif_5',
          title: 'Scheduled Maintenance',
          message: 'GovPrep AI will undergo scheduled maintenance on Sunday from 2 AM to 4 AM.',
          category: NotificationCategory.system,
          timestamp: now.subtract(const Duration(days: 3)),
          isRead: true,
        ),
      ];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AppNotification> get _filteredNotifications {
    return _notifications.where((n) {
      final matchesCategory = _selectedCategory == NotificationCategory.all || n.category == _selectedCategory;
      final matchesRead = _readFilter == NotificationReadFilter.all ||
          (_readFilter == NotificationReadFilter.unread && !n.isRead) ||
          (_readFilter == NotificationReadFilter.read && n.isRead);
      return matchesCategory && matchesRead;
    }).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _markAsRead(String id) async {
    // Optimistic UI update
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
    
    // Simulate backend sync
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    
    // Simulate backend sync
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read.'), backgroundColor: Colors.green),
      );
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }
    
    // Always route to the details screen as per Phase 134
    context.go('/notifications/${notification.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Notification Center', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0F0F11)),
            tooltip: 'Notification Preferences',
            onPressed: () {
              // Navigate to settings when supported
              context.go('/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Stay updated on your exam preparation and account activity.',
                              style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            _buildHeaderRow(),
                            const SizedBox(height: 24),
                            _buildFilters(),
                            const SizedBox(height: 24),
                            _buildNotificationList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    final unread = _unreadCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Your Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            if (unread > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF5A31F4), borderRadius: BorderRadius.circular(100)),
                child: Text('$unread New', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        if (unread > 0)
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark all as read'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF5A31F4)),
          ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Read Status Segmented Control
        SegmentedButton<NotificationReadFilter>(
          segments: const [
            ButtonSegment(value: NotificationReadFilter.all, label: Text('All')),
            ButtonSegment(value: NotificationReadFilter.unread, label: Text('Unread')),
            ButtonSegment(value: NotificationReadFilter.read, label: Text('Read')),
          ],
          selected: {_readFilter},
          onSelectionChanged: (Set<NotificationReadFilter> newSelection) {
            setState(() => _readFilter = newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF5A31F4).withValues(alpha: 0.1);
                }
                return Colors.white;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF5A31F4);
                }
                return const Color(0xFF0F0F11);
              },
            ),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        const SizedBox(height: 16),
        // Category Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('All Categories', NotificationCategory.all),
              _buildCategoryChip('Exam Updates', NotificationCategory.examReminders),
              _buildCategoryChip('Study', NotificationCategory.studyReminders),
              _buildCategoryChip('Mock Tests', NotificationCategory.mockTests),
              _buildCategoryChip('Current Affairs', NotificationCategory.currentAffairs),
              _buildCategoryChip('Achievements', NotificationCategory.achievements),
              _buildCategoryChip('Billing', NotificationCategory.subscription),
              _buildCategoryChip('System', NotificationCategory.system),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, NotificationCategory category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF0F0F11),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF0F0F11),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6)),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    final filtered = _filteredNotifications;
    
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final n = filtered[index];
        return _buildNotificationCard(n);
      },
    );
  }

  Widget _buildEmptyState() {
    IconData icon;
    String title;
    String message;

    if (_notifications.isEmpty) {
      icon = Icons.notifications_none;
      title = "You're All Caught Up";
      message = 'New updates about your preparation and account will appear here.';
    } else if (_readFilter == NotificationReadFilter.unread && _filteredNotifications.isEmpty) {
      icon = Icons.mark_email_read_outlined;
      title = 'No Unread Notifications';
      message = "You've reviewed all available notifications.";
    } else {
      icon = Icons.search_off;
      title = 'No Matching Notifications';
      message = 'Try another category or clear your filters.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          if (_selectedCategory != NotificationCategory.all || _readFilter != NotificationReadFilter.all) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = NotificationCategory.all;
                  _readFilter = NotificationReadFilter.all;
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    IconData categoryIcon;
    Color categoryColor;

    switch (notification.category) {
      case NotificationCategory.examReminders:
        categoryIcon = Icons.event_note;
        categoryColor = const Color(0xFF5A31F4);
        break;
      case NotificationCategory.studyReminders:
        categoryIcon = Icons.menu_book;
        categoryColor = Colors.teal;
        break;
      case NotificationCategory.mockTests:
        categoryIcon = Icons.quiz;
        categoryColor = Colors.orange;
        break;
      case NotificationCategory.currentAffairs:
        categoryIcon = Icons.public;
        categoryColor = Colors.blue;
        break;
      case NotificationCategory.achievements:
        categoryIcon = Icons.emoji_events;
        categoryColor = Colors.amber;
        break;
      case NotificationCategory.subscription:
        categoryIcon = Icons.payment;
        categoryColor = Colors.green;
        break;
      case NotificationCategory.system:
        categoryIcon = Icons.info;
        categoryColor = Colors.grey[700]!;
        break;
      default:
        categoryIcon = Icons.notifications;
        categoryColor = const Color(0xFF0F0F11);
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead ? const Color(0xFFF3F4F6) : const Color(0xFFE4DBF6),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      color: notification.isRead ? Colors.white : const Color(0xFFF6F3FB), // Slight lavender tint if unread
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (notification.isImportant) ...[
                          const Icon(Icons.error, size: 16, color: Colors.orange),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                              color: const Color(0xFF0F0F11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(fontSize: 12, color: notification.isRead ? Colors.grey[500] : const Color(0xFF5A31F4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead ? Colors.grey[600] : const Color(0xFF0F0F11),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5A31F4),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
