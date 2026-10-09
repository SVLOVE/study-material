import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

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
            Text('Contact Support', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Find the right support option', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
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
                  _buildWelcomeCard(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Choose Your Issue', isDark),
                  _buildIssueCategories(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Support Options', isDark),
                  _buildSupportChannels(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Help Us Understand Your Issue', isDark),
                  _buildChecklist(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Quick Help Links', isDark),
                  _buildQuickLinks(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Common Support Questions', isDark),
                  _buildFaqs(context, isDark),
                  const SizedBox(height: 32),
                  _buildExpectationsCard(isDark),
                  const SizedBox(height: 32),
                  _buildFinalCta(context, isDark),
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

  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
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
                child: const Icon(Icons.headset_mic, color: Color(0xFF5A31F4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('How Can We Help You?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'We are here to help you succeed. Please check the Help Center and FAQs first, as they contain answers to most common questions.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showNotImplementedSnackBar(context, 'Create Support Ticket'),
                icon: const Icon(Icons.edit_document),
                label: const Text('Create Support Ticket (Planned)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A31F4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/help'),
                icon: const Icon(Icons.search),
                label: const Text('Browse Help Center'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey[300] : const Color(0xFF0F0F11),
                  side: BorderSide(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCategories(BuildContext context, bool isDark) {
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
            _buildCategoryCard(context, Icons.person_outline, 'Account and Login', 'Sign-in problems, verification, and recovery.', isDark),
            _buildCategoryCard(context, Icons.menu_book_outlined, 'Exam Preparation', 'Syllabus, practice, and mock-test guidance.', isDark),
            _buildCategoryCard(context, Icons.card_membership, 'Subscription', 'Plan info, access entitlements, and status.', isDark),
            _buildCategoryCard(context, Icons.payment, 'Payments and Billing', 'Pending payments and failed transactions.', isDark),
            _buildCategoryCard(context, Icons.bug_report_outlined, 'Technical Issues', 'Loading problems and unexpected errors.', isDark),
            _buildCategoryCard(context, Icons.lightbulb_outline, 'Suggestions and Feedback', 'Ideas for improving the application.', isDark),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String title, String desc, bool isDark) {
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF5A31F4), size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11)))),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13))),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showNotImplementedSnackBar(context, 'Ticket form prefilled with $title'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5A31F4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Get Help'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportChannels(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildChannelRow(
          context,
          Icons.menu_book,
          'Help Center',
          'Browse available help articles and FAQs.',
          'Browse',
          () => context.push('/help'),
          isDark,
        ),
        const SizedBox(height: 16),
        _buildChannelRow(
          context,
          Icons.email_outlined,
          'Support Ticket',
          'Submit an issue through the existing ticket workflow.',
          'Create Ticket',
          () => _showNotImplementedSnackBar(context, 'Create Support Ticket'),
          isDark,
        ),
      ],
    );
  }

  Widget _buildChannelRow(BuildContext context, IconData icon, String title, String desc, String actionText, VoidCallback onTap, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[700], size: 28),
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
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5A31F4),
              side: BorderSide(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(actionText),
          ),
        ],
      ),
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
          _buildChecklistItem('A clear description of the problem.', isDark),
          _buildChecklistItem('The screen or feature where it occurred.', isDark),
          _buildChecklistItem('The steps that led to the problem.', isDark),
          _buildChecklistItem('The approximate time it happened.', isDark),
          _buildChecklistItem('A relevant non-sensitive error message.', isDark),
          _buildChecklistItem('The device and browser information.', isDark),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C1919) : const Color(0xFFFCE8E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF5A2A2A) : const Color(0xFFF8CACA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: isDark ? Colors.red[300] : Colors.red[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Never request or provide passwords, OTPs, UPI PINs, full card numbers, or banking credentials. Only use secure upload functionality when officially instructed.',
                    style: TextStyle(color: isDark ? Colors.red[100] : Colors.red[900], fontSize: 13),
                  ),
                ),
              ],
            ),
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
          Icon(Icons.check_circle, size: 18, color: const Color(0xFF5A31F4).withValues(alpha: 0.8)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildLinkChip(context, 'Getting Started', '/help/getting-started', isDark),
        _buildLinkChip(context, 'Exam Prep Guide', '/help/exam-preparation-guide', isDark),
        _buildLinkChip(context, 'Practice Guide', '/help/practice-guide', isDark),
        _buildLinkChip(context, 'Mock Test Guide', '/help/mock-test-guide', isDark),
        _buildLinkChip(context, 'Subscription FAQ', '/help/subscription-faq', isDark),
        _buildLinkChip(context, 'Payment Help', '/help/payment-help', isDark),
        _buildLinkChip(context, 'General FAQ', '/help/faq', isDark),
        _buildLinkChip(context, 'Account Recovery', '/settings/account-recovery', isDark),
      ],
    );
  }

  Widget _buildLinkChip(BuildContext context, String label, String route, bool isDark) {
    return ActionChip(
      label: Text(label),
      onPressed: () => context.push(route),
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
      labelStyle: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13),
      side: BorderSide(color: isDark ? const Color(0xFF444444) : Colors.transparent),
    );
  }

  Widget _buildFaqs(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildFaqAccordion(context, 'Where should I report a technical problem?', 'You can report technical issues by creating a Support Ticket using the options provided on this page.', isDark),
        _buildFaqAccordion(context, 'What should I do if I cannot sign in?', 'Use the Account Recovery screen. If that fails, create a support ticket with your registered email.', isDark),
        _buildFaqAccordion(context, 'How can I report a payment issue?', 'Please review the Payment Help guide first. If unresolved, submit a ticket with your transaction reference.', isDark),
        _buildFaqAccordion(context, 'How do I check my subscription status?', 'Navigate to the Manage Subscription page to view your active plan and renewal dates.', isDark),
        _buildFaqAccordion(context, 'What information should I include in a support request?', 'Include a clear description, the screen where it happened, and any relevant non-sensitive error messages.', isDark),
        _buildFaqAccordion(context, 'How can I report a security or privacy concern?', 'Submit a Support Ticket categorized under Security/Account, and our team will prioritize its review.', isDark),
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

  Widget _buildExpectationsCard(bool isDark) {
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
          Icon(Icons.schedule, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Support Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(
                  'Use the available support options to describe your issue. Any response or resolution timeframe depends on the configured support process.',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCta(BuildContext context, bool isDark) {
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
          Text('Still Need Assistance?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'We are ready to help you resolve your issue as quickly as possible.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showNotImplementedSnackBar(context, 'Create Support Ticket'),
                icon: const Icon(Icons.edit_document),
                label: const Text('Create Support Ticket (Planned)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A31F4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/help'),
                icon: const Icon(Icons.menu_book),
                label: const Text('Help Center'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey[300] : const Color(0xFF0F0F11),
                  side: BorderSide(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
