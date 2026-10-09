import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String category; // Practice, Mock Tests, Revision, Consistency
  final IconData icon;
  final int targetValue;
  final int progressValue;
  final bool isCompleted;
  final DateTime? completedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.targetValue,
    required this.progressValue,
    required this.isCompleted,
    this.completedAt,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Completed', 'In Progress', 'Locked'];
  List<Achievement> _achievements = [];
  List<Achievement> _filteredAchievements = [];

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock network

      _achievements = [
        Achievement(
          id: 'a_1',
          title: 'Practice Starter',
          description: 'Solve your first 50 practice questions.',
          category: 'Practice',
          icon: Icons.task_alt,
          targetValue: 50,
          progressValue: 50,
          isCompleted: true,
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Achievement(
          id: 'a_2',
          title: 'Practice Builder',
          description: 'Answer 250 practice questions.',
          category: 'Practice',
          icon: Icons.done_all,
          targetValue: 250,
          progressValue: 120,
          isCompleted: false,
        ),
        Achievement(
          id: 'a_3',
          title: 'Mock Test Explorer',
          description: 'Complete 5 mock tests.',
          category: 'Mock Tests',
          icon: Icons.assignment,
          targetValue: 5,
          progressValue: 1,
          isCompleted: false,
        ),
        Achievement(
          id: 'a_4',
          title: 'Revision Habit',
          description: 'Complete 10 revision sessions.',
          category: 'Revision',
          icon: Icons.replay,
          targetValue: 10,
          progressValue: 0,
          isCompleted: false,
        ),
        Achievement(
          id: 'a_5',
          title: 'Daily Learner',
          description: 'Complete 7 daily challenges.',
          category: 'Consistency',
          icon: Icons.calendar_month,
          targetValue: 7,
          progressValue: 4,
          isCompleted: false,
        ),
      ];
      
      _applyFilter();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredAchievements = _achievements;
      } else if (_selectedFilter == 'Completed') {
        _filteredAchievements = _achievements.where((a) => a.isCompleted).toList();
      } else if (_selectedFilter == 'In Progress') {
        _filteredAchievements = _achievements.where((a) => !a.isCompleted && a.progressValue > 0).toList();
      } else if (_selectedFilter == 'Locked') {
        _filteredAchievements = _achievements.where((a) => !a.isCompleted && a.progressValue == 0).toList();
      }
    });
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
        title: const Text('Achievements', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: _isLoading ? _buildLoading() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilter = filter;
                      _applyFilter();
                    });
                  }
                },
                selectedColor: const Color(0xFF0F0F11),
                backgroundColor: const Color(0xFFFFFFFF),
                side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedFilter == 'All') _buildSummary(),
              const SizedBox(height: 24),
              
              if (_filteredAchievements.isEmpty)
                _buildEmptyState()
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    int cols = constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _filteredAchievements.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementCard(_filteredAchievements[index]);
                      },
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

  Widget _buildSummary() {
    int total = _achievements.length;
    int completed = _achievements.where((a) => a.isCompleted).length;
    int inProgress = _achievements.where((a) => !a.isCompleted && a.progressValue > 0).length;

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
          const Text('YOUR PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('$total', 'Total'),
              _buildSummaryStat('$completed', 'Completed'),
              _buildSummaryStat('$inProgress', 'In Progress'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Your Learning Journey Starts Here', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Complete practice sessions, mock tests, revisions, and study goals to unlock meaningful milestones.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.push('/practice'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0F0F11)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Practicing', style: TextStyle(color: Color(0xFF0F0F11))),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    Color cardColor = const Color(0xFFFFFFFF);
    Color statusColor = const Color(0xFF0F0F11).withValues(alpha: 0.6);
    String statusText = 'Locked';

    if (achievement.isCompleted) {
      cardColor = const Color(0xFFE2F0D9);
      statusColor = Colors.green;
      statusText = 'Completed';
    } else if (achievement.progressValue > 0) {
      cardColor = const Color(0xFFE4DBF6);
      statusColor = Colors.deepPurple;
      statusText = 'In Progress';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: achievement.isCompleted ? Colors.transparent : const Color(0xFFF3F4F6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(achievement.icon, size: 24, color: statusColor),
                if (achievement.isCompleted)
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Text(achievement.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 4),
            Text(achievement.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
            
            const Spacer(),
            
            if (achievement.isCompleted)
              Text('Earned ${achievement.completedAt!.day}/${achievement.completedAt!.month}/${achievement.completedAt!.year}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green))
            else ...[
              Text('${achievement.progressValue} / ${achievement.targetValue}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: achievement.progressValue / achievement.targetValue,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  color: statusColor,
                  minHeight: 6,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
