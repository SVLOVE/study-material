import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PracticeGuideScreen extends StatelessWidget {
  const PracticeGuideScreen({super.key});

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
            Text('Practice Guide', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Strengthen your exam readiness', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
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
                  _buildSectionTitle('How Practice Works', isDark),
                  _buildHowItWorksFlow(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Question Selection Guide', isDark),
                  _buildQuestionSelection(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Difficulty Levels', isDark),
                  _buildDifficultyLevels(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Smart Practice Tips', isDark),
                  _buildPracticeTips(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Mistakes Are Part of Learning', isDark),
                  _buildMistakesLearning(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Build an Effective Practice Routine', isDark),
                  _buildPracticeRoutine(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Common Practice Mistakes', isDark),
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
                child: const Icon(Icons.edit_note, color: Color(0xFF5A31F4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Practise with Purpose', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Practice questions are the most effective way to test your understanding and improve retention.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildPrincipleRow(Icons.check_circle_outline, 'Practise one topic at a time.', isDark),
          const SizedBox(height: 8),
          _buildPrincipleRow(Icons.check_circle_outline, 'Understand why an answer is correct or incorrect.', isDark),
          const SizedBox(height: 8),
          _buildPrincipleRow(Icons.check_circle_outline, 'Revisit questions and concepts that need more attention.', isDark),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showNotImplementedSnackBar(context, 'Practice Arena'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Open Practice Arena (Planned)'),
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
          final isMobile = constraints.maxWidth < 500;
          if (isMobile) {
            return Column(
              children: [
                _buildFlowStep(Icons.category, 'Choose an Exam', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.library_books, 'Select a Subject', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.topic, 'Choose a Topic', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.question_answer, 'Answer Questions', isDark),
                _buildFlowConnector(isMobile, isDark),
                _buildFlowStep(Icons.rate_review, 'Review and Improve', isDark),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildFlowStep(Icons.category, 'Choose an\nExam', isDark)),
              _buildFlowConnector(isMobile, isDark),
              Expanded(child: _buildFlowStep(Icons.library_books, 'Select a\nSubject', isDark)),
              _buildFlowConnector(isMobile, isDark),
              Expanded(child: _buildFlowStep(Icons.topic, 'Choose a\nTopic', isDark)),
              _buildFlowConnector(isMobile, isDark),
              Expanded(child: _buildFlowStep(Icons.question_answer, 'Answer\nQuestions', isDark)),
              _buildFlowConnector(isMobile, isDark),
              Expanded(child: _buildFlowStep(Icons.rate_review, 'Review and\nImprove', isDark)),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF5A31F4), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFlowConnector(bool isVertical, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isVertical ? 0 : 8.0,
        vertical: isVertical ? 8.0 : 24.0,
      ),
      child: Icon(
        isVertical ? Icons.arrow_downward : Icons.arrow_forward,
        color: isDark ? Colors.grey[700] : Colors.grey[400],
        size: 16,
      ),
    );
  }

  Widget _buildQuestionSelection(bool isDark) {
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
          Text('Organizing Practice Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'Begin with manageable questions and increase difficulty as your understanding improves. You can filter questions by:',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Exam Category', isDark),
              _buildFilterChip('Subject', isDark),
              _buildFilterChip('Topic', isDark),
              _buildFilterChip('Difficulty Level', isDark),
              _buildFilterChip('Question Type', isDark),
              _buildFilterChip('Bookmarked/Attempted', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF444444) : const Color(0xFFE2ECE9)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[800])),
    );
  }

  Widget _buildDifficultyLevels(bool isDark) {
    return Column(
      children: [
        _buildDifficultyCard('Easy', 'Focus on basic concepts and definitions to build familiarity with a topic.', const Color(0xFFE2F0D9), const Color(0xFF33691E), isDark),
        const SizedBox(height: 16),
        _buildDifficultyCard('Medium', 'Apply concepts to different question formats to improve accuracy and consistency.', const Color(0xFFFDF0D5), const Color(0xFF8B6B15), isDark),
        const SizedBox(height: 16),
        _buildDifficultyCard('Hard', 'Challenge deeper understanding with complex reasoning and multi-step problems.', const Color(0xFFFCE8E8), const Color(0xFFC62828), isDark),
      ],
    );
  }

  Widget _buildDifficultyCard(String title, String desc, Color bgColor, Color textColor, bool isDark) {
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: isDark ? textColor.withValues(alpha: 0.2) : bgColor, borderRadius: BorderRadius.circular(12)),
            child: Text(title, style: TextStyle(color: isDark ? bgColor : textColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(desc, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPracticeTips(bool isDark) {
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
            _buildTipCard(Icons.visibility_outlined, 'Read Carefully', 'Identify what the question is asking before answering.', isDark),
            _buildTipCard(Icons.person_outline, 'Attempt Independently', 'Try solving before viewing an explanation.', isDark),
            _buildTipCard(Icons.lightbulb_outline, 'Understand Explanations', 'Learn the reasoning behind the correct answer.', isDark),
            _buildTipCard(Icons.troubleshoot, 'Track Repeated Errors', 'Recognize concepts that cause recurring mistakes.', isDark),
            _buildTipCard(Icons.replay, 'Revisit Difficult Questions', 'Return to challenging concepts after revision.', isDark),
            _buildTipCard(Icons.event_available, 'Practise Consistently', 'Use realistic sessions that fit your schedule.', isDark),
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

  Widget _buildMistakesLearning(BuildContext context, bool isDark) {
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
          Text('4-Step Review Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildNumberedRow('1', 'Identify the concept behind the incorrect answer.', isDark),
          const SizedBox(height: 12),
          _buildNumberedRow('2', 'Read the explanation and understand the correct reasoning.', isDark),
          const SizedBox(height: 12),
          _buildNumberedRow('3', 'Revisit the relevant notes or syllabus topic.', isDark),
          const SizedBox(height: 12),
          _buildNumberedRow('4', 'Attempt a similar question to check understanding.', isDark),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showNotImplementedSnackBar(context, 'Saved Questions'),
            icon: const Icon(Icons.bookmark_outline, size: 18),
            label: const Text('View Saved Questions (Planned)'),
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

  Widget _buildNumberedRow(String number, String text, bool isDark) {
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
        Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14))),
      ],
    );
  }

  Widget _buildPracticeRoutine(bool isDark) {
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
              color: const Color(0xFFE2ECE9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Example Session — Adjust to Your Needs', style: TextStyle(color: Color(0xFF2C6B59), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          _buildRoutineStep('Start', 'Choose one subject and topic.', isDark),
          _buildRoutineStep('Practice', 'Answer a manageable set of questions.', isDark),
          _buildRoutineStep('Review', 'Read explanations for uncertain and incorrect answers.', isDark),
          _buildRoutineStep('Revise', 'Revisit the concepts that need attention.', isDark),
          _buildRoutineStep('Follow up', 'Practise the topic again later.', isDark),
        ],
      ),
    );
  }

  Widget _buildRoutineStep(String title, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF0F0F11), fontSize: 14)),
          ),
          Expanded(child: Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14))),
        ],
      ),
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
          _buildMistakeRow('Guessing without reading carefully', 'Identify the key requirement first.', isDark),
          _buildMistakeRow('Memorizing answers', 'Focus on concepts and reasoning.', isDark),
          _buildMistakeRow('Ignoring explanations', 'Review both correct and incorrect answers.', isDark),
          _buildMistakeRow('Practising only easy questions', 'Gradually introduce more challenging questions.', isDark),
          _buildMistakeRow('Repeating mistakes without revision', 'Revisit the relevant concept before trying again.', isDark),
          _buildMistakeRow('Focusing only on quantity', 'Balance practice volume with understanding and accuracy.', isDark),
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
        _buildFaqAccordion(context, 'How should I start practising?', 'Start by picking a specific topic you have recently studied. Begin with easy or medium questions to solidify foundational concepts before tackling complex problems.', isDark),
        _buildFaqAccordion(context, 'Should I practise by topic or by subject?', 'Topic-wise practice is best for building initial understanding and identifying specific weaknesses. Subject-wise practice is better later on for testing your overall grasp of the subject.', isDark),
        _buildFaqAccordion(context, 'When should I attempt difficult questions?', 'Introduce difficult questions only after you have achieved consistent accuracy on easy and medium questions for a given topic.', isDark),
        _buildFaqAccordion(context, 'What should I do after answering incorrectly?', 'Do not just memorize the correct option. Read the detailed explanation, identify the concept you misunderstood, and review your notes on that concept before moving on.', isDark),
        _buildFaqAccordion(context, 'How often should I revisit difficult questions?', 'Use spaced repetition. Revisit difficult or previously incorrect questions after a few days, and then again after a couple of weeks to ensure long-term retention.', isDark),
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
          _buildLinkItem(context, 'Getting Started', () => context.push('/help/getting-started'), isDark),
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
