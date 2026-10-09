import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GettingStartedScreen extends StatelessWidget {
  const GettingStartedScreen({super.key});

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
            Text('Getting Started', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Everything you need to begin', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
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
                  _buildWelcomeCard(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('How GovPrep AI Works', isDark),
                  _buildHowItWorksFlow(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Getting Started Checklist', isDark),
                  _buildChecklist(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Quick Navigation', isDark),
                  _buildQuickNavigation(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Start with a simple routine', isDark),
                  _buildPreparationTips(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Frequently Asked Questions', isDark),
                  _buildFaqLinks(context, isDark),
                  const SizedBox(height: 32),
                  _buildSupportCard(context, isDark),
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
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title, 
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rocket_launch, color: Color(0xFF5A31F4), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to GovPrep AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 8),
                Text(
                  'Build your preparation routine, practice questions, and track your progress in one place.',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksFlow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 450;
          if (isMobile) {
            return Column(
              children: [
                _buildFlowStep(Icons.category, 'Choose Exam', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.library_books, 'Study Topics', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.edit_document, 'Practice', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.assignment, 'Mock Tests', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.auto_graph, 'Review Progress', isDark),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFlowStep(Icons.category, 'Choose\nExam', isDark),
              _buildFlowConnector(isMobile, isDark),
              _buildFlowStep(Icons.library_books, 'Study\nTopics', isDark),
              _buildFlowConnector(isMobile, isDark),
              _buildFlowStep(Icons.edit_document, 'Practice\nQuestions', isDark),
              _buildFlowConnector(isMobile, isDark),
              _buildFlowStep(Icons.assignment, 'Mock\nTests', isDark),
              _buildFlowConnector(isMobile, isDark),
              _buildFlowStep(Icons.auto_graph, 'Review\nProgress', isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlowStep(IconData icon, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF5A31F4), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFlowConnector(bool isVertical, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isVertical ? 0 : 8.0,
        vertical: isVertical ? 8.0 : 0,
      ),
      child: Icon(
        isVertical ? Icons.arrow_downward : Icons.arrow_forward,
        color: isDark ? Colors.grey[700] : Colors.grey[400],
        size: 16,
      ),
    );
  }

  Widget _buildChecklist(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildChecklistStep(
          context,
          step: 1,
          icon: Icons.person_outline,
          title: 'Set Up Your Profile',
          description: 'Review and update your basic profile information to personalize your experience.',
          actionLabel: 'Edit Profile',
          onAction: () => context.push('/profile/edit'),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildChecklistStep(
          context,
          step: 2,
          icon: Icons.track_changes_outlined,
          title: 'Choose Your Exam',
          description: 'Select your target examination to customize your study plan and materials. (e.g., TNPSC, SSC)',
          actionLabel: 'Exam Preferences',
          onAction: () => context.push('/profile/exam-preferences'),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildChecklistStep(
          context,
          step: 3,
          icon: Icons.library_books_outlined,
          title: 'Explore the Syllabus',
          description: 'Find subjects and topics relevant to your selected examination.',
          actionLabel: 'View Syllabus (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Syllabus explorer'),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildChecklistStep(
          context,
          step: 4,
          icon: Icons.edit_note_outlined,
          title: 'Start Practicing',
          description: 'Answer practice questions and review detailed explanations to build your knowledge.',
          actionLabel: 'Practice Arena (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Practice Arena'),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildChecklistStep(
          context,
          step: 5,
          icon: Icons.assignment_outlined,
          title: 'Take a Mock Test',
          description: 'Attempt full-length mock tests to simulate the real exam environment and review your results.',
          actionLabel: 'Mock Tests (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Mock Tests'),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildChecklistStep(
          context,
          step: 6,
          icon: Icons.insights_outlined,
          title: 'Track Your Progress',
          description: 'Review your learning progress and analytics through your dashboard.',
          actionLabel: 'Dashboard (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Progress Dashboard'),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildChecklistStep(
    BuildContext context, {
    required int step,
    required IconData icon,
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF5A31F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$step',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5A31F4),
                    side: const BorderSide(color: Color(0xFFE4DBF6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(actionLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavigation(BuildContext context, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _buildNavShortcut(context, Icons.dashboard_outlined, 'Dashboard', () => _showNotImplementedSnackBar(context, 'Dashboard'), isDark),
            _buildNavShortcut(context, Icons.settings_outlined, 'Settings', () => context.push('/settings'), isDark),
            _buildNavShortcut(context, Icons.assignment_outlined, 'Mock Tests', () => _showNotImplementedSnackBar(context, 'Mock Tests'), isDark),
            _buildNavShortcut(context, Icons.psychology_outlined, 'Study Prefs', () => context.push('/profile/study-preferences'), isDark),
            _buildNavShortcut(context, Icons.bookmark_outline, 'Bookmarks', () => _showNotImplementedSnackBar(context, 'Bookmarks'), isDark),
            _buildNavShortcut(context, Icons.help_outline, 'Help Center', () => context.push('/help'), isDark),
          ],
        );
      },
    );
  }

  Widget _buildNavShortcut(BuildContext context, IconData icon, String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5A31F4)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparationTips(bool isDark) {
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
          _buildTipItem(Icons.flag_outlined, 'Set a realistic daily study target.', isDark),
          const SizedBox(height: 12),
          _buildTipItem(Icons.filter_center_focus, 'Focus on one subject or topic at a time.', isDark),
          const SizedBox(height: 12),
          _buildTipItem(Icons.edit_note, 'Practice questions regularly.', isDark),
          const SizedBox(height: 12),
          _buildTipItem(Icons.rate_review_outlined, 'Review incorrect answers to understand mistakes.', isDark),
          const SizedBox(height: 12),
          _buildTipItem(Icons.assessment_outlined, 'Use mock tests to assess exam readiness.', isDark),
          const SizedBox(height: 12),
          _buildTipItem(Icons.replay, 'Revisit weaker topics to strengthen your foundation.', isDark),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5A31F4)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildFaqLinks(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _buildFaqLink(context, 'How to choose an exam', isDark),
          const Divider(height: 1),
          _buildFaqLink(context, 'How to practice questions', isDark),
          const Divider(height: 1),
          _buildFaqLink(context, 'How to attempt mock tests', isDark),
          const Divider(height: 1),
          _buildFaqLink(context, 'How to save study materials', isDark),
        ],
      ),
    );
  }

  Widget _buildFaqLink(BuildContext context, String title, bool isDark) {
    return ListTile(
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 14)),
      trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.grey[600] : Colors.grey[400]),
      onTap: () => context.push('/help/faq'),
    );
  }

  Widget _buildSupportCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
      ),
      child: Column(
        children: [
          Icon(Icons.support_agent_outlined, size: 32, color: const Color(0xFF5A31F4)),
          const SizedBox(height: 12),
          Text('Need More Help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            "Explore the Help Center or contact support through the available options.",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/help'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5A31F4),
                    side: const BorderSide(color: Color(0xFF5A31F4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Help Center'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showNotImplementedSnackBar(context, 'Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A31F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Contact Support'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
