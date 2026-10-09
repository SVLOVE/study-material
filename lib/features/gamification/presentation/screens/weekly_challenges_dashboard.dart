import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WeeklyChallengesDashboard extends StatefulWidget {
  const WeeklyChallengesDashboard({super.key});

  @override
  State<WeeklyChallengesDashboard> createState() => _WeeklyChallengesDashboardState();
}

class _WeeklyChallengesDashboardState extends State<WeeklyChallengesDashboard> {
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Practice',
    'Mock Tests',
    'Revision',
    'Study Plan',
  ];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for weekly challenge data
    await Future.delayed(const Duration(milliseconds: 700));
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Weekly Challenges', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchChallenges,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildWeeklyProgressOverview(),
                const SizedBox(height: 32),
                _buildWeeklyActivityStrip(),
                const SizedBox(height: 32),
                _buildWeeklyGoalsSection(),
                const SizedBox(height: 32),
                _buildCategories(),
                const SizedBox(height: 24),
                _buildChallengeList(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Challenges', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text('Build consistency, strengthen your preparation.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF0F0F11)),
              const SizedBox(width: 8),
              const Text('Oct 05 - Oct 11, 2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressOverview() {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('43% Completed', style: TextStyle(color: Color(0xFFFDF0D5), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('3', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                child: Text('of 7 challenges completed', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 3 / 7,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text('Earned 150 XP this week', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityStrip() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = [5, 6, 7, 8, 9, 10, 11];
    final statuses = [1, 1, 0, 2, 3, 3, 3]; // 1: Complete, 0: Missed, 2: Today (In progress), 3: Upcoming

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Activity Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final status = statuses[index];
              Color bgColor;
              Color textColor;
              Border? border;

              if (status == 1) { // Completed
                bgColor = const Color(0xFF5A31F4);
                textColor = Colors.white;
              } else if (status == 2) { // Today
                bgColor = const Color(0xFFFDF0D5);
                textColor = const Color(0xFF0F0F11);
                border = Border.all(color: Colors.orange, width: 2);
              } else if (status == 0) { // Missed
                bgColor = const Color(0xFFF3F4F6);
                textColor = Colors.grey[500]!;
              } else { // Upcoming
                bgColor = Colors.transparent;
                textColor = Colors.grey[700]!;
              }

              return Column(
                children: [
                  Text(days[index], style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: status == 2 ? FontWeight.bold : FontWeight.normal)),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: border,
                    ),
                    child: Center(
                      child: Text(
                        dates[index].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (status == 1)
                    const Icon(Icons.check_circle, color: Colors.green, size: 12)
                  else if (status == 0)
                    Icon(Icons.remove_circle, color: Colors.grey[400], size: 12)
                  else
                    const SizedBox(height: 12),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyGoalsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weekly Targets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                TextButton(onPressed: () {}, child: const Text('Edit Goals', style: TextStyle(color: Color(0xFF5A31F4), fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildGoalCard(title: 'Practice Questions', progress: 120, target: 200, color: Colors.blue),
                ),
                if (!isMobile) const SizedBox(width: 16),
                if (isMobile) const SizedBox(height: 16),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildGoalCard(title: 'Mock Tests', progress: 1, target: 2, color: Colors.orange),
                ),
                if (!isMobile) const SizedBox(width: 16),
                if (isMobile) const SizedBox(height: 16),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildGoalCard(title: 'Study Sessions', progress: 4, target: 7, color: Colors.green),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard({required String title, required int progress, required int target, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$progress', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Text('/ $target', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: target > 0 ? progress / target : 0,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                  _fetchChallenges();
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF5A31F4),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChallengeList() {
    return Column(
      children: [
        _buildChallengeCard(
          title: 'Master Indian Polity',
          description: 'Answer 50 practice questions in Indian Polity.',
          category: 'Practice',
          progress: 50,
          total: 50,
          reward: '100 XP',
          status: 'Completed',
          actionText: 'Completed',
          onAction: () {},
        ),
        _buildChallengeCard(
          title: 'Weekend Mock Test',
          description: 'Complete 1 full-length mock test.',
          category: 'Mock Tests',
          progress: 0,
          total: 1,
          reward: '250 XP',
          status: 'Not Started',
          actionText: 'Start Test',
          onAction: () => context.push('/mock-tests'),
        ),
        _buildChallengeCard(
          title: 'Revise Weak Topics',
          description: 'Review 3 topics flagged as weak from your recent tests.',
          category: 'Revision',
          progress: 1,
          total: 3,
          reward: '150 XP',
          status: 'In Progress',
          actionText: 'Continue Revision',
          onAction: () => context.push('/study-plan'),
        ),
        _buildChallengeCard(
          title: 'Weekly Consistency',
          description: 'Complete 4 study sessions this week.',
          category: 'Study Plan',
          progress: 4,
          total: 4,
          reward: '200 XP',
          status: 'Completed',
          actionText: 'Completed',
          onAction: () {},
        ),
      ],
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String description,
    required String category,
    required int progress,
    required int total,
    required String reward,
    required String status,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final isCompleted = status == 'Completed';
    final isInProgress = status == 'In Progress';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isCompleted ? Colors.green.withValues(alpha: 0.3) : const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withValues(alpha: 0.1) : (isInProgress ? Colors.orange.withValues(alpha: 0.1) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isCompleted ? Icons.emoji_events : (isInProgress ? Icons.directions_run : Icons.flag),
                  color: isCompleted ? Colors.green : (isInProgress ? Colors.orange : const Color(0xFF0F0F11)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF0D5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                        Text('$progress / $total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? progress / total : 0,
                        backgroundColor: const Color(0xFFF3F4F6),
                        valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : Colors.blue),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: isCompleted ? Colors.green : Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text('Reward: $reward', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: isCompleted ? null : onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.green.withValues(alpha: 0.1) : const Color(0xFF0F0F11),
                  foregroundColor: isCompleted ? Colors.green : Colors.white,
                  disabledBackgroundColor: Colors.green.withValues(alpha: 0.1),
                  disabledForegroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
