import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MilestonesDashboard extends StatefulWidget {
  const MilestonesDashboard({super.key});

  @override
  State<MilestonesDashboard> createState() => _MilestonesDashboardState();
}

class _MilestonesDashboardState extends State<MilestonesDashboard> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All',
    'Practice Progress',
    'Mock Tests',
    'Study Consistency',
    'Challenges',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMilestonesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMilestonesData() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for milestone progress
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
        title: const Text('Milestones', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F0F11)),
            onPressed: _fetchMilestonesData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildCategoryFilter(),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5A31F4),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF5A31F4),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'In Progress'),
            Tab(text: 'Achieved'),
            Tab(text: 'Upcoming'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInProgressTab(),
              _buildAchievedTab(),
              _buildUpcomingTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Journey So Far', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text('Every completed goal marks progress in your exam preparation.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Achieved', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4DBF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('24 / 100 Milestones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.24,
                    minHeight: 12,
                    backgroundColor: Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A31F4)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _selectedCategoryIndex = index);
            },
            selectedColor: const Color(0xFF0F0F11),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0F0F11),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildInProgressTab() {
    return RefreshIndicator(
      onRefresh: _fetchMilestonesData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMilestoneCard(
            title: 'Practice Mastery I',
            description: 'Answer 500 practice questions correctly.',
            icon: Icons.edit_note,
            iconColor: Colors.blue,
            progress: 0.85,
            currentValue: '425',
            targetValue: '500',
            actionLabel: 'Practice Now',
            onAction: () => context.go('/practice'),
          ),
          _buildMilestoneCard(
            title: 'Mock Test Warrior',
            description: 'Complete 10 full-length mock tests.',
            icon: Icons.timer,
            iconColor: Colors.purple,
            progress: 0.4,
            currentValue: '4',
            targetValue: '10',
            actionLabel: 'Take Test',
            onAction: () => context.go('/mock-tests'),
          ),
          _buildMilestoneCard(
            title: 'Consistent Learner',
            description: 'Maintain a 14-day study streak.',
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            progress: 0.6,
            currentValue: '8 days',
            targetValue: '14 days',
          ),
        ],
      ),
    );
  }

  Widget _buildAchievedTab() {
    return RefreshIndicator(
      onRefresh: _fetchMilestonesData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAchievedMilestoneCard(
            title: 'First 100 Questions',
            description: 'You completed your first century of practice questions.',
            icon: Icons.star,
            iconColor: Colors.amber,
            date: 'Oct 8, 2026',
            category: 'Practice Progress',
          ),
          _buildAchievedMilestoneCard(
            title: 'Week 1 Champion',
            description: 'Completed all daily challenges for 7 consecutive days.',
            icon: Icons.emoji_events,
            iconColor: Colors.green,
            date: 'Oct 1, 2026',
            category: 'Challenges',
          ),
          _buildAchievedMilestoneCard(
            title: 'First Mock Test',
            description: 'Successfully finished your first full-length mock test.',
            icon: Icons.fact_check,
            iconColor: Colors.teal,
            date: 'Sep 25, 2026',
            category: 'Mock Tests',
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return RefreshIndicator(
      onRefresh: _fetchMilestonesData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0D5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_clock, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These milestones will unlock as you progress further in your preparation journey.',
                    style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                  ),
                ),
              ],
            ),
          ),
          _buildUpcomingMilestoneCard(
            title: 'Syllabus Conqueror',
            description: 'Complete 100% of your targeted exam syllabus.',
            icon: Icons.menu_book,
            iconColor: Colors.indigo,
            unlockCondition: 'Reach 80% syllabus completion first.',
          ),
          _buildUpcomingMilestoneCard(
            title: 'Mock Test Elite',
            description: 'Score above 90th percentile in 5 consecutive mock tests.',
            icon: Icons.workspace_premium, // using a different icon
            iconColor: Colors.redAccent,
            unlockCondition: 'Complete the "Mock Test Warrior" milestone.',
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required double progress,
    required String currentValue,
    required String targetValue,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
              Text('$currentValue / $targetValue', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: const Color(0xFF0F0F11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievedMilestoneCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String date,
    required String category,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)))),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Achieved: $date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMilestoneCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String unlockCondition,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Unlock: $unlockCondition',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
