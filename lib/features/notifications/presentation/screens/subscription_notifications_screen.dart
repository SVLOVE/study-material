import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SubscriptionNotification {
  final String id;
  final String title;
  final String message;
  final String category; // 'Renewal', 'Payment', 'Plan Update'
  final String status; // 'Success', 'Warning', 'Info', 'Error'
  final DateTime timestamp;
  final bool isRead;
  final String actionLabel;
  final String actionRoute;

  SubscriptionNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.status,
    required this.timestamp,
    required this.isRead,
    required this.actionLabel,
    required this.actionRoute,
  });
}

class SubscriptionStatus {
  final String planName;
  final String status;
  final DateTime nextBillingDate;
  final bool autoRenew;

  SubscriptionStatus({
    required this.planName,
    required this.status,
    required this.nextBillingDate,
    required this.autoRenew,
  });
}

class SubscriptionNotificationsScreen extends ConsumerStatefulWidget {
  const SubscriptionNotificationsScreen({super.key});

  @override
  ConsumerState<SubscriptionNotificationsScreen> createState() => _SubscriptionNotificationsScreenState();
}

class _SubscriptionNotificationsScreenState extends ConsumerState<SubscriptionNotificationsScreen> {
  bool _isLoading = true;
  String? _error;
  SubscriptionStatus? _status;
  List<SubscriptionNotification> _notifications = [];
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Unread', 'Renewals', 'Payments', 'Plan Updates'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));

      _status = SubscriptionStatus(
        planName: 'GovPrep Pro Annual',
        status: 'Active',
        nextBillingDate: DateTime.now().add(const Duration(days: 14)),
        autoRenew: true,
      );

      _notifications = [
        SubscriptionNotification(
          id: 'n1',
          title: 'Your plan renewal is approaching.',
          message: 'Your GovPrep Pro Annual plan will automatically renew in 14 days.',
          category: 'Renewal',
          status: 'Info',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
          actionLabel: 'Manage Plan',
          actionRoute: '/subscription-management',
        ),
        SubscriptionNotification(
          id: 'n2',
          title: 'Payment Successful',
          message: 'Your payment of ₹3,999 was processed successfully.',
          category: 'Payment',
          status: 'Success',
          timestamp: DateTime.now().subtract(const Duration(days: 350)),
          isRead: true,
          actionLabel: 'View Receipt',
          actionRoute: '/invoices',
        ),
        SubscriptionNotification(
          id: 'n3',
          title: 'Plan Upgraded',
          message: 'You have successfully upgraded to the Pro Annual tier.',
          category: 'Plan Update',
          status: 'Success',
          timestamp: DateTime.now().subtract(const Duration(days: 350, hours: 1)),
          isRead: true,
          actionLabel: 'View Plan',
          actionRoute: '/subscription-active',
        ),
      ];
    } catch (e) {
      _error = 'Failed to load subscription data.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<SubscriptionNotification> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    if (_selectedFilter == 'Unread') return _notifications.where((n) => !n.isRead).toList();
    if (_selectedFilter == 'Renewals') return _notifications.where((n) => n.category == 'Renewal').toList();
    if (_selectedFilter == 'Payments') return _notifications.where((n) => n.category == 'Payment').toList();
    if (_selectedFilter == 'Plan Updates') return _notifications.where((n) => n.category == 'Plan Update').toList();
    return _notifications;
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        final old = _notifications[index];
        _notifications[index] = SubscriptionNotification(
          id: old.id,
          title: old.title,
          message: old.message,
          category: old.category,
          status: old.status,
          timestamp: old.timestamp,
          isRead: true,
          actionLabel: old.actionLabel,
          actionRoute: old.actionRoute,
        );
      }
    });
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications = _notifications.map((n) {
        if (!n.isRead) {
          return SubscriptionNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            category: n.category,
            status: n.status,
            timestamp: n.timestamp,
            isRead: true,
            actionLabel: n.actionLabel,
            actionRoute: n.actionRoute,
          );
        }
        return n;
      }).toList();
    });
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
        title: Column(
          children: [
            const Text('Subscription Notifications', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Stay updated on your plan, renewals, and billing.', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF5A31F4)),
            tooltip: 'Mark all as read',
            onPressed: _notifications.any((n) => !n.isRead) ? _markAllAsRead : null,
          ),
        ],
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
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
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
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_status != null) ...[
                    _buildStatusSummaryCard(),
                    const SizedBox(height: 32),
                  ],
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildNotificationsList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A31F4).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Subscription',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0D9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2E6559), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _status!.status.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF2E6559), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _status!.planName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Billing Date', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(_status!.nextBillingDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Renew', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      _status!.autoRenew ? 'Enabled' : 'Disabled',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/subscription-management'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5A31F4),
                side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Manage Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE4DBF6),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFFE5E7EB),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final list = _filteredNotifications;

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              "You're all caught up",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            ),
            const SizedBox(height: 8),
            Text(
              "Subscription updates will appear here when available.",
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilter != 'All') ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() => _selectedFilter = 'All'),
                child: const Text('View All Notifications'),
              ),
            ]
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final notif = list[index];
        
        IconData iconData;
        Color iconColor;
        Color iconBg;

        if (notif.status == 'Success') {
          iconData = Icons.check_circle;
          iconColor = Colors.teal;
          iconBg = const Color(0xFFE2F0D9);
        } else if (notif.status == 'Warning') {
          iconData = Icons.warning_amber;
          iconColor = Colors.orange[800]!;
          iconBg = const Color(0xFFFDF0D5);
        } else if (notif.status == 'Error') {
          iconData = Icons.error_outline;
          iconColor = Colors.red;
          iconBg = Colors.red.withValues(alpha: 0.1);
        } else {
          iconData = Icons.info_outline;
          iconColor = const Color(0xFF5A31F4);
          iconBg = const Color(0xFFE4DBF6);
        }

        return Container(
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : const Color(0xFFF9F8FD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: notif.isRead ? const Color(0xFFF3F4F6) : const Color(0xFFE4DBF6)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _markAsRead(notif.id);
                // Optionally navigate to details if it was a deep link, here we just mark as read
                // or follow action route directly. Let's just expand or show toast for now unless action clicked.
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: iconColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    notif.category,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(notif.timestamp),
                                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF0F0F11),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notif.message,
                                style: TextStyle(color: Colors.grey[700], height: 1.4, fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _markAsRead(notif.id);
                                      context.go(notif.actionRoute);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF5A31F4),
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(notif.actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  if (!notif.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5A31F4),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
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
      },
    );
  }
}
