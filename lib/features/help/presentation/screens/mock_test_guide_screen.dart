import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockTestGuideScreen extends StatelessWidget {
  const MockTestGuideScreen({super.key});

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
            Text('Mock Test Guide', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Prepare confidently and manage your time', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
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
                  _buildSectionTitle('Types of Mock Tests', isDark),
                  _buildTestTypes(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Get Ready Before You Begin', isDark),
                  _buildBeforeStarting(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Understand the Test Interface', isDark),
                  _buildTestInterface(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Time Management Strategy', isDark),
                  _buildTimeStrategy(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Test-Day Best Practices', isDark),
                  _buildBestPractices(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Turn Results into Improvement', isDark),
                  _buildPostTestReview(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Common Mock Test Mistakes', isDark),
                  _buildMistakesToAvoid(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Frequently Asked Questions', isDark),
                  _buildFaqs(context, isDark),
                  const SizedBox(height: 32),
                  _buildHelpfulLinks(context, isDark),
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
                child: const Icon(Icons.assignment_turned_in, color: Color(0xFF5A31F4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Practise Before the Real Exam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mock tests simulate the real examination environment to help you prepare effectively.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildPrincipleRow(Icons.check_circle_outline, 'Experience answering questions in a timed setting.', isDark),
          const SizedBox(height: 8),
          _buildPrincipleRow(Icons.check_circle_outline, 'Practise time management and question selection.', isDark),
          const SizedBox(height: 8),
          _buildPrincipleRow(Icons.check_circle_outline, 'Identify concepts that need further revision.', isDark),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showNotImplementedSnackBar(context, 'Explore Mock Tests'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Explore Mock Tests (Planned)'),
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

  Widget _buildPrincipleRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5A31F4)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14))),
      ],
    );
  }

  Widget _buildTestTypes(bool isDark) {
    return LayoutBuilder(
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
            _buildTypeCard(Icons.article, 'Full-Length Test', 'Practise a complete examination-style session.', isDark),
            _buildTypeCard(Icons.view_agenda, 'Sectional Test', 'Focus on a particular subject or section.', isDark),
            _buildTypeCard(Icons.topic, 'Topic-Based Test', 'Practise questions associated with a selected topic.', isDark),
            _buildTypeCard(Icons.event_available, 'Daily Challenge', 'Use a regular assessment routine.', isDark),
          ],
        );
      },
    );
  }

  Widget _buildTypeCard(IconData icon, String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF5A31F4), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeStarting(bool isDark) {
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
          Text('Checklist for Success', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildChecklistItem('Check the test instructions.', isDark),
          _buildChecklistItem('Confirm the available time and question format.', isDark),
          _buildChecklistItem('Choose a quiet environment.', isDark),
          _buildChecklistItem('Ensure a stable internet connection when required.', isDark),
          _buildChecklistItem('Keep permitted materials ready, if applicable.', isDark),
          _buildChecklistItem('Avoid leaving the test unnecessarily once it begins.', isDark),
          _buildChecklistItem('Start only when ready to focus.', isDark),
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
          Icon(Icons.check_box_outlined, size: 20, color: const Color(0xFF5A31F4)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTestInterface(bool isDark) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0D5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Illustration', style: TextStyle(color: Color(0xFF8B6B15), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          _buildInterfaceItem(Icons.list_alt, 'Question and answer options.', isDark),
          _buildInterfaceItem(Icons.skip_next, 'Next and previous question controls.', isDark),
          _buildInterfaceItem(Icons.grid_view, 'Question navigation or question palette.', isDark),
          _buildInterfaceItem(Icons.flag, 'Mark for review.', isDark),
          _buildInterfaceItem(Icons.timer, 'Time remaining.', isDark),
          _buildInterfaceItem(Icons.done_all, 'Submit or finish-test control.', isDark),
        ],
      ),
    );
  }

  Widget _buildInterfaceItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTimeStrategy(bool isDark) {
    return Column(
      children: [
        _buildStrategyStage('Stage 1 — First Pass', [
          'Answer questions you understand.',
          'Avoid spending too long on one difficult question.',
          'Follow the actual test\'s navigation rules.',
        ], isDark),
        const SizedBox(height: 16),
        _buildStrategyStage('Stage 2 — Review', [
          'Revisit unanswered or marked questions if permitted.',
          'Check for mistakes and incomplete responses.',
        ], isDark),
        const SizedBox(height: 16),
        _buildStrategyStage('Stage 3 — Final Check', [
          'Review answers where time permits.',
          'Verify the submission state.',
          'Submit before the actual timer expires.',
        ], isDark),
        const SizedBox(height: 16),
        Text(
          'Note: Time allocation depends on the examination\'s actual duration, question count, and marking rules.',
          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildStrategyStage(String title, List<String> points, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF5A31F4))),
          const SizedBox(height: 12),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF5A31F4))),
                Expanded(child: Text(p, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBestPractices(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3.5,
          children: [
            _buildTipCard(Icons.menu_book, 'Read Instructions', 'Understand the rules before starting.', isDark),
            _buildTipCard(Icons.self_improvement, 'Stay Calm', 'Approach questions methodically.', isDark),
            _buildTipCard(Icons.timer, 'Manage Time', 'Move on when a question takes too long.', isDark),
            _buildTipCard(Icons.manage_search, 'Read Carefully', 'Look for keywords and qualifiers.', isDark),
            _buildTipCard(Icons.flag, 'Use Review Tools', 'Revisit uncertain answers when permitted.', isDark),
            _buildTipCard(Icons.done_all, 'Check Submission', 'Confirm that the test has been submitted.', isDark),
          ],
        );
      },
    );
  }

  Widget _buildTipCard(IconData icon, String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5A31F4), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTestReview(BuildContext context, bool isDark) {
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
          Text('4-Step Review Process', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildNumberedRow('1', 'Review Performance', 'Examine the result information provided.', isDark),
          const SizedBox(height: 12),
          _buildNumberedRow('2', 'Understand Mistakes', 'Read explanations and identify relevant concepts.', isDark),
          const SizedBox(height: 12),
          _buildNumberedRow('3', 'Identify Learning Gaps', 'Find subjects or topics requiring more attention.', isDark),
          const SizedBox(height: 12),
          _buildNumberedRow('4', 'Plan the Next Session', 'Return to practice or revision based on findings.', isDark),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF444444) : const Color(0xFFE4DBF6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sample Post-Test Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 8),
                Text('Topic reviewed: Sample Topic A', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13)),
                Text('Observation: Several mistakes involved the same concept.', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13)),
                Text('Suggested action: Review the concept and attempt related practice questions.', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedRow(String number, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Text(number, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[800])),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF0F0F11), fontSize: 14)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMistakesToAvoid(bool isDark) {
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
          _buildMistakeRow('Starting without reading instructions', 'Review the rules first.', isDark),
          _buildMistakeRow('Spending too long on one question', 'Follow a flexible time-management strategy.', isDark),
          _buildMistakeRow('Guessing without understanding', 'Read carefully and apply marking rules.', isDark),
          _buildMistakeRow('Ignoring explanations', 'Review incorrect and uncertain answers.', isDark),
          _buildMistakeRow('Taking tests without revision', 'Schedule follow-up study.', isDark),
          _buildMistakeRow('Comparing scores without context', 'Focus on personal learning.', isDark),
        ],
      ),
    );
  }

  Widget _buildMistakeRow(String mistake, String correction, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, size: 20, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mistake, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF0F0F11), fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right_alt, size: 16, color: const Color(0xFF5A31F4)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(correction, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqs(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildFaqAccordion(context, 'When should I start taking mock tests?', 'Start incorporating mock tests into your routine once you have built a strong foundation in at least a few subjects.', isDark),
        _buildFaqAccordion(context, 'How often should I take a mock test?', 'This depends on your exam timeline. Weekly tests are common, but closer to the exam, you may want to increase the frequency.', isDark),
        _buildFaqAccordion(context, 'Should I take full-length or sectional tests first?', 'Begin with sectional or topic-based tests to build confidence, and move to full-length tests to practise stamina and overall time management.', isDark),
        _buildFaqAccordion(context, 'What should I do after a low score?', 'Analyze the results. Identify whether mistakes were due to lack of knowledge, time pressure, or misreading questions. Use this insight to adjust your study plan.', isDark),
        _buildFaqAccordion(context, 'How should I review incorrect answers?', 'Read the explanations thoroughly, revisit your notes on those concepts, and try solving similar questions without assistance.', isDark),
        _buildFaqAccordion(context, 'Do all examinations have negative marking?', 'No. Test rules, including negative marking, vary significantly across different exams. Always check the official guidelines.', isDark),
        _buildFaqAccordion(context, 'What should I do if a test is interrupted?', 'If supported by the platform, you may be able to resume the test. Otherwise, ensure you have a stable connection and a quiet environment before starting.', isDark),
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

  Widget _buildHelpfulLinks(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 24, color: const Color(0xFF5A31F4)),
              const SizedBox(width: 12),
              Text('Helpful Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 16),
          _buildLinkItem(context, 'Exam Preparation Guide', () => context.push('/help/exam-preparation-guide'), isDark),
          _buildLinkItem(context, 'Practice Guide', () => context.push('/help/practice-guide'), isDark),
          _buildLinkItem(context, 'Study Calendar (Planned)', () => _showNotImplementedSnackBar(context, 'Study Calendar'), isDark),
          _buildLinkItem(context, 'Saved Questions (Planned)', () => _showNotImplementedSnackBar(context, 'Saved Questions'), isDark),
          _buildLinkItem(context, 'Help Center', () => context.push('/help'), isDark),
        ],
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, String title, VoidCallback onTap, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 14)),
      trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.grey[600] : Colors.grey[400]),
      onTap: onTap,
    );
  }
}
