import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentHelpScreen extends StatelessWidget {
  const PaymentHelpScreen({super.key});

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
            Text('Payment Help', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Troubleshoot payment and access issues', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
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
                  _buildStatusOverview(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Quick Troubleshooting', isDark),
                  _buildTroubleshooting(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Step-by-Step Payment Recovery', isDark),
                  _buildRecoveryFlow(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Transaction Information Checklist', isDark),
                  _buildChecklist(isDark),
                  const SizedBox(height: 32),
                  _buildSafetyNotice(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Frequently Asked Questions', isDark),
                  _buildFaqs(context, isDark),
                  const SizedBox(height: 32),
                  _buildSupportActions(context, isDark),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Text(
        title, 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
      ),
    );
  }

  Widget _buildStatusOverview(bool isDark) {
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
          Text('What happened to your payment?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildStatusRow(Icons.check_circle, 'Successful', 'The payment provider has confirmed the transaction. If paid access is still unavailable, verify your signed-in account and subscription status.', Colors.green, isDark),
          const SizedBox(height: 16),
          _buildStatusRow(Icons.pending, 'Pending', 'The transaction has not reached a confirmed final state. Check the provider or bank before attempting another payment.', Colors.orange, isDark),
          const SizedBox(height: 16),
          _buildStatusRow(Icons.cancel, 'Failed', 'The transaction was not confirmed as successful. Review the provider\'s message before retrying.', Colors.red, isDark),
          const SizedBox(height: 16),
          _buildStatusRow(Icons.help, 'Unknown or Unconfirmed', 'The available information is insufficient to establish the final outcome. Avoid making another payment until the status is clarified.', Colors.grey, isDark),
        ],
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String title, String desc, MaterialColor color, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: isDark ? color[400] : color[700], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTroubleshooting(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildIssueCard('Money Deducted, but Payment Shows Pending', [
              'Check the transaction status with your provider or bank.',
              'Keep the transaction reference available.',
              'Avoid duplicate payments while the outcome is unclear.',
            ], isDark),
            _buildIssueCard('Payment Successful, but Subscription Is Inactive', [
              'Verify that the correct account is signed in.',
              'Check the actual subscription status.',
              'Contact support if the transaction is not reflected.',
            ], isDark),
            _buildIssueCard('Payment Failed', [
              'Read the provider\'s failure message.',
              'Check the payment method and available funds.',
              'Retry only after the earlier transaction\'s status is clear.',
            ], isDark),
            _buildIssueCard('Possible Duplicate Charge', [
              'Review the actual transaction records.',
              'Record the relevant transaction references.',
              'Contact the appropriate support channel.',
            ], isDark),
            _buildIssueCard('Payment Page Did Not Load', [
              'Check the internet connection.',
              'Refresh only when doing so will not repeat an uncertain transaction.',
              'Return to the application using normal navigation.',
            ], isDark),
            _buildIssueCard('Receipt or Transaction Details Missing', [
              'Check the actual payment history or provider confirmation.',
              'Contact support if the transaction cannot be located.',
            ], isDark),
          ],
        );
      },
    );
  }

  Widget _buildIssueCard(String title, List<String> points, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: points.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 12)),
                      Expanded(child: Text(p, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryFlow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _buildRecoveryStep('1', 'Check Status', 'Confirm whether the provider reports the transaction as successful, pending, or failed.', isDark),
          _buildRecoveryConnector(isDark),
          _buildRecoveryStep('2', 'Verify Your Account', 'Make sure the application is signed in with the intended account.', isDark),
          _buildRecoveryConnector(isDark),
          _buildRecoveryStep('3', 'Check Subscription Access', 'Use the existing subscription screen to inspect your current entitlement.', isDark),
          _buildRecoveryConnector(isDark),
          _buildRecoveryStep('4', 'Collect Transaction Details', 'Keep the date, amount, payment method type, and transaction reference available.', isDark),
          _buildRecoveryConnector(isDark),
          _buildRecoveryStep('5', 'Contact Support', 'Use the existing support route if the issue remains unresolved.', isDark),
        ],
      ),
    );
  }

  Widget _buildRecoveryStep(String step, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(step, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5A31F4))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryConnector(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      width: 2,
      height: 20,
      color: isDark ? const Color(0xFF333333) : const Color(0xFFE2ECE9),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _buildChecklist(bool isDark) {
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
          Text('Information needed for support:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildChecklistItem('Approximate transaction date and time.', isDark),
          _buildChecklistItem('Amount and currency.', isDark),
          _buildChecklistItem('Transaction or provider reference.', isDark),
          _buildChecklistItem('Payment method type.', isDark),
          _buildChecklistItem('Transaction status shown by the provider.', isDark),
          _buildChecklistItem('Relevant application account email.', isDark),
          _buildChecklistItem('Brief description of the issue.', isDark),
          const SizedBox(height: 16),
          Text(
            'Provide only the information required through an authorized support channel.',
            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: const Color(0xFF5A31F4)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSafetyNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C1919) : const Color(0xFFFCE8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF5A2A2A) : const Color(0xFFF8CACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 24, color: isDark ? Colors.red[300] : Colors.red[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Keep Your Payment Information Safe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.red[100] : Colors.red[900])),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSafetyRow('Never share an OTP, password, UPI PIN, or card security code with support.', isDark),
          _buildSafetyRow('Use only the application\'s verified payment flow.', isDark),
          _buildSafetyRow('Do not pay through unofficial links or personal accounts.', isDark),
          _buildSafetyRow('Check transaction details before retrying a payment.', isDark),
          _buildSafetyRow('Use authorized support channels for billing concerns.', isDark),
        ],
      ),
    );
  }

  Widget _buildSafetyRow(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: isDark ? Colors.red[200] : Colors.red[800], fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.red[100] : Colors.red[900], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildFaqs(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildFaqAccordion(context, 'What should I do if money was deducted but the payment is pending?', 'Do not try to pay again. Wait for the bank or payment provider to confirm the final status of the transaction.', isDark),
        _buildFaqAccordion(context, 'Why is my subscription inactive after a successful payment?', 'There may be a slight delay in activating access. Refresh the app, ensure you are logged into the correct account, and contact support if the issue persists.', isDark),
        _buildFaqAccordion(context, 'Should I pay again if I have not received confirmation?', 'No. Retrying while a payment is unconfirmed can lead to duplicate charges. Verify the status first.', isDark),
        _buildFaqAccordion(context, 'How can I find my transaction reference?', 'Check the email receipt sent to your registered address or look at your bank statement for the reference number.', isDark),
        _buildFaqAccordion(context, 'What should I do about a possible duplicate charge?', 'Collect the references for all charges and contact our support team. Verified duplicate payments are eligible for a refund.', isDark),
        _buildFaqAccordion(context, 'How can I request help with a payment?', 'Use the "Contact Support" or "Create Support Ticket" options on this page to securely reach our team.', isDark),
        _buildFaqAccordion(context, 'What information should I never share with support?', 'Never share your passwords, OTPs, UPI PINs, CVV codes, full credit card numbers, or any banking credentials.', isDark),
      ],
    );
  }

  Widget _buildFaqAccordion(BuildContext context, String question, String answer, bool isDark) {
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
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
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

  Widget _buildSupportActions(BuildContext context, bool isDark) {
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
          Icon(Icons.help_outline, size: 40, color: const Color(0xFF5A31F4)),
          const SizedBox(height: 16),
          Text('Still Having a Payment Problem?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.push('/help/contact-support'),
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A31F4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showNotImplementedSnackBar(context, 'Create Support Ticket'),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Create Support Ticket (Planned)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5A31F4),
                  side: BorderSide(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/help/subscription-faq'),
                icon: const Icon(Icons.article_outlined),
                label: const Text('Subscription FAQ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey[300] : const Color(0xFF0F0F11),
                  side: BorderSide(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
