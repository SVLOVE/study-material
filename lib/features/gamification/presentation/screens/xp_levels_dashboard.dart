import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class XpLevelsDashboard extends StatefulWidget {
  const XpLevelsDashboard({super.key});

  @override
  State<XpLevelsDashboard> createState() => _XpLevelsDashboardState();
}

class _XpLevelsDashboardState extends State<XpLevelsDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchXpData();
  }

  Future<void> _fetchXpData() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for XP and level data
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
        title: const Text('XP & Levels', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchXpData,
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
                _buildCurrentLevelCard(),
                const SizedBox(height: 32),
                _buildHowToEarn(),
                const SizedBox(height: 32),
                _buildXpActivityHistory(),
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
        const Text('XP & Levels', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text('Track your learning milestones and progress.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildCurrentLevelCard() {
    // Simulated XP logic variables (to be replaced with Riverpod state)
    final currentLevel = 4;
    final currentXp = 1250;
    final requiredXp = 2000;
    final progress = currentXp / requiredXp;

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
              Text('Level $currentLevel', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text('Dedicated Learner', style: TextStyle(color: Color(0xFFFDF0D5), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$currentXp', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Total XP Earned', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${requiredXp - currentXp}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('XP to Level ${currentLevel + 1}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep completing mock tests and practice sessions to level up.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarn() {
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
          const Text('How to Earn XP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildEarnRuleRow(Icons.assignment_turned_in, 'Complete a Mock Test', '+100 XP', Colors.orange),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildEarnRuleRow(Icons.storage, 'Finish a Practice Session', '+25 XP', Colors.blue),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildEarnRuleRow(Icons.local_fire_department, 'Maintain a 3-Day Streak', '+50 XP', Colors.red),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildEarnRuleRow(Icons.autorenew, 'Revise Weak Topics', '+20 XP', Colors.green),
        ],
      ),
    );
  }

  Widget _buildEarnRuleRow(IconData icon, String title, String reward, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11)))),
        Text(reward, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor)),
      ],
    );
  }

  Widget _buildXpActivityHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent XP History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            TextButton(
              onPressed: () {}, // To implement if there's a full history screen
              child: const Text('View All', style: TextStyle(color: Color(0xFF5A31F4), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildHistoryItem(
          title: 'Weekly Sectional Mock Test',
          subtitle: 'Scored 85%',
          reward: '+100 XP',
          date: 'Oct 07, 2026',
        ),
        _buildHistoryItem(
          title: '3-Day Study Streak',
          subtitle: 'Consistency reward',
          reward: '+50 XP',
          date: 'Oct 06, 2026',
        ),
        _buildHistoryItem(
          title: 'Practice: Indian Polity',
          subtitle: '50 questions completed',
          reward: '+25 XP',
          date: 'Oct 05, 2026',
        ),
      ],
    );
  }

  Widget _buildHistoryItem({required String title, required String subtitle, required String reward, required String date}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFFDF0D5), shape: BoxShape.circle),
            child: const Icon(Icons.star, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(reward, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 4),
              Text(date, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
