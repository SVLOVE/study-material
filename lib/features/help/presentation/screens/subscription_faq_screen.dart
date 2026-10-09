import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionFaqScreen extends StatefulWidget {
  const SubscriptionFaqScreen({super.key});

  @override
  State<SubscriptionFaqScreen> createState() => _SubscriptionFaqScreenState();
}

class _SubscriptionFaqScreenState extends State<SubscriptionFaqScreen> {
  String _selectedCategory = 'All Questions';

  final List<String> _categories = [
    'All Questions',
    'Plans and Features',
    'Payments and Billing',
    'Renewal and Cancellation',
    'Subscription Status',
    'Refunds and Failed Payments',
    'Account and Access',
  ];

  void _showNotImplementedSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not yet implemented in this phase.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Subscription FAQ', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Plans, payments, and renewals', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOverviewCard(isDark),
                  const SizedBox(height: 32),
                  _buildCategoryNavigation(isDark),
                  const SizedBox(height: 32),
                  _buildFaqSection(isDark),
                  const SizedBox(height: 32),
                  _buildTroubleshooting(isDark),
                  const SizedBox(height: 32),
                  _buildHelpfulActions(isDark),
                  const SizedBox(height: 32),
                  _buildStillNeedHelp(isDark),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars, color: Color(0xFF5A31F4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Understand Your Subscription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Available features may depend on the plan currently offered.', isDark),
          _buildInfoRow('Plan details and prices should be checked on the official in-app subscription page.', isDark),
          _buildInfoRow('Subscription status and billing information come from verified account records.', isDark),
          _buildInfoRow('Review the plan terms before purchasing.', isDark),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/plans'),
            icon: const Icon(Icons.remove_red_eye),
            label: const Text('View Subscription Plans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A31F4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: isDark ? Colors.grey[500] : Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildCategoryNavigation(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
              selectedColor: const Color(0xFF5A31F4).withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected 
                  ? const Color(0xFF5A31F4) 
                  : (isDark ? Colors.grey[300] : Colors.grey[800]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF5A31F4) : (isDark ? const Color(0xFF444444) : Colors.transparent),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFaqSection(bool isDark) {
    final List<Widget> faqs = [];

    if (_selectedCategory == 'All Questions' || _selectedCategory == 'Plans and Features') {
      faqs.addAll([
        _buildSectionHeader('Plans and Features', isDark),
        _buildFaqItem('What subscription plans are available?', 'Please visit the View Subscription Plans page to see the latest available tiers and their pricing.', isDark),
        _buildFaqItem('What is included in each plan?', 'Each plan\'s specific entitlements, such as mock test quotas and premium material access, are detailed on the official subscription page.', isDark),
        _buildFaqItem('Can I use the application without a paid subscription?', 'Yes, the application offers a foundational set of free features. A paid subscription simply unlocks premium mock tests and advanced analytics.', isDark),
        _buildFaqItem('How can I compare available plans?', 'You can compare plans directly in the Subscription Plans screen to see feature-by-feature differences.', isDark),
        _buildFaqItem('Can plan features change over time?', 'Yes, as we add new content and tools, plan benefits may be updated. You will be notified of major changes.', isDark),
        _buildFaqItem('How can I check whether a feature is included in my plan?', 'Attempting to access a premium feature will notify you if your current plan does not cover it, and prompt an upgrade if available.', isDark),
      ]);
    }

    if (_selectedCategory == 'All Questions' || _selectedCategory == 'Payments and Billing') {
      if (faqs.isNotEmpty) faqs.add(const SizedBox(height: 24));
      faqs.addAll([
        _buildSectionHeader('Payments and Billing', isDark),
        _buildFaqItem('Which payment methods are supported?', 'We support most major Credit/Debit cards, UPI, and popular Net Banking options based on the official payment integration.', isDark),
        _buildFaqItem('How can I check whether a payment succeeded?', 'Check your Billing History screen or the payment provider\'s confirmation receipt.', isDark),
        _buildFaqItem('What should I do if money was deducted but access was not activated?', 'Wait a few minutes and refresh. If it persists, verify your active subscription status and contact support with your transaction reference.', isDark),
        _buildFaqItem('Where can I find payment details or receipts?', 'Your receipts and invoices can be downloaded directly from the Billing History screen.', isDark),
        _buildFaqItem('Why might a payment fail?', 'Payments can fail due to insufficient funds, bank server downtime, or incorrect credentials.', isDark),
        _buildFaqItem('Can I try a failed payment again?', 'Yes, wait for the previous transaction to be definitively marked as failed before retrying.', isDark),
      ]);
    }

    if (_selectedCategory == 'All Questions' || _selectedCategory == 'Renewal and Cancellation') {
      if (faqs.isNotEmpty) faqs.add(const SizedBox(height: 24));
      faqs.addAll([
        _buildSectionHeader('Renewal and Cancellation', isDark),
        _buildFaqItem('Does my subscription renew automatically?', 'This depends on the plan you selected. Check your Subscription Management page to verify auto-renewal status.', isDark),
        _buildFaqItem('How can I cancel a subscription?', 'You can cancel auto-renewal at any time through the Manage Subscription page.', isDark),
        _buildFaqItem('When does my current access end?', 'Your exact expiry date is listed on the Subscription Overview and Billing screens.', isDark),
        _buildFaqItem('Can I continue using paid features after cancellation?', 'Yes, you retain full access until the end of your current active billing cycle.', isDark),
        _buildFaqItem('What happens if a renewal payment fails?', 'Your subscription may be paused or downgraded to the free tier until payment is successfully processed.', isDark),
        _buildFaqItem('Can I change my subscription plan?', 'Yes, upgrades or changes can be initiated from the Subscription Plans screen subject to current billing rules.', isDark),
      ]);
    }

    if (_selectedCategory == 'All Questions' || _selectedCategory == 'Subscription Status') {
      if (faqs.isNotEmpty) faqs.add(const SizedBox(height: 24));
      faqs.addAll([
        _buildSectionHeader('Subscription Status', isDark),
        _buildFaqItem('How can I check my current subscription status?', 'Navigate to the Profile or Manage Subscription screen to view your active plan status.', isDark),
        _buildFaqItem('Why can I not access a paid feature?', 'Ensure you are logged into the correct account and that your subscription hasn\'t expired or failed to renew.', isDark),
        _buildFaqItem('What should I do if my payment succeeded but my plan still appears inactive?', 'Log out and log back in. If the issue persists, contact support with your payment receipt.', isDark),
        _buildFaqItem('What happens when a subscription expires?', 'You will lose access to premium features, but your saved data and progress will remain intact.', isDark),
      ]);
    }

    if (_selectedCategory == 'All Questions' || _selectedCategory == 'Refunds and Failed Payments') {
      if (faqs.isNotEmpty) faqs.add(const SizedBox(height: 24));
      faqs.addAll([
        _buildSectionHeader('Refunds and Failed Payments', isDark),
        _buildFaqItem('How can I request a refund?', 'If you are eligible under the official refund policy, you can initiate a request by creating a Support Ticket.', isDark),
        _buildFaqItem('What should I do if a payment is pending?', 'Do not initiate a second payment immediately. Wait for the bank to process the pending status.', isDark),
        _buildFaqItem('What if the same payment appears more than once?', 'If a duplicate charge occurred, retain both transaction IDs and contact support immediately.', isDark),
        _buildFaqItem('What information should I include when contacting support?', 'Include the transaction ID, date, and registered email. Never share full card numbers, OTPs, or UPI PINs.', isDark),
        _buildFaqItem('How do I report an incorrect charge?', 'File a ticket through the Help Center providing the transaction details.', isDark),
      ]);
    }

    if (_selectedCategory == 'All Questions' || _selectedCategory == 'Account and Access') {
      if (faqs.isNotEmpty) faqs.add(const SizedBox(height: 24));
      faqs.addAll([
        _buildSectionHeader('Account and Access', isDark),
        _buildFaqItem('What should I do if I signed in with a different account?', 'Subscriptions are bound to specific accounts. Ensure you log in with the exact email used during purchase.', isDark),
        _buildFaqItem('How can I contact support about an access issue?', 'Use the "Contact Support" link to reach our team for account-specific queries.', isDark),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: faqs,
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF5A31F4),
          collapsedIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
          title: Text(
            question,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(answer, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshooting(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text('Quick Troubleshooting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildTroubleshootCard('Payment succeeded, but access is missing', 'Check the payment status and signed-in account; contact support if unresolved.', Icons.error_outline, isDark),
                _buildTroubleshootCard('Payment failed', 'Check the payment provider\'s message and retry only if the status is clear.', Icons.cancel_outlined, isDark),
                _buildTroubleshootCard('Subscription appears expired', 'Verify the current plan status and expiry information.', Icons.event_busy, isDark),
                _buildTroubleshootCard('Paid feature is locked', 'Confirm the signed-in account and actual feature entitlement.', Icons.lock_outline, isDark),
                _buildTroubleshootCard('Cancellation status is unclear', 'Review the verified subscription status or contact support.', Icons.help_outline, isDark),
                _buildTroubleshootCard('Duplicate charge concern', 'Preserve transaction references and contact support.', Icons.receipt_long, isDark),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTroubleshootCard(String issue, String solution, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(issue, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 6),
                Text(solution, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Helpful Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton('View Subscription Plans', () => context.push('/plans'), isDark),
              _buildActionButton('Manage Subscription', () => context.push('/subscription-management'), isDark),
              _buildActionButton('Payment Help', () => context.push('/help/payment-help'), isDark),
              _buildActionButton('Contact Support', () => context.push('/help/contact-support'), isDark),
              _buildActionButton('Create Support Ticket (Planned)', () => _showNotImplementedSnackBar(context, 'Support Ticket'), isDark),
              _buildActionButton('Read Terms & Conditions (Planned)', () => _showNotImplementedSnackBar(context, 'Terms & Conditions'), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, bool isDark) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF5A31F4),
        side: BorderSide(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  Widget _buildStillNeedHelp(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 40, color: const Color(0xFF5A31F4)),
          const SizedBox(height: 16),
          Text('Still have questions?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'Contact our support team for account-specific billing issues. We are here to help.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.push('/help/contact-support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A31F4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
