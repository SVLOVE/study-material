import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  PaymentMethodOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final String amount;
  final String planId;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    required this.planId,
  });

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _selectedMethodId;
  
  List<PaymentMethodOption> _availableMethods = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend configuration fetch for supported methods
      await Future.delayed(const Duration(milliseconds: 700));
      
      if (mounted) {
        setState(() {
          _availableMethods = [
            PaymentMethodOption(
              id: 'upi',
              name: 'UPI',
              description: 'Pay using any supported UPI app.',
              icon: Icons.qr_code_scanner,
            ),
            PaymentMethodOption(
              id: 'card',
              name: 'Debit or Credit Card',
              description: 'Securely processed by our payment partner.',
              icon: Icons.credit_card,
            ),
            PaymentMethodOption(
              id: 'netbanking',
              name: 'Net Banking',
              description: 'Pay directly from your bank account.',
              icon: Icons.account_balance,
            ),
          ];
          
          if (_availableMethods.isNotEmpty) {
            _selectedMethodId = _availableMethods.first.id;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _proceedToPayment() async {
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method to proceed.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment preparation handoff
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() => _isProcessing = false);
      
      // Navigate to Payment Processing screen
      context.go(
        Uri(
          path: '/payment-processing',
          queryParameters: {
            'planId': widget.planId,
            'amount': widget.amount,
            'methodId': _selectedMethodId,
          },
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amount.isEmpty || widget.planId.isEmpty) {
      return _buildErrorState();
    }

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
              context.go('/plans');
            }
          },
        ),
        title: const Text('Payment Method', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)))
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildPaymentMethodsList(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildCompactOrderSummary(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildCompactOrderSummary(),
        const SizedBox(height: 24),
        _buildPaymentMethodsList(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose how you would like to pay.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a secure payment method to complete your subscription.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsList() {
    if (_availableMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Icon(Icons.payment, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Payment Methods Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text(
              'We could not load the supported payment methods at this time. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _availableMethods.map((method) {
        final isSelected = _selectedMethodId == method.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => setState(() => _selectedMethodId = method.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFFF3F4F6),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4DBF6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(method.icon, color: const Color(0xFF5A31F4)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.description,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[400]!,
                        width: isSelected ? 6 : 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
          const Text('Amount to Pay', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            '₹${widget.amount}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 24),
          
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your payment information is securely processed by our authorized payment partner.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isProcessing || _selectedMethodId == null) ? null : _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isProcessing 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Proceed to Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
              const Text('Invalid Checkout State', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text(
                'We could not verify your order amount. Please return to checkout and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/plans');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F11),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Return to Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
