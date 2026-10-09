import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class TopicWorkspaceScreen extends StatefulWidget {
  final String topicId;
  const TopicWorkspaceScreen({super.key, required this.topicId});

  @override
  State<TopicWorkspaceScreen> createState() => _TopicWorkspaceScreenState();
}

class _TopicWorkspaceScreenState extends State<TopicWorkspaceScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopicData();
  }

  Future<void> _fetchTopicData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock delay
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Color(0xFF0F0F11)),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Topic bookmarked'))),
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Color(0xFF0F0F11)),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report topic'))),
          ),
        ],
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
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPrimaryAction(),
              const SizedBox(height: 32),
              _buildLearningOverview(),
              const SizedBox(height: 32),
              _buildPracticeSection(),
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
        const Text('Indian Polity', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        Text('Fundamental Rights', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fundamental Rights', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          const Text('Part III of the Indian Constitution, detailing essential human rights offered to citizens.', style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Topic Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
              Text('70%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple[800])),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.70,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple[800]!),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/practice'),
            icon: const Icon(Icons.quiz),
            label: const Text('Start Practice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/revision'),
            icon: const Icon(Icons.replay),
            label: const Text('Start Revision'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0F0F11)),
              foregroundColor: const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Learn This Topic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            TextButton(
              onPressed: () => context.push('/study-materials'),
              child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4DBF6), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFE4DBF6), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fundamental Rights — Quick Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    SizedBox(height: 4),
                    Text('Notes · English · 12 min', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => context.push('/study-materials'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAE4F7),
                  foregroundColor: const Color(0xFF0F0F11),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Open'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Practice & Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Questions', '120'),
              _buildStatItem('Attempted', '42'),
              _buildStatItem('Incorrect', '13'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/question-bank'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2ECE9)),
                foregroundColor: const Color(0xFF0F0F11),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Topic Question Bank', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Accuracy', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('68%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent[400])),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.68,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent[400]!),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 32),
          const Text('Focus Next', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Application-based questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
