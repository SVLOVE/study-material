import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum SubscriptionStatus {
  active,
  activeRenewalDisabled,
  pending,
  expired,
  cancelled,
  none,
}

class SubscriptionActiveScreen extends ConsumerStatefulWidget {
  const SubscriptionActiveScreen({super.key});

  @override
  ConsumerState<SubscriptionActiveScreen> createState() => _SubscriptionActiveScreenState();
}

class _SubscriptionActiveScreenState extends ConsumerState<SubscriptionActiveScreen> {
  bool _isLoading = true;
  SubscriptionStatus _status = SubscriptionStatus.none;
  
  // Mock Data (will be replaced by real backend models)
  String _planName = '';
  String _billingPeriod = '';
  String _amount = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _autoRenew = false;
  String _reference = '';

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionData();
  }

  Future<void> _fetchSubscriptionData() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 1200));
      
      if (mounted) {
        setState(() {
          // Setting mock active state
          _status = SubscriptionStatus.active;
          _planName = 'GovPrep Pro';
          _billingPeriod = 'Yearly';
          _amount = '1999.00';
          _startDate = DateTime.now().subtract(const Duration(days: 10));
          _endDate = DateTime.now().add(const Duration(days: 355));
          _autoRenew = true;
          _reference = 'SUB-GP-9482X';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
              context.go('/');
            }
          },
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFF5A31F4)),
            SizedBox(width: 8),
            Text('GovPrep AI', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
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
        child: Column(
          children: [
            _buildStatusHero(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildCurrentPlanCard(),
                      const SizedBox(height: 24),
                      _buildRenewalInfo(),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildIncludedBenefits(),
                      const SizedBox(height: 24),
                      _buildPrimaryActions(),
                    ],
                  ),
                ),
              ],
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
        _buildStatusHero(),
        const SizedBox(height: 24),
        _buildCurrentPlanCard(),
        const SizedBox(height: 24),
        _buildIncludedBenefits(),
        const SizedBox(height: 24),
        _buildRenewalInfo(),
        const SizedBox(height: 32),
        _buildPrimaryActions(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusHero() {
    if (_status == SubscriptionStatus.none) {
      return _buildNoSubscriptionHero();
    } else if (_status == SubscriptionStatus.pending) {
      return _buildPendingHero();
    } else if (_status == SubscriptionStatus.expired || _status == SubscriptionStatus.cancelled) {
      return _buildInactiveHero();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Subscription Is Active',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your plan is ready. Continue preparing for your exams with the benefits included in your subscription.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0D9).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Active: $_planName',
                  style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionHero() {
    return Container(
      width: double.infinity,
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
          const Text('No Active Subscription', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          Text(
            'You are currently on the free tier. Upgrade your plan to access premium benefits.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
            child: const Text('View Plans', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFF5A31F4)),
          const SizedBox(height: 24),
          const Text('Activation Pending', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          Text(
            'Your payment was received and we are finalizing your subscription activation. This will just take a moment.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.orange[400]),
          const SizedBox(height: 16),
          Text(
            _status == SubscriptionStatus.expired ? 'Subscription Expired' : 'Subscription Cancelled',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 12),
          Text(
            'Your previous subscription has ended. Renew to regain access to premium benefits.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
            child: const Text('Renew Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    if (_status == SubscriptionStatus.none || _status == SubscriptionStatus.pending) {
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
          const Text('Subscription Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildDetailRow('Plan', _planName),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Billing Period', _billingPeriod),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Amount', '₹$_amount'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Start Date', _startDate != null ? formatter.format(_startDate!) : 'N/A'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Expiry / Next Billing', _endDate != null ? formatter.format(_endDate!) : 'N/A'),
          if (_reference.isNotEmpty) ...[
            const Divider(height: 24, color: Color(0xFFF3F4F6)),
            _buildDetailRow('Reference ID', _reference),
          ],
        ],
      ),
    );
  }

  Widget _buildIncludedBenefits() {
    if (_status == SubscriptionStatus.none || _status == SubscriptionStatus.pending) {
      return const SizedBox.shrink();
    }

    final benefits = [
      'Access to all Exam Categories',
      'Unlimited Practice Questions',
      'Advanced Performance Analytics',
      'Full-Length Mock Tests',
      'Personalized Study Recommendations',
      'Premium Learning Materials',
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
          const Text('Included Benefits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
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

  Widget _buildRenewalInfo() {
    if (_status != SubscriptionStatus.active && _status != SubscriptionStatus.activeRenewalDisabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDF0D5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _autoRenew ? Icons.autorenew : Icons.event_busy,
            color: Colors.orange[800],
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _autoRenew ? 'Auto-Renewal Enabled' : 'Auto-Renewal Disabled',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange[900]),
                ),
                const SizedBox(height: 4),
                Text(
                  _autoRenew
                      ? 'Your subscription will automatically renew on ${_endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : 'your next billing date'}.'
                      : 'Your subscription will end on ${_endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : 'your expiry date'}. You will need to renew manually.',
                  style: TextStyle(fontSize: 13, color: Colors.orange[900], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A31F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Start Preparing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              context.go('/subscription-management');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
            ),
            child: const Text('Manage Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/billing'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF5A31F4),
          ),
          child: const Text('View Billing History', style: TextStyle(fontWeight: FontWeight.bold)),
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
