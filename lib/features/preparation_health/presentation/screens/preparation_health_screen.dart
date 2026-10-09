import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/preparation_health.dart';

class PreparationHealthScreen extends StatelessWidget {
  const PreparationHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = dummyPreparationHealth;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Preparation Health',
          style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'See how your preparation is progressing and where you need to focus next.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 24),
                  _buildHeroCard(context, health),
                  const SizedBox(height: 32),
                  const Text(
                    'Key Metrics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(health),
                  const SizedBox(height: 32),
                  const Text(
                    'Your Next Priority',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  _buildNextPriorityCard(context),
                  const SizedBox(height: 32),
                  const Text(
                    'Preparation Gaps',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  ...health.gaps.map((gap) => _buildGapCard(context, gap)),
                  const SizedBox(height: 32),
                  const Text(
                    'Action Center',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCenter(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, PreparationHealth health) {
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.trending_up;
    if (health.status == 'Needs Attention' || health.status == 'Declined') {
      statusColor = Colors.redAccent;
      statusIcon = Icons.warning_amber_rounded;
    } else if (health.status == 'Stable') {
      statusColor = Colors.blue;
      statusIcon = Icons.horizontal_rule;
    } else if (health.status == 'Insufficient Data') {
      statusColor = Colors.orange;
      statusIcon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.2),
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
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('Your Preparation', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Text(
                health.status,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            health.statusDescription,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/reassessment'), // View Priority Areas -> adaptive reassessment
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F0F11),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('View Priority Areas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(PreparationHealth health) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Accuracy', '${health.accuracy.toStringAsFixed(0)}%', Icons.track_changes, Colors.deepPurple),
        _buildMetricCard('Questions Solved', '${health.questionsSolved}', Icons.format_list_numbered, Colors.blue),
        _buildMetricCard('Topics Improved', '${health.topicsImproved}', Icons.arrow_upward, Colors.green),
        _buildMetricCard('Needs Attention', '${health.topicsNeedingAttention}', Icons.warning_amber, Colors.redAccent),
        if (health.recentMockAverage != null)
          _buildMetricCard('Mock Average', '${health.recentMockAverage!.toStringAsFixed(0)}%', Icons.analytics, Colors.orange),
        _buildMetricCard('Syllabus', '${health.syllabusCoverage.toStringAsFixed(0)}%', Icons.menu_book, Colors.teal),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF555555)), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPriorityCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5), // Soft Yellow indicating attention
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Modern History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          const Text('Why:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
          const SizedBox(height: 4),
          const Text('Recent performance remains low after reassessment.', style: TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          const Text('Recommended:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
          const SizedBox(height: 4),
          const Text('Review → Practice → Reassess', style: TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/reassessment'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              side: const BorderSide(color: Color(0xFF0F0F11)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Recovery'),
          ),
        ],
      ),
    );
  }

  Widget _buildGapCard(BuildContext context, PreparationGap gap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gap.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text('Gap: ${gap.description}', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(gap.actionRoute),
            child: Text(gap.actionTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCenter(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.9,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          _buildActionItem(context, 'Start Reassessment', Icons.refresh, '/reassessment'),
          const Divider(height: 1, color: Color(0xFFEAE4F7)),
          _buildActionItem(context, 'Continue Study Plan', Icons.next_plan, '/dashboard'),
          const Divider(height: 1, color: Color(0xFFEAE4F7)),
          _buildActionItem(context, 'Take Mock Test', Icons.assignment, '/mock-tests'),
          const Divider(height: 1, color: Color(0xFFEAE4F7)),
          _buildActionItem(context, 'Review Mistakes', Icons.error_outline, '/mistake-notebook'),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFE4DBF6), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.deepPurple, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => context.push(route),
    );
  }
}
