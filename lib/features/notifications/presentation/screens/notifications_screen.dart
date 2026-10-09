import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'practice', 'mock_test', 'account', 'system'
  final DateTime createdAt;
  bool isRead;
  final String? routeTarget;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.routeTarget,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<NotificationItem> _notifications = [];
  String _filter = 'All'; // 'All' or 'Unread'

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Simulating network
      _notifications = [
        NotificationItem(
          id: 'n1',
          title: 'Mock Test Completed',
          message: 'Your completed mock test is ready for review. Click here to see your detailed performance analytics.',
          type: 'mock_test',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: false,
          routeTarget: '/mock-tests',
        ),
        NotificationItem(
          id: 'n2',
          title: 'Daily Practice Ready',
          message: 'Your daily practice session is ready. Continue your preparation for TNPSC Group 4.',
          type: 'practice',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
          routeTarget: '/practice',
        ),
        NotificationItem(
          id: 'n3',
          title: 'New Sign-in Detected',
          message: 'A new sign-in was detected on a Windows device. If this was you, you can ignore this alert.',
          type: 'account',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          routeTarget: '/profile',
        ),
        NotificationItem(
          id: 'n4',
          title: 'Scheduled Maintenance',
          message: 'GovPrep AI will undergo brief maintenance on Sunday at 2:00 AM IST.',
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _markAsRead(NotificationItem item) {
    if (item.isRead) return;
    setState(() {
      item.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.', style: TextStyle(color: Color(0xFF0F0F11))),
        backgroundColor: Color(0xFFFFFFFF),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem item) {
    _markAsRead(item);
    if (item.routeTarget != null) {
      context.push(item.routeTarget!);
    }
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
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      width: double.infinity,
      child: Row(
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 12),
          _buildFilterChip('Unread'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF0F0F11))),
      selected: isSelected,
      selectedColor: const Color(0xFFE4DBF6),
      backgroundColor: const Color(0xFFF3F4F6),
      onSelected: (selected) {
        if (selected) setState(() => _filter = label);
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final filteredList = _notifications.where((n) {
      if (_filter == 'Unread') return !n.isRead;
      return true;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _filter == 'Unread' ? Icons.done_all : Icons.notifications_off_outlined,
              size: 64,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.3)
            ),
            const SizedBox(height: 16),
            Text(
              _filter == 'Unread' ? 'No unread notifications' : 'You\'re all caught up',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))
            ),
            const SizedBox(height: 8),
            Text(
              _filter == 'Unread' ? 'You\'re all caught up.' : 'Important updates will appear here.',
              style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      color: const Color(0xFF0F0F11),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final item = filteredList[index];
          return _buildNotificationCard(item);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    IconData iconData;
    Color iconColor;

    switch (item.type) {
      case 'mock_test':
        iconData = Icons.timer;
        iconColor = Colors.pinkAccent;
        break;
      case 'practice':
        iconData = Icons.quiz;
        iconColor = Colors.orangeAccent;
        break;
      case 'account':
        iconData = Icons.security;
        iconColor = Colors.blueAccent;
        break;
      case 'system':
      default:
        iconData = Icons.info_outline;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead ? const Color(0xFFFFFFFF) : const Color(0xFFFDF0D5).withValues(alpha: 0.4), // Soft yellow tint for unread
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.isRead ? const Color(0xFFF3F4F6) : const Color(0xFFE4DBF6), width: item.isRead ? 1 : 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleNotificationTap(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.isRead ? const Color(0xFFF3F4F6) : iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 20, color: item.isRead ? const Color(0xFF0F0F11).withValues(alpha: 0.5) : iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 15,
                                color: const Color(0xFF0F0F11),
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF0F0F11).withValues(alpha: item.isRead ? 0.6 : 0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatTime(item.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF0F0F11).withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}
