import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExamPreparationGuideScreen extends StatelessWidget {
  const ExamPreparationGuideScreen({super.key});

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
            Text('Exam Preparation Guide', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Build a focused study plan', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
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
                  _buildSectionTitle('Step-by-Step Roadmap', isDark),
                  _buildRoadmap(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Sample Weekly Study Plan', isDark),
                  _buildSamplePlan(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Effective Study Techniques', isDark),
                  _buildStudyTechniques(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Mistakes to Avoid', isDark),
                  _buildMistakes(isDark),
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
                child: const Icon(Icons.psychology, color: Color(0xFF5A31F4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Prepare with a clear strategy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Success in government exams requires more than just reading. It requires a balanced approach combining planning, practice, revision, and continuous assessment.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildPrincipleRow(Icons.check_circle_outline, 'Study consistently.', isDark),
          const SizedBox(height: 8),
          _buildPrincipleRow(Icons.check_circle_outline, 'Practice regularly.', isDark),
          const SizedBox(height: 8),
          _buildPrincipleRow(Icons.check_circle_outline, 'Review mistakes and revise.', isDark),
        ],
      ),
    );
  }

  Widget _buildPrincipleRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5A31F4)),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14)),
      ],
    );
  }

  Widget _buildRoadmap(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildRoadmapStep(
          context,
          stepNumber: 1,
          title: 'Choose Your Exam',
          content: 'Understand the target examination, eligibility requirements, exam pattern, and selection process.',
          actionLabel: 'Exam Preferences',
          onAction: () => context.push('/profile/exam-preferences'),
          isDark: isDark,
        ),
        _buildRoadmapConnector(isDark),
        _buildRoadmapStep(
          context,
          stepNumber: 2,
          title: 'Understand the Syllabus',
          content: 'Divide the syllabus into subjects and topics. Identify high-priority areas based on the official syllabus.',
          actionLabel: 'View Syllabus (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Syllabus Explorer'),
          isDark: isDark,
        ),
        _buildRoadmapConnector(isDark),
        _buildRoadmapStep(
          context,
          stepNumber: 3,
          title: 'Build a Study Schedule',
          content: 'Allocate realistic study sessions balancing new topics, practice, and revision.',
          actionLabel: 'Study Calendar (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Study Calendar'),
          isDark: isDark,
        ),
        _buildRoadmapConnector(isDark),
        _buildRoadmapStep(
          context,
          stepNumber: 4,
          title: 'Learn and Practise',
          content: 'Study one topic at a time, solve topic-based questions, and review explanations.',
          actionLabel: 'Practice Arena (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Practice Arena'),
          isDark: isDark,
        ),
        _buildRoadmapConnector(isDark),
        _buildRoadmapStep(
          context,
          stepNumber: 5,
          title: 'Take Mock Tests',
          content: 'Attempt timed tests when ready. Practise time management and review mistakes after completion.',
          actionLabel: 'Mock Tests (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Mock Tests'),
          isDark: isDark,
        ),
        _buildRoadmapConnector(isDark),
        _buildRoadmapStep(
          context,
          stepNumber: 6,
          title: 'Review and Improve',
          content: 'Monitor performance, revisit difficult topics, and adjust the study plan based on results.',
          actionLabel: 'Progress Dashboard (Planned)',
          onAction: () => _showNotImplementedSnackBar(context, 'Progress Dashboard'),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRoadmapConnector(bool isDark) {
    return Container(
      width: 2,
      height: 24,
      color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6),
      margin: const EdgeInsets.only(left: 35),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _buildRoadmapStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String content,
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
              '$stepNumber',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 8),
                Text(
                  content,
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

  Widget _buildSamplePlan(BuildContext context, bool isDark) {
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
            child: const Text('Customize for Your Schedule', style: TextStyle(color: Color(0xFF8B6B15), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(
            'This is a suggested template to balance learning, practice, and revision.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildPlanDay('Monday', 'Learn a new topic.', isDark),
          _buildPlanDay('Tuesday', 'Continue the topic and solve practice questions.', isDark),
          _buildPlanDay('Wednesday', 'Study another topic.', isDark),
          _buildPlanDay('Thursday', 'Practise questions and review mistakes.', isDark),
          _buildPlanDay('Friday', 'Revise previously studied topics.', isDark),
          _buildPlanDay('Saturday', 'Attempt a mock test or sectional test.', isDark),
          _buildPlanDay('Sunday', 'Review the week\'s learning and plan the next week.', isDark),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showNotImplementedSnackBar(context, 'Study Calendar'),
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text('View Study Calendar (Planned)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5A31F4),
              side: const BorderSide(color: Color(0xFFE4DBF6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDay(String day, String task, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(day, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF0F0F11), fontSize: 14)),
          ),
          Expanded(
            child: Text(task, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTechniques(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: crossAxisCount == 1 ? 3 : 1.2,
          children: [
            _buildTechniqueCard('Active Recall', 'Test yourself without looking at the answer first.', Icons.lightbulb_outline, const Color(0xFFFDF0D5), const Color(0xFF8B6B15), isDark),
            _buildTechniqueCard('Spaced Revision', 'Revisit topics at regular intervals.', Icons.replay, const Color(0xFFE2ECE9), const Color(0xFF2C6B59), isDark),
            _buildTechniqueCard('Practice Questions', 'Apply concepts and identify gaps.', Icons.edit_note, const Color(0xFFE4DBF6), const Color(0xFF3F19B5), isDark),
            _buildTechniqueCard('Error Review', 'Understand why an answer was incorrect.', Icons.manage_search, const Color(0xFFFCE8E8), const Color(0xFFC62828), isDark),
            _buildTechniqueCard('Time Management', 'Practise completing questions within a limit.', Icons.timer_outlined, const Color(0xFFE2F0D9), const Color(0xFF33691E), isDark),
            _buildTechniqueCard('Consistency', 'Prefer a sustainable routine over burnout.', Icons.directions_run, const Color(0xFFE3F2FD), const Color(0xFF1565C0), isDark),
          ],
        );
      },
    );
  }

  Widget _buildTechniqueCard(String title, String desc, IconData icon, Color bgColor, Color iconColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isDark ? iconColor.withValues(alpha: 0.2) : bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: isDark ? bgColor : iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Expanded(child: Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, height: 1.3), overflow: TextOverflow.fade)),
        ],
      ),
    );
  }

  Widget _buildMistakes(bool isDark) {
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
          _buildMistakeRow('Starting without understanding the syllabus.', 'Review the official syllabus and map out topics first.', isDark),
          _buildMistakeRow('Studying too many topics without revision.', 'Allocate at least one day a week solely for revision.', isDark),
          _buildMistakeRow('Memorizing answers without concepts.', 'Understand the underlying principles to handle twisted questions.', isDark),
          _buildMistakeRow('Ignoring incorrect answers.', 'Analyze why you were wrong to prevent repeating the mistake.', isDark),
          _buildMistakeRow('Taking mock tests without reviewing.', 'Spend time analyzing your performance post-test.', isDark),
          _buildMistakeRow('Setting unrealistic daily goals.', 'Start small and build consistency to avoid burnout.', isDark),
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
          Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mistake, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF0F0F11), fontSize: 14)),
                const SizedBox(height: 4),
                Text(correction, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 13)),
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
        _buildFaqAccordion(context, 'How should I begin preparing for a government exam?', 'Start by thoroughly reviewing the exam syllabus and pattern. Gather reliable study materials, and begin with foundational topics before moving to complex ones.', isDark),
        _buildFaqAccordion(context, 'How do I organize a large syllabus?', 'Break the syllabus down into subjects, and further into manageable topics. Use a study schedule to tackle one or two topics a day, and prioritize high-weightage areas.', isDark),
        _buildFaqAccordion(context, 'How often should I practise questions?', 'Daily practice is recommended. After completing a topic, solve related questions to solidify your understanding and identify knowledge gaps immediately.', isDark),
        _buildFaqAccordion(context, 'When should I start taking mock tests?', 'Start taking full-length mock tests once you have covered at least 60-70% of the syllabus. Before that, stick to topic-wise or sectional tests.', isDark),
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
          _buildLinkItem(context, 'Getting Started Guide', () => context.push('/help/getting-started'), isDark),
          _buildLinkItem(context, 'Practice Guide', () => context.push('/help/practice-guide'), isDark),
          _buildLinkItem(context, 'Mock Test Guide', () => context.push('/help/mock-test-guide'), isDark),
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
