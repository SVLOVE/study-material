import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/action_outcome.dart';
import '../../domain/models/next_action.dart';

class ActionOutcomeScreen extends StatelessWidget {
  final String actionId;

  const ActionOutcomeScreen({super.key, required this.actionId});

  @override
  Widget build(BuildContext context) {
    // In a real app, we'd fetch the outcome by actionId
    final outcome = dummyActionOutcome;
    
    // Refresh next action (Phase 58 simulation)
    final nextAction = dummyPrimaryAction;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F0F11)),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          'Action Outcome',
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
                'See what changed after your last preparation activity.',
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 24),
              _buildHeroCard(context, outcome),
              const SizedBox(height: 32),
              if (outcome.improvements.isNotEmpty) ...[
                const Text(
                  'What Changed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                ),
                const SizedBox(height: 16),
                _buildWhatChangedCard(outcome.improvements),
                const SizedBox(height: 32),
              ],
              const Text(
                'Your Next Step',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              ),
              const SizedBox(height: 16),
              _buildNextStepCard(context, nextAction),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, ActionOutcome outcome) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (outcome.status) {
      case ActionOutcomeStatus.improved:
        statusText = 'Improved';
        statusColor = Colors.green;
        statusIcon = Icons.arrow_upward;
        break;
      case ActionOutcomeStatus.maintained:
        statusText = 'Maintained';
        statusColor = Colors.blue;
        statusIcon = Icons.horizontal_rule;
        break;
      case ActionOutcomeStatus.needsMorePractice:
        statusText = 'Needs More Practice';
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case ActionOutcomeStatus.declined:
        statusText = 'Declined';
        statusColor = Colors.redAccent;
        statusIcon = Icons.arrow_downward;
        break;
      case ActionOutcomeStatus.incomplete:
        statusText = 'Incomplete';
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        break;
      case ActionOutcomeStatus.insufficientData:
        statusText = 'Insufficient Data';
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
        break;
    }

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
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text('${outcome.actionType} Completed', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            outcome.actionTitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text('${outcome.questionsCompleted} questions completed', style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Outcome', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24),
                    const SizedBox(width: 8),
                    Text(statusText, style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (outcome.beforeAccuracy != null && outcome.afterAccuracy != null) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${outcome.beforeAccuracy!.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_forward, color: Colors.white54),
                      Text('${outcome.afterAccuracy!.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${outcome.changePoints! > 0 ? '+' : ''}${outcome.changePoints!.toStringAsFixed(0)} percentage points', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(_getOutcomeDescription(outcome.status), style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  String _getOutcomeDescription(ActionOutcomeStatus status) {
    switch (status) {
      case ActionOutcomeStatus.improved:
        return 'Your latest performance is stronger than your earlier result.';
      case ActionOutcomeStatus.maintained:
        return 'Your performance is currently stable.';
      case ActionOutcomeStatus.needsMorePractice:
        return 'Your latest result shows that this area still needs practice.';
      case ActionOutcomeStatus.declined:
        return 'Your latest result is lower than your earlier result. Consider another focused review.';
      case ActionOutcomeStatus.incomplete:
        return 'This activity was not completed, so there is not enough evidence to evaluate the outcome.';
      case ActionOutcomeStatus.insufficientData:
        return 'The activity was completed, but more performance data is needed to measure the outcome.';
    }
  }

  Widget _buildWhatChangedCard(List<String> improvements) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: improvements.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Text(item, style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNextStepCard(BuildContext context, NextAction nextAction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5), // Soft Yellow
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Continue with:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
          const SizedBox(height: 8),
          Text(nextAction.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          const Text('Why:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
          const SizedBox(height: 4),
          Text(nextAction.reason, style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push(nextAction.route),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F0F11),
                side: const BorderSide(color: Color(0xFF0F0F11)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Next Action', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
