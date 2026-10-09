import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum SubscriptionState {
  active,
  activeRenewalDisabled,
  cancellationPending,
  cancelled,
  expired,
  none,
}

class CancelRenewSubscriptionScreen extends ConsumerStatefulWidget {
  const CancelRenewSubscriptionScreen({super.key});

  @override
  ConsumerState<CancelRenewSubscriptionScreen> createState() => _CancelRenewSubscriptionScreenState();
}

class _CancelRenewSubscriptionScreenState extends ConsumerState<CancelRenewSubscriptionScreen> {
  bool _isLoading = true;
  bool _isProcessingAction = false;

  SubscriptionState _status = SubscriptionState.active;
  String _planName = 'GovPrep Pro';
  String _billingPeriod = 'Yearly';
  double _amount = 1999.0;
  String _currency = 'INR';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _nextBillingDate;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionState();
  }

  Future<void> _fetchSubscriptionState() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));
      
      final now = DateTime.now();
      _startDate = now.subtract(const Duration(days: 45));
      _endDate = now.add(const Duration(days: 320));
      _nextBillingDate = _endDate;
      _status = SubscriptionState.active;
      
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleToggleRenewal(bool enable) async {
    setState(() => _isProcessingAction = true);
    try {
      // Simulate backend API call
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (mounted) {
        setState(() {
          if (enable) {
            _status = SubscriptionState.active;
            _nextBillingDate = _endDate;
          } else {
            _status = SubscriptionState.activeRenewalDisabled;
            _nextBillingDate = null;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable ? 'Auto-renewal enabled successfully.' : 'Auto-renewal disabled successfully.'),
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

  Future<void> _handleCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Subscription', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel your $_planName subscription?',
              style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0D5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If you cancel now, you will retain access until ${DateFormat('MMM d, yyyy').format(_endDate!)}. You will not be charged again.',
                      style: TextStyle(color: Colors.orange[900], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Subscription', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessingAction = true);
      try {
        // Simulate backend API call
        await Future.delayed(const Duration(milliseconds: 2000));
        
        if (mounted) {
          setState(() {
            _status = SubscriptionState.cancelled;
            _nextBillingDate = null;
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
              content: Text('Failed to cancel subscription. Please contact support.'),
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
              context.go('/subscription-management');
            }
          },
        ),
        title: const Text('Manage Renewal & Cancellation', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Review your subscription and manage the available renewal options.',
                              style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            _buildCurrentSubscriptionCard(),
                            const SizedBox(height: 24),
                            if (_status == SubscriptionState.active || _status == SubscriptionState.activeRenewalDisabled)
                              _buildRenewalManagementSection(),
                            const SizedBox(height: 24),
                            if (_status == SubscriptionState.active || _status == SubscriptionState.activeRenewalDisabled)
                              _buildCancellationSection(),
                            if (_status == SubscriptionState.cancelled || _status == SubscriptionState.expired)
                              _buildRenewalAfterCancellationSection(),
                            const SizedBox(height: 32),
                            _buildHelpSection(),
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

  Widget _buildCurrentSubscriptionCard() {
    if (_status == SubscriptionState.none) {
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
            Text('You do not have a subscription to manage.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
              ),
              child: const Text('Explore Plans'),
            ),
          ],
        ),
      );
    }

    final DateFormat formatter = DateFormat('MMM d, yyyy');
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_status) {
      case SubscriptionState.active:
        statusColor = Colors.green;
        statusText = 'Active';
        statusIcon = Icons.check_circle;
        break;
      case SubscriptionState.activeRenewalDisabled:
        statusColor = Colors.orange;
        statusText = 'Active (Non-Renewing)';
        statusIcon = Icons.info;
        break;
      case SubscriptionState.cancellationPending:
        statusColor = Colors.orange;
        statusText = 'Cancellation Pending';
        statusIcon = Icons.hourglass_empty;
        break;
      case SubscriptionState.cancelled:
        statusColor = Colors.grey[700]!;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
      case SubscriptionState.expired:
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
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
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
          Text(_planName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4))),
          const SizedBox(height: 8),
          Text('$_billingPeriod billing • $_currency ${_amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateColumn('Start Date', _startDate != null ? formatter.format(_startDate!) : 'N/A'),
              _buildDateColumn('Expiry Date', _endDate != null ? formatter.format(_endDate!) : 'N/A'),
              _buildDateColumn('Next Billing', _nextBillingDate != null ? formatter.format(_nextBillingDate!) : 'None'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildRenewalManagementSection() {
    final bool isAutoRenewEnabled = _status == SubscriptionState.active;

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
          const Text('Renewal Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isAutoRenewEnabled ? Icons.autorenew : Icons.block,
                color: isAutoRenewEnabled ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAutoRenewEnabled ? 'Auto-Renewal is Enabled' : 'Auto-Renewal is Disabled',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAutoRenewEnabled
                          ? 'Your subscription will automatically renew on ${DateFormat('MMM d, yyyy').format(_nextBillingDate!)} for $_currency ${_amount.toStringAsFixed(2)}.'
                          : 'Your subscription will not renew. You will lose premium access on ${DateFormat('MMM d, yyyy').format(_endDate!)}.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
              onPressed: _isProcessingAction ? null : () => _handleToggleRenewal(!isAutoRenewEnabled),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isProcessingAction
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      isAutoRenewEnabled ? 'Turn Off Renewal' : 'Enable Renewal',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cancel Subscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 16),
          Text(
            'Cancelling your subscription will stop all future billing. You will continue to have full access to GovPrep AI until the end of your current billing period (${DateFormat('MMM d, yyyy').format(_endDate!)}).',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isProcessingAction ? null : _handleCancelSubscription,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isProcessingAction
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.red)))
                  : const Text('Cancel Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalAfterCancellationSection() {
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
          const Text('Reactivate Subscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          Text(
            _status == SubscriptionState.cancelled
                ? 'Your subscription is cancelled but you still have access until ${DateFormat('MMM d, yyyy').format(_endDate!)}. You can reactivate your subscription or choose a new plan.'
                : 'Your subscription has expired. Choose a new plan to regain premium access.',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessingAction ? null : () => context.go('/plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Renew / Change Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Need help or looking for past payments?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.go('/billing'),
                child: const Text('Billing History', style: TextStyle(color: Color(0xFF5A31F4))),
              ),
              const Text('•', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () => context.go('/invoices'),
                child: const Text('Invoices', style: TextStyle(color: Color(0xFF5A31F4))),
              ),
              const Text('•', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () => context.go('/subscription-management'),
                child: const Text('Management Home', style: TextStyle(color: Color(0xFF5A31F4))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
