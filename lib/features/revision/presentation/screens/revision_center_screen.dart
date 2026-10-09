import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RevisionCenterScreen extends StatefulWidget {
  const RevisionCenterScreen({super.key});

  @override
  State<RevisionCenterScreen> createState() => _RevisionCenterScreenState();
}

class _RevisionCenterScreenState extends State<RevisionCenterScreen> {
  bool _isLoading = true;
  final String _targetExam = 'UPSC Civil Services';

  @override
  void initState() {
    super.initState();
    _fetchRevisionData();
  }

  Future<void> _fetchRevisionData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock network latency
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          onPressed: () => context.pop(),
        ),
        title: const Text('Revision Center', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preparing for: $_targetExam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              const Text('Review what you got wrong, strengthen weak areas, and keep important questions fresh.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 32),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildPrimarySection()),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _buildSecondarySection()),
                      ],
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPrimarySection(),
                      const SizedBox(height: 48),
                      _buildSecondarySection(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviseTodayCard(),
        const SizedBox(height: 32),
        const Text('Revision Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 2 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: MediaQuery.of(context).size.width >= 600 ? 1.5 : 2.5,
          children: [
            _buildCategoryCard('Incorrect Questions', 'Questions you previously answered incorrectly.', Icons.close, const Color(0xFFFDF0D5), Colors.orange, () => context.push('/mistake-notebook')),
            _buildCategoryCard('Bookmarked Questions', 'Questions you\'ve saved for later.', Icons.bookmark_outline, const Color(0xFFE4DBF6), Colors.deepPurple, () => context.push('/practice')),
            _buildCategoryCard('Weak Topics', 'Topics where your recent performance needs improvement.', Icons.trending_down, const Color(0xFFFDECEB), Colors.redAccent, () => context.push('/practice')),
            _buildCategoryCard('Recent Mistakes', 'Questions you\'ve recently answered incorrectly.', Icons.history, const Color(0xFFE2F0D9), Colors.green, () => context.push('/mistake-notebook')),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Recent Mistakes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        _buildRecentMistakesList(),
      ],
    );
  }

  Widget _buildSecondarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMockMistakesCard(),
        const SizedBox(height: 32),
        _buildWeakTopicsList(),
      ],
    );
  }

  Widget _buildReviseTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('Highest Priority', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          const Text('Revise Today', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('You have 15 high-priority questions to review.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/revision/smart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F0F11),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Revise Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Expanded(child: Text(subtitle, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMistakesList() {
    return Column(
      children: [
        _buildMistakeCard('Indian Polity', 'Fundamental Rights', 'Medium', '2 hours ago'),
        _buildMistakeCard('Quantitative Aptitude', 'Percentages', 'Hard', '5 hours ago'),
        _buildMistakeCard('General Science', 'Physics - Motion', 'Easy', 'Yesterday'),
      ],
    );
  }

  Widget _buildMistakeCard(String subject, String topic, String diff, String timeAgo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                      child: Text(diff, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    ),
                    const SizedBox(width: 8),
                    Text(timeAgo, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(topic, style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.7))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {}, // Routes to existing question review
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAE4F7),
              foregroundColor: const Color(0xFF0F0F11),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMockMistakesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_late_outlined, color: Colors.pinkAccent),
              SizedBox(width: 8),
              Text('Review Mock Mistakes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Last Mock Test', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          _buildMockStatRow('Incorrect', '8', Colors.redAccent),
          const SizedBox(height: 8),
          _buildMockStatRow('Unanswered', '3', Colors.grey),
          const SizedBox(height: 8),
          _buildMockStatRow('Marked for Review', '5', Colors.orange),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/mock-results/1'), // Route to existing mock result
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF0F0F11)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Review Answers', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.8), fontSize: 13)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildWeakTopicsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Topics to Strengthen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildWeakTopicRow('Constitution', '64%'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildWeakTopicRow('Banking Awareness', '67%'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildWeakTopicRow('Probability', '69%'),
        ],
      ),
    );
  }

  Widget _buildWeakTopicRow(String topic, String accuracy) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topic, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text('Accuracy: $accuracy', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        TextButton(
          onPressed: () => context.push('/practice'), // Existing practice arena with topic filter conceptually applied
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0F0F11),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: const Color(0xFFF3F4F6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Practice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}
