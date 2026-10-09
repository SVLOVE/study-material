import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum PaymentFailureType {
  declined,
  cancelled,
  timeout,
  unknown,
}

class PaymentFailedScreen extends ConsumerStatefulWidget {
  final String transactionId;
  final String planId;
  final String amount;
  final String reasonCode;

  const PaymentFailedScreen({
    super.key,
    required this.transactionId,
    required this.planId,
    required this.amount,
    this.reasonCode = 'unknown',
  });

  @override
  ConsumerState<PaymentFailedScreen> createState() => _PaymentFailedScreenState();
}

class _PaymentFailedScreenState extends ConsumerState<PaymentFailedScreen> {
  bool _isCheckingStatus = false;
  String _planName = 'Premium Plan';

  PaymentFailureType get _failureType {
    switch (widget.reasonCode.toLowerCase()) {
      case 'declined':
        return PaymentFailureType.declined;
      case 'cancelled':
        return PaymentFailureType.cancelled;
      case 'timeout':
        return PaymentFailureType.timeout;
      default:
        return PaymentFailureType.unknown;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.planId.toLowerCase().contains('plus')) {
      _planName = 'GovPrep Plus';
    } else if (widget.planId.toLowerCase().contains('pro')) {
      _planName = 'GovPrep Pro';
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _isCheckingStatus = true);

    try {
      // Simulate backend verification
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // In a real scenario, this might navigate to /payment-success if the backend
        // found a delayed success. Here, we'll assume it's still definitively failed.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment status remains unchanged (Failed).'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactionId.isEmpty && widget.planId.isEmpty) {
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFailureHero(),
                  const SizedBox(height: 24),
                  _buildTransactionSummary(),
                  const SizedBox(height: 32),
                  _buildPrimaryActions(),
                  const SizedBox(height: 32),
                  _buildSupportSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureHero() {
    String title;
    String description;
    IconData icon;
    Color color;
    Color bgColor;

    switch (_failureType) {
      case PaymentFailureType.cancelled:
        title = 'Payment Cancelled';
        description = 'You cancelled the payment process. No charges were made.';
        icon = Icons.cancel;
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case PaymentFailureType.declined:
        title = 'Payment Declined';
        description = 'Your bank or payment provider declined the transaction. Please check your details or try another method.';
        icon = Icons.error_outline;
        color = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
        break;
      case PaymentFailureType.timeout:
        title = 'Payment Timeout';
        description = 'We did not receive a response from the payment provider in time. If money was deducted, it will be refunded automatically by your bank.';
        icon = Icons.timer_off;
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case PaymentFailureType.unknown:
        title = 'Payment Unsuccessful';
        description = 'We couldn\'t confirm your payment due to an unexpected error. You can check the transaction status or try again.';
        icon = Icons.warning_amber_rounded;
        color = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
        break;
    }

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
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    if (widget.amount.isEmpty || widget.amount == '0.00') {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildSummaryRow('Plan', _planName),
          const SizedBox(height: 12),
          _buildSummaryRow('Amount Attempted', '₹${widget.amount}'),
          if (widget.transactionId.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('Reference ID', widget.transactionId),
          ],
          const SizedBox(height: 12),
          _buildSummaryRow('Date & Time', DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now())),
          const SizedBox(height: 12),
          _buildSummaryRow('Status', _failureType == PaymentFailureType.cancelled ? 'Cancelled' : 'Failed', isError: true),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions() {
    return Column(
      children: [
        if (_failureType != PaymentFailureType.cancelled)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCheckingStatus ? null : _checkPaymentStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F11),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isCheckingStatus
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Check Payment Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        if (_failureType != PaymentFailureType.cancelled) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to payment method selection
              context.go(
                Uri(
                  path: '/payment-method',
                  queryParameters: {
                    'planId': widget.planId,
                    'amount': widget.amount,
                  },
                ).toString(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A31F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Try Another Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/plans'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
            ),
            child: const Text('Return to Plans', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 20, color: Color(0xFF5A31F4)),
              SizedBox(width: 8),
              Text('Need Help?', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'If the amount was debited from your account but this screen shows failure, please do not attempt the payment again. The amount is usually refunded within 3-5 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5),
          ),
          if (widget.transactionId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Quote Reference: ${widget.transactionId}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: isError ? Colors.red : const Color(0xFF0F0F11),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
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
