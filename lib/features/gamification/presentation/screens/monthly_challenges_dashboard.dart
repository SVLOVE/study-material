import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MonthlyChallengesDashboard extends StatefulWidget {
  const MonthlyChallengesDashboard({super.key});

  @override
  State<MonthlyChallengesDashboard> createState() => _MonthlyChallengesDashboardState();
}

class _MonthlyChallengesDashboardState extends State<MonthlyChallengesDashboard> {
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Practice',
    'Mock Tests',
    'Revision',
    'Current Affairs',
  ];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for monthly challenge data
    await Future.delayed(const Duration(milliseconds: 800));
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
        title: const Text('Monthly Challenges', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
                _buildMonthlyProgressOverview(),
                const SizedBox(height: 32),
                _buildMonthlyGoalsSection(),
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
        const Text('Monthly Challenges', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text('Make steady progress toward your exam goals, one month at a time.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20, color: Color(0xFF0F0F11)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const Text('October 2026', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: null, // Future month disabled
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyProgressOverview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              flex: isMobile ? 0 : 2,
              child: Container(
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
                        const Text('Monthly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('20% Completed', style: TextStyle(color: Color(0xFFFDF0D5), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('1', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                          child: Text('of 5 challenges completed', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 1 / 5,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isMobile) const SizedBox(width: 24),
            if (isMobile) const SizedBox(height: 24),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly XP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 8),
                    const Text('350', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 8),
                    Text('XP earned this month', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyGoalsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Monthly Targets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                TextButton(onPressed: () {}, child: const Text('Edit Goals', style: TextStyle(color: Color(0xFF5A31F4), fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildGoalCard(title: 'Practice Questions', progress: 450, target: 1000, color: Colors.blue),
                ),
                if (!isMobile) const SizedBox(width: 16),
                if (isMobile) const SizedBox(height: 16),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildGoalCard(title: 'Mock Tests', progress: 3, target: 8, color: Colors.orange),
                ),
                if (!isMobile) const SizedBox(width: 16),
                if (isMobile) const SizedBox(height: 16),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildGoalCard(title: 'Study Days', progress: 9, target: 25, color: Colors.green),
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
          title: 'Monthly Mock Test Marathon',
          description: 'Complete 8 full-length mock tests this month.',
          category: 'Mock Tests',
          progress: 3,
          total: 8,
          reward: '500 XP',
          status: 'In Progress',
          actionText: 'Start Test',
          onAction: () => context.push('/mock-tests'),
        ),
        _buildChallengeCard(
          title: 'Current Affairs Mastery',
          description: 'Study current affairs on 20 different days.',
          category: 'Current Affairs',
          progress: 9,
          total: 20,
          reward: '300 XP',
          status: 'In Progress',
          actionText: 'Read Today',
          onAction: () {},
        ),
        _buildChallengeCard(
          title: 'Question Bank Dominator',
          description: 'Solve 1000 practice questions this month.',
          category: 'Practice',
          progress: 450,
          total: 1000,
          reward: '750 XP',
          status: 'In Progress',
          actionText: 'Continue Practice',
          onAction: () {},
        ),
        _buildChallengeCard(
          title: 'Early Bird Starter',
          description: 'Complete a study session in the first week of the month.',
          category: 'Study Plan',
          progress: 1,
          total: 1,
          reward: '100 XP',
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
                  isCompleted ? Icons.emoji_events : (isInProgress ? Icons.trending_up : Icons.flag),
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
