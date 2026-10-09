import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/next_action.dart';

class NextStepScreen extends StatelessWidget {
  const NextStepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryAction = dummyPrimaryAction;
    final secondaryActions = dummySecondaryActions;
    final dailyContext = dummyDailyContext;

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
          'Your Next Step',
          style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A focused action based on your current preparation.',
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 24),
              _buildHeroCard(context, primaryAction),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Other Useful Actions',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                        ),
                        const SizedBox(height: 16),
                        ...secondaryActions.map((action) => _buildSecondaryActionCard(context, action)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                        ),
                        const SizedBox(height: 16),
                        _buildDailyContextCard(context, dailyContext),
                        const SizedBox(height: 24),
                        _buildPreparationStatusContext(context),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, NextAction action) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
            child: const Text('YOUR NEXT STEP', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 24),
          Text(
            action.title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            action.reason,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          if (action.estimatedMinutes != null)
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white54, size: 20),
                const SizedBox(width: 8),
                Text('Estimated time: ${action.estimatedMinutes} min', style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: () => context.push(action.route),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F0F11),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActionCard(BuildContext context, NextAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(action.description, style: const TextStyle(fontSize: 14, color: Color(0xFF555555))),
        ),
        trailing: OutlinedButton(
          onPressed: () => context.push(action.route),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F0F11),
            side: const BorderSide(color: Color(0xFF0F0F11)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDailyContextCard(BuildContext context, DailyContext daily) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyItem('Today\'s Goal', '${daily.questionsSolved} / ${daily.questionsGoal} questions'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDailyItem('Scheduled Tasks', '${daily.scheduledTasksRemaining} remaining'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDailyItem('Revision Due', '${daily.revisionDue} items'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDailyItem('Mock Test', 'None scheduled'),
        ],
      ),
    );
  }

  Widget _buildDailyItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildPreparationStatusContext(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0D9), // Pale Green
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preparation Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 8),
          const Text('Improving', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          const Text('3 areas recovering\n2 areas need attention', style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/preparation-health'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Colors.green.shade800,
              alignment: Alignment.centerLeft,
            ),
            child: const Text('View Preparation Health', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
