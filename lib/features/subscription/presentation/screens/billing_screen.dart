import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum TransactionStatus {
  successful,
  pending,
  failed,
  cancelled,
  refunded,
}

class Transaction {
  final String id;
  final String providerTxnId;
  final String planName;
  final String billingPeriod;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final DateTime date;
  final String paymentMethod;
  final bool hasInvoice;

  Transaction({
    required this.id,
    required this.providerTxnId,
    required this.planName,
    required this.billingPeriod,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    required this.date,
    required this.paymentMethod,
    this.hasInvoice = false,
  });
}

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  bool _isLoading = true;
  List<Transaction> _allTransactions = [];
  String _searchQuery = '';
  TransactionStatus? _statusFilter;
  
  // Summary Data
  int _totalSuccessful = 0;
  double _totalAmountPaid = 0.0;
  DateTime? _lastPaymentDate;
  String _currentPlanName = 'None';

  @override
  void initState() {
    super.initState();
    _fetchBillingHistory();
  }

  Future<void> _fetchBillingHistory() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 1200));
      
      final now = DateTime.now();
      _allTransactions = [
        Transaction(
          id: 'txn_001',
          providerTxnId: 'PAY-892347X',
          planName: 'GovPrep Pro',
          billingPeriod: 'Yearly',
          amount: 1999.00,
          status: TransactionStatus.successful,
          date: now.subtract(const Duration(days: 15)),
          paymentMethod: 'Visa •••• 4242',
          hasInvoice: true,
        ),
        Transaction(
          id: 'txn_002',
          providerTxnId: 'PAY-881231Y',
          planName: 'GovPrep Pro',
          billingPeriod: 'Yearly',
          amount: 1999.00,
          status: TransactionStatus.failed,
          date: now.subtract(const Duration(days: 16)),
          paymentMethod: 'UPI •••• 1234',
          hasInvoice: false,
        ),
        Transaction(
          id: 'txn_003',
          providerTxnId: 'PAY-112233Z',
          planName: 'GovPrep Plus',
          billingPeriod: 'Monthly',
          amount: 499.00,
          status: TransactionStatus.refunded,
          date: now.subtract(const Duration(days: 380)),
          paymentMethod: 'MasterCard •••• 5555',
          hasInvoice: true,
        ),
      ];

      _calculateSummaries();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateSummaries() {
    _totalSuccessful = 0;
    _totalAmountPaid = 0.0;
    _lastPaymentDate = null;
    _currentPlanName = 'GovPrep Pro'; // In reality, fetch from subscription repo

    for (var txn in _allTransactions) {
      if (txn.status == TransactionStatus.successful) {
        _totalSuccessful++;
        _totalAmountPaid += txn.amount;
        if (_lastPaymentDate == null || txn.date.isAfter(_lastPaymentDate!)) {
          _lastPaymentDate = txn.date;
        }
      }
    }
  }

  List<Transaction> get _filteredTransactions {
    return _allTransactions.where((txn) {
      final matchesSearch = _searchQuery.isEmpty ||
          txn.providerTxnId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          txn.planName.toLowerCase().contains(_searchQuery.toLowerCase());
          
      final matchesFilter = _statusFilter == null || txn.status == _statusFilter;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _showTransactionDetails(Transaction txn) {
    final DateFormat formatter = DateFormat('MMM d, yyyy • h:mm a');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Transaction Details', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Reference', txn.providerTxnId),
              const SizedBox(height: 12),
              _buildDetailRow('Date', formatter.format(txn.date)),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _buildDetailRow('Plan', txn.planName),
              const SizedBox(height: 12),
              _buildDetailRow('Billing Period', txn.billingPeriod),
              const SizedBox(height: 12),
              _buildDetailRow('Method', txn.paymentMethod),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _buildDetailRow('Amount', '₹${txn.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  _buildStatusBadge(txn.status),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (txn.hasInvoice)
            TextButton.icon(
              onPressed: () {
                // Simulate downloading invoice
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading invoice...'), backgroundColor: Color(0xFF5A31F4)),
                );
              },
              icon: const Icon(Icons.download, color: Color(0xFF5A31F4)),
              label: const Text('Invoice', style: TextStyle(color: Color(0xFF5A31F4), fontWeight: FontWeight.bold)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
        title: const Text('Billing History', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Review your subscription payments and transaction records.',
                              style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                            ),
                            const SizedBox(height: 32),
                            if (isDesktop) 
                              _buildDesktopSummary()
                            else 
                              _buildMobileSummary(),
                            const SizedBox(height: 32),
                            _buildFilters(),
                            const SizedBox(height: 24),
                            _buildTransactionList(),
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

  Widget _buildDesktopSummary() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Current Plan', _currentPlanName, Icons.workspace_premium, const Color(0xFFE4DBF6), const Color(0xFF5A31F4))),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Total Paid', '₹${_totalAmountPaid.toStringAsFixed(2)}', Icons.payments, const Color(0xFFE2F0D9), Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Successful Payments', _totalSuccessful.toString(), Icons.receipt_long, const Color(0xFFFDF0D5), Colors.orange)),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Last Payment', 
            _lastPaymentDate != null ? DateFormat('MMM d, yyyy').format(_lastPaymentDate!) : 'None', 
            Icons.calendar_today, 
            const Color(0xFFE2ECE9), 
            Colors.teal
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSummary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Current Plan', _currentPlanName, Icons.workspace_premium, const Color(0xFFE4DBF6), const Color(0xFF5A31F4))),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Total Paid', '₹${_totalAmountPaid.toStringAsFixed(2)}', Icons.payments, const Color(0xFFE2F0D9), Colors.green)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Successful Payments', _totalSuccessful.toString(), Icons.receipt_long, const Color(0xFFFDF0D5), Colors.orange)),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Last Payment', 
                _lastPaymentDate != null ? DateFormat('MMM d, yyyy').format(_lastPaymentDate!) : 'None', 
                Icons.calendar_today, 
                const Color(0xFFE2ECE9), 
                Colors.teal
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Ref ID or Plan...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All', null),
              _buildFilterChip('Successful', TransactionStatus.successful),
              _buildFilterChip('Pending', TransactionStatus.pending),
              _buildFilterChip('Failed', TransactionStatus.failed),
              _buildFilterChip('Refunded', TransactionStatus.refunded),
            ],
          ),
          if (_searchQuery.isNotEmpty || _statusFilter != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _statusFilter = null;
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear Filters'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionStatus? status) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = status),
      backgroundColor: const Color(0xFFF3F4F6),
      selectedColor: const Color(0xFF5A31F4).withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: const Color(0xFF5A31F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildTransactionList() {
    final transactions = _filteredTransactions;
    
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Billing History Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text(
              _allTransactions.isEmpty 
                  ? 'Your subscription payment records will appear here when available.' 
                  : 'No transactions match your current filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final DateFormat formatter = DateFormat('MMM d, yyyy');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final txn = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
            side: const BorderSide(color: Color(0xFFF3F4F6)),
          ),
          child: InkWell(
            onTap: () => _showTransactionDetails(txn),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt, color: Colors.grey[700], size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(txn.planName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
                        const SizedBox(height: 4),
                        Text('Ref: ${txn.providerTxnId}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatter.format(txn.date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11))),
                        const SizedBox(height: 4),
                        Text(txn.billingPeriod, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${txn.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
                        const SizedBox(height: 8),
                        _buildStatusBadge(txn.status),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (txn.hasInvoice)
                    IconButton(
                      icon: const Icon(Icons.download, color: Color(0xFF5A31F4)),
                      tooltip: 'Download Invoice',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading invoice...'), backgroundColor: Color(0xFF5A31F4)),
                        );
                      },
                    )
                  else
                    const SizedBox(width: 48), // Spacer to match button width
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case TransactionStatus.successful:
        bgColor = const Color(0xFFE2F0D9);
        textColor = Colors.green;
        label = 'Successful';
        break;
      case TransactionStatus.pending:
        bgColor = const Color(0xFFFDF0D5);
        textColor = Colors.orange;
        label = 'Pending';
        break;
      case TransactionStatus.failed:
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        label = 'Failed';
        break;
      case TransactionStatus.cancelled:
        bgColor = const Color(0xFFF3F4F6);
        textColor = Colors.grey[700]!;
        label = 'Cancelled';
        break;
      case TransactionStatus.refunded:
        bgColor = const Color(0xFFE2ECE9);
        textColor = Colors.teal;
        label = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
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
