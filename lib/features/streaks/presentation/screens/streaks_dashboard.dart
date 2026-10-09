import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StreaksDashboard extends StatefulWidget {
  const StreaksDashboard({super.key});

  @override
  State<StreaksDashboard> createState() => _StreaksDashboardState();
}

class _StreaksDashboardState extends State<StreaksDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStreakData();
  }

  Future<void> _fetchStreakData() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for streak and activity records
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
        title: const Text('Study Streaks', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchStreakData,
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
                _buildStreakSummaries(),
                const SizedBox(height: 32),
                _buildActivityCalendar(),
                const SizedBox(height: 32),
                _buildWeeklyConsistency(),
                const SizedBox(height: 32),
                _buildRecentActivity(),
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
        const Text('Study Streaks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text('Build a consistent study habit, one day at a time.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildStreakSummaries() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildStreakCard(
                title: 'Current Streak',
                value: '3 Days',
                subtitle: 'Next milestone: 7 Days',
                icon: Icons.local_fire_department,
                color: Colors.orange,
                isPrimary: true,
              ),
            ),
            if (!isMobile) const SizedBox(width: 24),
            if (isMobile) const SizedBox(height: 24),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildStreakCard(
                title: 'Best Streak',
                value: '14 Days',
                subtitle: 'Achieved in Sep 2026',
                icon: Icons.emoji_events,
                color: Colors.amber,
                isPrimary: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStreakCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF0F0F11) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: isPrimary ? null : Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: isPrimary
            ? [BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))]
            : [BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : const Color(0xFF0F0F11)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : const Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: isPrimary ? Colors.white.withValues(alpha: 0.7) : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCalendar() {
    // Simulated calendar data for a generic month representation
    final daysInMonth = 31;
    final activeDays = {1, 2, 5, 6, 7, 8, 9}; // Example active days
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('October 2026', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((d) => Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Simplified Grid for month view
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isActive = activeDays.contains(day);
              final isToday = day == 9; // Assuming today is 9th
              
              return Container(
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF5A31F4) : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(color: Colors.orange, width: 2) : null,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF5A31F4), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Studied', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Inactive', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 2))),
              const SizedBox(width: 8),
              Text('Today', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyConsistency() {
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
          const Text('Weekly Goal Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('5 / 7', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text('Days Studied This Week', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('8', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text('Completed Sessions', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 5 / 7,
              backgroundColor: Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Study Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        _buildActivityRow(date: 'Today', title: 'Practice: Medieval History', duration: '45 mins'),
        _buildActivityRow(date: 'Yesterday', title: 'Revision: Indian Polity', duration: '30 mins'),
        _buildActivityRow(date: 'Oct 07', title: 'Weekly Sectional Mock Test', duration: '60 mins'),
      ],
    );
  }

  Widget _buildActivityRow({required String date, required String title, required String duration}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(duration, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
