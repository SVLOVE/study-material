import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final String transactionId;
  final String planId;
  final String amount;
  
  const PaymentSuccessScreen({
    super.key,
    required this.transactionId,
    required this.planId,
    required this.amount,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  bool _isLoading = true;
  bool _isSubscriptionActive = false;
  String? _transactionDate;
  String _planName = 'Premium Plan'; // Default fallback

  @override
  void initState() {
    super.initState();
    _verifyPaymentAndSubscription();
  }

  Future<void> _verifyPaymentAndSubscription() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate backend verification of the transaction and subscription activation
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isSubscriptionActive = true;
          _transactionDate = DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now());
          
          if (widget.planId.toLowerCase().contains('plus')) {
            _planName = 'GovPrep Plus';
          } else if (widget.planId.toLowerCase().contains('pro')) {
            _planName = 'GovPrep Pro';
          }
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
    if (widget.transactionId.isEmpty) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent navigating back to processing
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
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSuccessHero(),
                        const SizedBox(height: 24),
                        _buildPaymentSummary(),
                        const SizedBox(height: 24),
                        _buildSubscriptionStatus(),
                        const SizedBox(height: 32),
                        _buildPrimaryActions(),
                        const SizedBox(height: 24),
                        _buildFooterInfo(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessHero() {
    return Container(
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
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 48, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Successful!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment has been confirmed.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0D9).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: Colors.green),
                SizedBox(width: 6),
                Text('Transaction confirmed', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
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
          const Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildSummaryRow('Plan', _planName),
          const SizedBox(height: 12),
          _buildSummaryRow('Amount Paid', '₹${widget.amount}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Reference ID', widget.transactionId),
          if (_transactionDate != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('Date & Time', _transactionDate!),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _isSubscriptionActive ? Icons.check_circle : Icons.hourglass_top,
            color: _isSubscriptionActive ? Colors.green : const Color(0xFF5A31F4),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSubscriptionActive ? 'Subscription Active' : 'Activation Pending',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                ),
                const SizedBox(height: 4),
                Text(
                  _isSubscriptionActive 
                      ? 'Your account has been upgraded successfully. You now have access to all premium features and study materials.'
                      : 'We are finalizing your subscription activation. This usually takes just a moment.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
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
            onPressed: () => context.go('/subscription-active'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
            ),
            child: const Text('View Subscription Details', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Text(
          'It may take a short time for all premium benefits to reflect across the application.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Need help? ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            InkWell(
              onTap: () {
                // Future route for support
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Invalid Verification Context', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text(
                'Missing transaction reference. We cannot verify your payment status.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/plans'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F11),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Return to Plans'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
