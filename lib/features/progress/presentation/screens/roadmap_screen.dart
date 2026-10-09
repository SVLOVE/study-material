import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RoadmapStage {
  final String id;
  final String title;
  final String description;
  final String status; // Locked, Upcoming, Active, Completed
  final double progress; // 0.0 to 1.0
  final String actionRoute;
  final String actionLabel;
  final IconData icon;

  RoadmapStage({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    required this.actionRoute,
    required this.actionLabel,
    required this.icon,
  });
}

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final String _targetExam = 'TNPSC Group 4';
  bool _isLoading = true;

  List<RoadmapStage> _stages = [];

  @override
  void initState() {
    super.initState();
    _fetchRoadmapData();
  }

  Future<void> _fetchRoadmapData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock delay
      
      // Mapped directly to existing modules and authoritative features
      _stages = [
        RoadmapStage(
          id: 'stage_1',
          title: 'Foundation',
          description: 'Understand the syllabus and build your preparation base.',
          status: 'Completed',
          progress: 1.0,
          actionRoute: '/syllabus',
          actionLabel: 'View Syllabus',
          icon: Icons.menu_book,
        ),
        RoadmapStage(
          id: 'stage_2',
          title: 'Learn & Build',
          description: 'Study core materials and build your conceptual understanding.',
          status: 'Completed',
          progress: 1.0,
          actionRoute: '/study-materials',
          actionLabel: 'Continue Learning',
          icon: Icons.auto_stories,
        ),
        RoadmapStage(
          id: 'stage_3',
          title: 'Practice & Apply',
          description: 'Solve topic-wise questions to strengthen your knowledge.',
          status: 'Active',
          progress: 0.72,
          actionRoute: '/practice',
          actionLabel: 'Start Practice',
          icon: Icons.quiz,
        ),
        RoadmapStage(
          id: 'stage_4',
          title: 'Analyze & Revise',
          description: 'Focus on weak areas and clear incorrect attempts.',
          status: 'Upcoming',
          progress: 0.20,
          actionRoute: '/revision',
          actionLabel: 'Start Revision',
          icon: Icons.replay,
        ),
        RoadmapStage(
          id: 'stage_5',
          title: 'Test & Evaluate',
          description: 'Take full-length mock tests to evaluate exam readiness.',
          status: 'Locked',
          progress: 0.0,
          actionRoute: '/mock-tests',
          actionLabel: 'Take a Mock Test',
          icon: Icons.timer,
        ),
      ];
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
        title: const Text('Preparation Roadmap', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
              _buildHeader(),
              const SizedBox(height: 32),
              _buildFocusNext(),
              const SizedBox(height: 32),
              const Text('Roadmap Stages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 24),
              _buildTimeline(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Arbitrary derivation from mocked active stages to give holistic progress
    final overallProgress = _stages.isEmpty ? 0.0 : (_stages.map((e) => e.progress).reduce((a, b) => a + b) / _stages.length);
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target Exam', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11).withValues(alpha: 0.5))),
              const Icon(Icons.verified, size: 16, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 4),
          Text(_targetExam, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Preparation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
              Text('${(overallProgress * 100).toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusNext() {
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
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text('FOCUS NEXT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Indian Polity — Fundamental Rights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Based on your recent performance, your accuracy here is 54%. Focus on this weak area.', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F0F11),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Practice Topic', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stages.length,
      itemBuilder: (context, index) {
        final stage = _stages[index];
        final isLast = index == _stages.length - 1;
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and node
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getNodeColor(stage.status),
                      shape: BoxShape.circle,
                      border: Border.all(color: _getBorderColor(stage.status), width: 2),
                    ),
                    child: Center(
                      child: Icon(stage.icon, size: 14, color: _getIconColor(stage.status)),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: stage.status == 'Completed' ? Colors.green : const Color(0xFFE2ECE9),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Stage Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildStageCard(stage, index + 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getNodeColor(String status) {
    switch (status) {
      case 'Completed': return const Color(0xFFE2F0D9);
      case 'Active': return const Color(0xFFE4DBF6);
      default: return const Color(0xFFFFFFFF);
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'Active': return Colors.deepPurple;
      case 'Upcoming': return const Color(0xFF0F0F11).withValues(alpha: 0.3);
      default: return const Color(0xFFF3F4F6);
    }
  }

  Color _getIconColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green[800]!;
      case 'Active': return Colors.deepPurple[800]!;
      case 'Upcoming': return const Color(0xFF0F0F11).withValues(alpha: 0.5);
      default: return Colors.grey;
    }
  }

  Widget _buildStageCard(RoadmapStage stage, int index) {
    final isActive = stage.status == 'Active';
    final isLocked = stage.status == 'Locked';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF).withValues(alpha: isLocked ? 0.6 : 1.0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.deepPurple.withValues(alpha: 0.3) : const Color(0xFFF3F4F6)),
        boxShadow: isActive ? [
          BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0$index', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11).withValues(alpha: 0.4))),
              _buildStatusBadge(stage.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(stage.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            isLocked ? 'Complete the previous stage to unlock this section.' : stage.description,
            style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: isLocked ? 0.4 : 0.7), height: 1.4),
          ),
          
          if (!isLocked && stage.status != 'Upcoming') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stage.progress,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(stage.status == 'Completed' ? Colors.green : Colors.deepPurple),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(stage.progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              ],
            ),
          ],
          
          if (!isLocked) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push(stage.actionRoute),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isActive ? const Color(0xFF0F0F11) : const Color(0xFFE2ECE9)),
                  backgroundColor: isActive ? const Color(0xFF0F0F11) : Colors.transparent,
                  foregroundColor: isActive ? Colors.white : const Color(0xFF0F0F11),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(stage.actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF3F4F6);
    Color fg = Colors.grey;
    
    if (status == 'Completed') {
      bg = const Color(0xFFE2F0D9);
      fg = Colors.green[800]!;
    } else if (status == 'Active') {
      bg = const Color(0xFFE4DBF6);
      fg = Colors.deepPurple[800]!;
    } else if (status == 'Upcoming') {
      bg = const Color(0xFFE2ECE9);
      fg = Colors.teal[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
