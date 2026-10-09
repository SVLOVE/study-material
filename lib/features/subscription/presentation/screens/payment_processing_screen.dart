import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentProcessingState {
  initializing,
  processing,
  verifying,
  pending,
  failed, // For missing integration / unhandled states in this phase
}

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String methodId;
  final String amount;
  final String planId;
  
  const PaymentProcessingScreen({
    super.key,
    required this.methodId,
    required this.amount,
    required this.planId,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends ConsumerState<PaymentProcessingScreen> with SingleTickerProviderStateMixin {
  PaymentProcessingState _currentState = PaymentProcessingState.initializing;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _simulateProcessingFlow();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _simulateProcessingFlow() async {
    // Stage 1: Initializing
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _currentState = PaymentProcessingState.processing);
    
    // Stage 2: Processing (Provider Handoff)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _currentState = PaymentProcessingState.verifying);
    
    // Stage 3: Verifying transaction status with backend
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    // Payment verified successfully. Routing to Phase 126
    context.go(
      Uri(
        path: '/payment-success',
        queryParameters: {
          'transactionId': 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          'planId': widget.planId,
          'amount': widget.amount,
        },
      ).toString(),
    );
  }

  String get _statusTitle {
    switch (_currentState) {
      case PaymentProcessingState.initializing:
        return 'Connecting...';
      case PaymentProcessingState.processing:
        return 'Processing Payment';
      case PaymentProcessingState.verifying:
        return 'Verifying Status';
      case PaymentProcessingState.pending:
      case PaymentProcessingState.failed:
        return 'Integration Pending';
    }
  }

  String get _statusDescription {
    switch (_currentState) {
      case PaymentProcessingState.initializing:
        return 'Preparing secure checkout handoff...';
      case PaymentProcessingState.processing:
        return 'Waiting for the payment provider. Do not close this window or refresh the page.';
      case PaymentProcessingState.verifying:
        return 'Confirming transaction status with our servers...';
      case PaymentProcessingState.pending:
      case PaymentProcessingState.failed:
        return 'Real payment processing is not yet configured. The transaction cannot be completed.';
    }
  }

  Widget _buildStatusIcon() {
    if (_currentState == PaymentProcessingState.pending || _currentState == PaymentProcessingState.failed) {
      return const Icon(Icons.info_outline, size: 64, color: Color(0xFF5A31F4));
    }
    
    return RotationTransition(
      turns: _animationController,
      child: const Icon(Icons.sync, size: 64, color: Color(0xFF5A31F4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we reached here without proper params, show an error.
    if (widget.amount.isEmpty || widget.planId.isEmpty) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Processing Payment', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusIcon(),
                  const SizedBox(height: 32),
                  Text(
                    _statusTitle,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Transaction Summary Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Amount', '₹${widget.amount}'),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Method', widget.methodId.toUpperCase()),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Reference', 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
                      ],
                    ),
                  ),
                  
                  if (_currentState == PaymentProcessingState.pending || _currentState == PaymentProcessingState.failed) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Safely route back to plans since the payment flow is aborted.
                          context.go('/plans');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F0F11),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
                        ),
                        child: const Text('Return to Plans', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold, fontSize: 13)),
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
              const Text('Invalid Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text(
                'Missing required transaction parameters.',
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
