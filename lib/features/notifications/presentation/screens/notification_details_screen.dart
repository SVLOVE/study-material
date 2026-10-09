import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'notification_center_screen.dart'; // To access the models (AppNotification, NotificationCategory)

class NotificationDetailsScreen extends ConsumerStatefulWidget {
  final String notificationId;

  const NotificationDetailsScreen({
    super.key,
    required this.notificationId,
  });

  @override
  ConsumerState<NotificationDetailsScreen> createState() => _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends ConsumerState<NotificationDetailsScreen> {
  bool _isLoading = true;
  bool _isProcessingAction = false;
  AppNotification? _notification;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotificationDetails();
  }

  Future<void> _fetchNotificationDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data lookup - in a real app, fetch from repository
      final now = DateTime.now();
      
      // We'll simulate finding it or not based on ID format
      if (widget.notificationId == 'notif_1') {
        _notification = AppNotification(
          id: 'notif_1',
          title: 'TNPSC Group 4 Exam Date Announced',
          message: 'The official notification for Group 4 has been released. The exam is scheduled for 14th June 2026. Please ensure you have completed your registration and reviewed the latest syllabus changes on your readiness dashboard. Start revising the core topics early to stay ahead.',
          category: NotificationCategory.examReminders,
          timestamp: now.subtract(const Duration(hours: 2)),
          isRead: false,
          isImportant: true,
          actionRoute: '/dashboard',
        );
      } else if (widget.notificationId == 'notif_3') {
         _notification = AppNotification(
          id: 'notif_3',
          title: 'Subscription Active',
          message: 'Your GovPrep Pro subscription has been successfully renewed for another year. Thank you for continuing your preparation journey with us! You can review your billing details and download your invoice from the subscription management portal.',
          category: NotificationCategory.subscription,
          timestamp: now.subtract(const Duration(days: 1)),
          isRead: true,
          actionRoute: '/subscription-management',
        );
      } else {
        // Generic fallback for simulation
        _notification = AppNotification(
          id: widget.notificationId,
          title: 'General Notification Update',
          message: 'This is a detailed view of your notification. In a production environment, this content will be loaded dynamically from the backend database.',
          category: NotificationCategory.system,
          timestamp: now.subtract(const Duration(days: 2)),
          isRead: true,
        );
      }
      
      // Mark as read automatically if it's unread
      if (_notification != null && !_notification!.isRead) {
        _markAsReadLocally();
      }
      
    } catch (e) {
      _error = 'Failed to load notification details.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsReadLocally() async {
    // Simulate updating read status in backend silently
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && _notification != null) {
      setState(() {
        _notification = _notification!.copyWith(isRead: true);
      });
    }
  }

  Future<void> _handleToggleReadStatus() async {
    if (_notification == null) return;
    
    setState(() => _isProcessingAction = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _notification = _notification!.copyWith(isRead: !_notification!.isRead);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_notification!.isRead ? 'Marked as read.' : 'Marked as unread.'),
            backgroundColor: const Color(0xFF5A31F4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/notifications');
            }
          },
        ),
        title: const Text('Notification Details', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchNotificationDetails,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notification == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Notification Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('This notification may have been removed.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/notifications'),
              child: const Text('Back to Notifications'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildContentCard(),
                  const SizedBox(height: 24),
                  _buildActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    IconData categoryIcon;
    Color categoryColor;
    String categoryName;

    switch (_notification!.category) {
      case NotificationCategory.examReminders:
        categoryIcon = Icons.event_note;
        categoryColor = const Color(0xFF5A31F4);
        categoryName = 'Exam Update';
        break;
      case NotificationCategory.studyReminders:
        categoryIcon = Icons.menu_book;
        categoryColor = Colors.teal;
        categoryName = 'Study Reminder';
        break;
      case NotificationCategory.mockTests:
        categoryIcon = Icons.quiz;
        categoryColor = Colors.orange;
        categoryName = 'Mock Test';
        break;
      case NotificationCategory.currentAffairs:
        categoryIcon = Icons.public;
        categoryColor = Colors.blue;
        categoryName = 'Current Affairs';
        break;
      case NotificationCategory.achievements:
        categoryIcon = Icons.emoji_events;
        categoryColor = Colors.amber;
        categoryName = 'Achievement';
        break;
      case NotificationCategory.subscription:
        categoryIcon = Icons.payment;
        categoryColor = Colors.green;
        categoryName = 'Billing & Subscription';
        break;
      case NotificationCategory.system:
        categoryIcon = Icons.info;
        categoryColor = Colors.grey[700]!;
        categoryName = 'System Announcement';
        break;
      default:
        categoryIcon = Icons.notifications;
        categoryColor = const Color(0xFF0F0F11);
        categoryName = 'Notification';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoryIcon, color: categoryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(categoryName, style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            if (_notification!.isImportant)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0D5),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('Important', style: TextStyle(color: Colors.orange[900], fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _notification!.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), height: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(_notification!.timestamp),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildContentCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _notification!.message,
            style: const TextStyle(
              fontSize: 16, 
              color: Color(0xFF0F0F11), 
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        if (_notification!.actionRoute != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(_notification!.actionRoute!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isProcessingAction ? null : _handleToggleReadStatus,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
            ),
            child: _isProcessingAction 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_notification!.isRead ? 'Mark as Unread' : 'Mark as Read', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
