import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum SubManagementStatus {
  active,
  activeRenewalDisabled,
  pending,
  expired,
  cancelled,
  none,
}

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends ConsumerState<SubscriptionManagementScreen> {
  bool _isLoading = true;
  bool _isProcessingAction = false;
  SubManagementStatus _status = SubManagementStatus.none;
  
  // Mock Data (to be replaced by backend models)
  String _planName = '';
  String _billingPeriod = '';
  String _amount = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _autoRenew = false;
  String _paymentMethod = '';

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionData();
  }

  Future<void> _fetchSubscriptionData() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        setState(() {
          _status = SubManagementStatus.active;
          _planName = 'GovPrep Pro';
          _billingPeriod = 'Yearly';
          _amount = '1999.00';
          _startDate = DateTime.now().subtract(const Duration(days: 15));
          _endDate = DateTime.now().add(const Duration(days: 350));
          _autoRenew = true;
          _paymentMethod = 'Visa ending in 4242';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleRenewal() async {
    final bool newRenewState = !_autoRenew;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newRenewState ? 'Enable Auto-Renewal?' : 'Disable Auto-Renewal?'),
        content: Text(
          newRenewState 
              ? 'Your subscription will automatically renew at the end of the current billing cycle.' 
              : 'Your subscription will not renew automatically. You will lose access to premium features on ${DateFormat('MMM d, yyyy').format(_endDate!)} unless you renew manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newRenewState ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessingAction = true);

    try {
      // Simulate backend action
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _autoRenew = newRenewState;
          _status = newRenewState ? SubManagementStatus.active : SubManagementStatus.activeRenewalDisabled;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newRenewState ? 'Auto-renewal enabled successfully.' : 'Auto-renewal disabled successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update renewal settings. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _cancelSubscription() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: Text(
          'Are you sure you want to cancel your $_planName subscription? You will still have access until the end of your current billing period on ${DateFormat('MMM d, yyyy').format(_endDate!)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessingAction = true);

    try {
      // Simulate backend action
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _status = SubManagementStatus.cancelled;
          _autoRenew = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel subscription. Please try again or contact support.'),
            backgroundColor: Colors.red,
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
              context.go('/subscription-active');
            }
          },
        ),
        title: const Text('Subscription Management', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 800;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOverviewCard(),
                  const SizedBox(height: 24),
                  _buildBillingAndRenewalDetails(),
                  const SizedBox(height: 24),
                  _buildTimeline(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildManagementActions(),
                  const SizedBox(height: 24),
                  _buildSubscriptionBenefits(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOverviewCard(),
        const SizedBox(height: 24),
        _buildBillingAndRenewalDetails(),
        const SizedBox(height: 24),
        _buildManagementActions(),
        const SizedBox(height: 24),
        _buildSubscriptionBenefits(),
        const SizedBox(height: 24),
        _buildTimeline(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOverviewCard() {
    if (_status == SubManagementStatus.none) {
      return _buildNoSubscriptionCard();
    }

    final DateFormat formatter = DateFormat('MMM d, yyyy');
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (_status) {
      case SubManagementStatus.active:
        statusColor = Colors.green;
        statusText = 'Active';
        statusIcon = Icons.check_circle;
        break;
      case SubManagementStatus.activeRenewalDisabled:
        statusColor = Colors.orange;
        statusText = 'Active (Non-Renewing)';
        statusIcon = Icons.info;
        break;
      case SubManagementStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending Activation';
        statusIcon = Icons.hourglass_empty;
        break;
      case SubManagementStatus.cancelled:
        statusColor = Colors.grey[700]!;
        statusText = 'Cancelled (Active until expiry)';
        statusIcon = Icons.cancel;
        break;
      case SubManagementStatus.expired:
        statusColor = Colors.red;
        statusText = 'Expired';
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(_planName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4))),
          const SizedBox(height: 8),
          Text('$_billingPeriod billing • ₹$_amount', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Date', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(_startDate != null ? formatter.format(_startDate!) : 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expiry Date', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(_endDate != null ? formatter.format(_endDate!) : 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.stars, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No Active Subscription', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          Text(
            'You are currently on the free tier. Upgrade your plan to access premium benefits and better analytics.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/plans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A31F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Explore Plans', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAndRenewalDetails() {
    if (_status == SubManagementStatus.none) {
      return const SizedBox.shrink();
    }

    final DateFormat formatter = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billing & Renewal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 20),
          _buildDetailRow('Next Payment Date', _autoRenew && _endDate != null ? formatter.format(_endDate!) : 'N/A'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Renewal Amount', _autoRenew ? '₹$_amount' : 'N/A'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Auto-Renewal', _autoRenew ? 'Enabled' : 'Disabled'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Payment Method', _paymentMethod.isNotEmpty ? _paymentMethod : 'N/A'),
        ],
      ),
    );
  }

  Widget _buildManagementActions() {
    if (_status == SubManagementStatus.none) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 20),
          
          if (_status != SubManagementStatus.cancelled && _status != SubManagementStatus.expired) ...[
            ElevatedButton(
              onPressed: _isProcessingAction ? null : () => context.go('/plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Change Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isProcessingAction ? null : _toggleRenewal,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F0F11),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
              ),
              child: Text(_autoRenew ? 'Disable Auto-Renewal' : 'Enable Auto-Renewal', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
          ],
          
          if (_status == SubManagementStatus.cancelled || _status == SubManagementStatus.expired) ...[
            ElevatedButton(
              onPressed: _isProcessingAction ? null : () => context.go('/plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Renew Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
          ],

          OutlinedButton(
            onPressed: () => context.go('/billing'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
            ),
            child: const Text('View Billing History', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          if (_status == SubManagementStatus.active || _status == SubManagementStatus.activeRenewalDisabled) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isProcessingAction ? null : _cancelSubscription,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionBenefits() {
    if (_status == SubManagementStatus.none || _status == SubManagementStatus.pending) {
      return const SizedBox.shrink();
    }

    final benefits = [
      'Access to all Exam Categories',
      'Unlimited Practice Questions',
      'Advanced Performance Analytics',
      'Full-Length Mock Tests',
      'Premium Study Resources',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Benefits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          ...benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 20, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (_status == SubManagementStatus.none) {
      return const SizedBox.shrink();
    }

    final DateFormat formatter = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subscription Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 20),
          _buildTimelineItem(
            'Subscription Started',
            _startDate != null ? formatter.format(_startDate!) : 'Unknown',
            Icons.play_circle_filled,
            isFirst: true,
          ),
          _buildTimelineItem(
            'Most Recent Payment',
            _startDate != null ? formatter.format(_startDate!) : 'Unknown',
            Icons.payment,
          ),
          if (_status == SubManagementStatus.cancelled)
            _buildTimelineItem(
              'Cancellation Requested',
              formatter.format(DateTime.now()),
              Icons.cancel,
              iconColor: Colors.red,
            ),
          _buildTimelineItem(
            _autoRenew ? 'Upcoming Renewal' : 'Scheduled Expiry',
            _endDate != null ? formatter.format(_endDate!) : 'Unknown',
            _autoRenew ? Icons.autorenew : Icons.event_busy,
            isLast: true,
            iconColor: _autoRenew ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, IconData icon, {bool isFirst = false, bool isLast = false, Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 2,
              height: 12,
              color: isFirst ? Colors.transparent : const Color(0xFFE4DBF6),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF5A31F4)).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor ?? const Color(0xFF5A31F4)),
            ),
            Container(
              width: 2,
              height: isLast ? 12 : 24,
              color: isLast ? Colors.transparent : const Color(0xFFE4DBF6),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 12 : 4, bottom: isLast ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
