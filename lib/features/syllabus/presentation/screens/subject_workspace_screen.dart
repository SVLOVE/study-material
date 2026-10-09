import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SubjectWorkspaceScreen extends StatefulWidget {
  final String subjectId;
  const SubjectWorkspaceScreen({super.key, required this.subjectId});

  @override
  State<SubjectWorkspaceScreen> createState() => _SubjectWorkspaceScreenState();
}

class _SubjectWorkspaceScreenState extends State<SubjectWorkspaceScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjectData();
  }

  Future<void> _fetchSubjectData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700)); // Mock network delay
    if (mounted) setState(() => _isLoading = false);
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
        title: const Text('General Science', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreadcrumb(),
              const SizedBox(height: 16),
              _buildSubjectHero(),
              const SizedBox(height: 24),
              _buildContinueLearning(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildTopicsList(),
              const SizedBox(height: 32),
              _buildPerformanceSection(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        const Text('TNPSC Group 4', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        const Text('General Studies', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        Text('General Science', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSubjectHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('General Science', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          const Text('Build a strong foundation across Physics, Chemistry, Biology and Environment.', style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subject Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
              Text('68%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple[800])),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.68,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple[800]!),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          const Text('12 / 18 topics explored', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildContinueLearning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Continue Learning', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Human Body', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Last studied 2 days ago', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/topics/topic-123'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard('Practice', '20 Qs', Icons.quiz, () => context.push('/practice'))),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard('Flashcards', '12 Due', Icons.style, () => context.push('/flashcards'))),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard('Revision', '8 Topics', Icons.published_with_changes, () => context.push('/revision'))),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0F0F11), size: 24),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Topics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 16),
              label: const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        _buildTopicCard('Human Body', 'Biology', 0.72, 12, 4, 'In Progress'),
        _buildTopicCard('Nutrition', 'Biology', 0.85, 20, 0, 'Completed'),
        _buildTopicCard('Diseases', 'Biology', 0.0, 0, 0, 'Not Started'),
        _buildTopicCard('Environment', 'Ecology', 0.95, 30, 2, 'Completed'),
      ],
    );
  }

  Widget _buildTopicCard(String title, String category, double progress, int qCount, int revCount, String status) {
    Color statusColor;
    IconData statusIcon;
    if (status == 'Completed') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'In Progress') {
      statusColor = Colors.blue;
      statusIcon = Icons.timelapse;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.radio_button_unchecked;
    }

    return InkWell(
      onTap: () => context.push('/topics/topic-123'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 4),
                  Text(category, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (qCount > 0) ...[
                        const Icon(Icons.quiz, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('$qCount Qs', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                      ],
                      if (revCount > 0) ...[
                        const Icon(Icons.replay, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('$revCount Review', style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            if (progress > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)),
                  const SizedBox(height: 4),
                  const Text('Progress', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subject Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildPerformanceStat('Accuracy', '76%', Colors.green)),
                  Expanded(child: _buildPerformanceStat('Solved', '245', const Color(0xFF0F0F11))),
                  Expanded(child: _buildPerformanceStat('Correct', '186', Colors.blue)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
