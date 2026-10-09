import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MotivationCenterScreen extends StatefulWidget {
  const MotivationCenterScreen({super.key});

  @override
  State<MotivationCenterScreen> createState() => _MotivationCenterScreenState();
}

class _MotivationCenterScreenState extends State<MotivationCenterScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMotivationData();
  }

  Future<void> _fetchMotivationData() async {
    setState(() => _isLoading = true);
    // Simulate fetching user progress, milestones, and daily quotes from backend
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
        title: const Text('Motivation Center', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)))
            : RefreshIndicator(
                onRefresh: _fetchMotivationData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageHeader(),
                      const SizedBox(height: 24),
                      _buildDailyMotivationCard(),
                      const SizedBox(height: 24),
                      _buildProgressStory(),
                      const SizedBox(height: 24),
                      _buildPersonalMilestones(),
                      const SizedBox(height: 24),
                      _buildWeeklyMonthlyChallenges(),
                      const SizedBox(height: 24),
                      _buildMotivationalTipCard(),
                      const SizedBox(height: 32),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hello, Aspirant! 👋',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 4),
        Text(
          'TNPSC Preparation • Every focused session brings you closer.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDailyMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A31F4).withValues(alpha: 0.2),
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
            decoration: BoxDecoration(
              color: const Color(0xFF5A31F4).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Daily Spark',
              style: TextStyle(color: Color(0xFFE4DBF6), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Small steps.\nStrong preparation.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 12),
          const Text(
            'Consistent practice helps you build confidence over time. Keep the momentum going.',
            style: TextStyle(fontSize: 14, color: Color(0xFFE2ECE9)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/practice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F0F11),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continue Practice', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Progress Story', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildProgressMetricCard(
                  icon: Icons.local_fire_department,
                  value: '12 Days',
                  label: 'Current Streak',
                  color: Colors.orange,
                  width: (constraints.maxWidth - 12) / 2,
                ),
                _buildProgressMetricCard(
                  icon: Icons.check_circle,
                  value: '450+',
                  label: 'Questions Solved',
                  color: Colors.green,
                  width: (constraints.maxWidth - 12) / 2,
                ),
                _buildProgressMetricCard(
                  icon: Icons.timer,
                  value: '45 hrs',
                  label: 'Study Time',
                  color: const Color(0xFF5A31F4),
                  width: (constraints.maxWidth - 12) / 2,
                ),
                _buildProgressMetricCard(
                  icon: Icons.emoji_events,
                  value: '8',
                  label: 'Challenges Met',
                  color: Colors.purple,
                  width: (constraints.maxWidth - 12) / 2,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressMetricCard({required IconData icon, required String value, required String label, required Color color, required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPersonalMilestones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        _buildMilestoneCard(
          title: 'First 100 Questions',
          description: 'You completed your first century of practice questions.',
          date: 'Achieved 2 days ago',
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildMilestoneCard(
          title: 'Consistency King',
          description: 'Maintained a 7-day active study streak.',
          date: 'Achieved last week',
          icon: Icons.trending_up,
          iconColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildMilestoneCard({required String title, required String description, required String date, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMonthlyChallenges() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, color: Colors.green),
              SizedBox(width: 8),
              Text('Challenge Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You are on track to complete 2 weekly challenges. A short practice session can help you keep moving!',
            style: TextStyle(fontSize: 14, color: Colors.green[800]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/weekly-challenges'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[800],
                    side: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Weekly'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/monthly-challenges'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[800],
                    side: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Monthly'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Learning Tip', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 4),
                Text(
                  'Review your mistakes in the Mistake Notebook to identify what to practice next. Active recall strengthens memory.',
                  style: TextStyle(fontSize: 13, color: Colors.orange[900], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionChip('Practice', Icons.edit_note, () => context.go('/practice')),
            _buildQuickActionChip('Mock Tests', Icons.timer, () => context.go('/mock-tests')),
            _buildQuickActionChip('Study Plan', Icons.calendar_today, () => context.go('/study-plan')),
            _buildQuickActionChip('Leaderboard', Icons.leaderboard, () => context.go('/leaderboard')),
            _buildQuickActionChip('Achievements', Icons.military_tech, () => context.go('/achievements')),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF5A31F4)),
      label: Text(label),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFF3F4F6)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: onTap,
    );
  }
}
