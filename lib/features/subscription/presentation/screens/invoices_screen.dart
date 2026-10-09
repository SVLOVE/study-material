import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum InvoiceStatus {
  paid,
  pending,
  voided,
}

class InvoiceRecord {
  final String id;
  final String invoiceNumber;
  final String planName;
  final double amount;
  final String currency;
  final DateTime issueDate;
  final String transactionRef;
  final InvoiceStatus status;
  final String downloadUrl;

  InvoiceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.planName,
    required this.amount,
    this.currency = 'INR',
    required this.issueDate,
    required this.transactionRef,
    required this.status,
    required this.downloadUrl,
  });
}

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  bool _isLoading = true;
  List<InvoiceRecord> _allInvoices = [];
  String _searchQuery = '';
  
  // Summary Data
  int _totalInvoices = 0;
  DateTime? _lastInvoiceDate;
  double _lastInvoiceAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final now = DateTime.now();
      _allInvoices = [
        InvoiceRecord(
          id: 'inv_1001',
          invoiceNumber: 'INV-2026-0001',
          planName: 'GovPrep Pro',
          amount: 1999.00,
          issueDate: now.subtract(const Duration(days: 15)),
          transactionRef: 'PAY-892347X',
          status: InvoiceStatus.paid,
          downloadUrl: 'mock_url_1',
        ),
        InvoiceRecord(
          id: 'inv_1002',
          invoiceNumber: 'INV-2025-0842',
          planName: 'GovPrep Plus',
          amount: 499.00,
          issueDate: now.subtract(const Duration(days: 380)),
          transactionRef: 'PAY-112233Z',
          status: InvoiceStatus.paid,
          downloadUrl: 'mock_url_2',
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
    _totalInvoices = _allInvoices.length;
    
    if (_allInvoices.isNotEmpty) {
      // Find the most recent invoice
      final latest = _allInvoices.reduce((a, b) => a.issueDate.isAfter(b.issueDate) ? a : b);
      _lastInvoiceDate = latest.issueDate;
      _lastInvoiceAmount = latest.amount;
    }
  }

  List<InvoiceRecord> get _filteredInvoices {
    return _allInvoices.where((inv) {
      return _searchQuery.isEmpty ||
          inv.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.transactionRef.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.planName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _downloadInvoice(InvoiceRecord invoice) async {
    // In a real application, this would fetch a signed URL from Supabase Storage
    // and use url_launcher or a downloading package to save the PDF.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF5A31F4)),
            SizedBox(width: 24),
            Text('Generating secure link...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1)); // Simulate network request
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${invoice.invoiceNumber}...'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
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
              context.go('/billing');
            }
          },
        ),
        title: const Text('Invoices', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
                              'View and access invoices for your subscription payments.',
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
                            _buildInvoiceList(isDesktop),
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
        Expanded(child: _buildSummaryCard('Total Invoices', _totalInvoices.toString(), Icons.receipt, const Color(0xFFE4DBF6), const Color(0xFF5A31F4))),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Latest Invoice Date', 
            _lastInvoiceDate != null ? DateFormat('MMM d, yyyy').format(_lastInvoiceDate!) : 'None', 
            Icons.calendar_today, 
            const Color(0xFFE2F0D9), 
            Colors.green
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Latest Amount', 
            _lastInvoiceAmount > 0 ? '₹${_lastInvoiceAmount.toStringAsFixed(2)}' : '₹0.00', 
            Icons.payments, 
            const Color(0xFFFDF0D5), 
            Colors.orange
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
            Expanded(child: _buildSummaryCard('Total', _totalInvoices.toString(), Icons.receipt, const Color(0xFFE4DBF6), const Color(0xFF5A31F4))),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Latest Amount', 
                _lastInvoiceAmount > 0 ? '₹${_lastInvoiceAmount.toStringAsFixed(2)}' : '₹0.00', 
                Icons.payments, 
                const Color(0xFFFDF0D5), 
                Colors.orange
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          'Latest Invoice Date', 
          _lastInvoiceDate != null ? DateFormat('MMM d, yyyy').format(_lastInvoiceDate!) : 'None', 
          Icons.calendar_today, 
          const Color(0xFFE2F0D9), 
          Colors.green
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
                hintText: 'Search by Invoice No. or Ref...',
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
          if (_searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(bool isDesktop) {
    final invoices = _filteredInvoices;
    
    if (invoices.isEmpty) {
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
            Icon(Icons.description_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Invoices Available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text(
              _allInvoices.isEmpty 
                  ? 'Invoices for eligible payments will appear here when available.' 
                  : 'No invoices match your current search.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final DateFormat formatter = DateFormat('MMM d, yyyy');

    if (isDesktop) {
      // Table layout for desktop
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  const Expanded(flex: 2, child: Text('INVOICE NO.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  const Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  const Expanded(flex: 2, child: Text('PLAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  const Expanded(flex: 2, child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  const Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  SizedBox(width: 100, child: Container()), // Action column space
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final inv = invoices[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(formatter.format(inv.issueDate), style: TextStyle(color: Colors.grey[700])),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(inv.planName, style: TextStyle(color: Colors.grey[700])),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('₹${inv.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildStatusBadge(inv.status),
                      ),
                      SizedBox(
                        width: 100,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _downloadInvoice(inv),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('PDF'),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF5A31F4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      // Card layout for mobile
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final inv = invoices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), 
              side: const BorderSide(color: Color(0xFFF3F4F6)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
                      _buildStatusBadge(inv.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date', formatter.format(inv.issueDate)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Plan', inv.planName),
                  const SizedBox(height: 8),
                  _buildDetailRow('Amount', '₹${inv.amount.toStringAsFixed(2)}', isBold: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadInvoice(inv),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5A31F4),
                        side: const BorderSide(color: Color(0xFFE4DBF6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value, 
          style: TextStyle(
            color: const Color(0xFF0F0F11), 
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
            fontSize: 14
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        bgColor = const Color(0xFFE2F0D9);
        textColor = Colors.green;
        label = 'Paid';
        break;
      case InvoiceStatus.pending:
        bgColor = const Color(0xFFFDF0D5);
        textColor = Colors.orange;
        label = 'Pending';
        break;
      case InvoiceStatus.voided:
        bgColor = const Color(0xFFF3F4F6);
        textColor = Colors.grey[700]!;
        label = 'Voided';
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
}
