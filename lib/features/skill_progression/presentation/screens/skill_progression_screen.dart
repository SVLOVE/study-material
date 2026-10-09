import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/skill_progression.dart';
import '../../../learning_state_convergence/presentation/widgets/convergence_aware_widget.dart';

class SkillProgressionScreen extends StatelessWidget {
  const SkillProgressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressions = dummySkillProgressions;
    final improvingCount = progressions.where((p) => p.status == SkillProgressionStatus.improving).length;
    final stableCount = progressions.where((p) => p.status == SkillProgressionStatus.stable).length;
    final needsAttentionCount = progressions.where((p) => p.status == SkillProgressionStatus.needsAttention).length;
    final insufficientCount = progressions.where((p) => p.status == SkillProgressionStatus.insufficientData).length;

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
          'Skill Progression',
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
                'See how your demonstrated performance is progressing across the topics you study.',
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 24),
              _buildOverallSummary(improvingCount, stableCount, needsAttentionCount, insufficientCount),
              const SizedBox(height: 32),
              const Text('Topic Progression', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              ...progressions.map((p) => _buildTopicCard(context, p)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallSummary(int improving, int stable, int needsAttention, int insufficient) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your preparation is progressing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('$improving', 'Improving', Colors.greenAccent),
              _buildSummaryItem('$stable', 'Stable', Colors.tealAccent),
              _buildSummaryItem('$needsAttention', 'Needs Attention', Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 16),
          if (insufficient > 0)
            Text('$insufficient topics have insufficient data', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildTopicCard(BuildContext context, SkillProgression progression) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (progression.status) {
      case SkillProgressionStatus.improving:
        statusColor = Colors.green;
        statusIcon = Icons.trending_up;
        statusLabel = 'Improving';
        break;
      case SkillProgressionStatus.stable:
        statusColor = Colors.teal;
        statusIcon = Icons.trending_flat;
        statusLabel = 'Stable';
        break;
      case SkillProgressionStatus.declining:
        statusColor = Colors.redAccent;
        statusIcon = Icons.trending_down;
        statusLabel = 'Declining';
        break;
      case SkillProgressionStatus.recovering:
        statusColor = Colors.deepPurple;
        statusIcon = Icons.keyboard_double_arrow_up;
        statusLabel = 'Recovering';
        break;
      case SkillProgressionStatus.strong:
        statusColor = Colors.green.shade700;
        statusIcon = Icons.check_circle;
        statusLabel = 'Strong';
        break;
      case SkillProgressionStatus.needsAttention:
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber_rounded;
        statusLabel = 'Needs Attention';
        break;
      case SkillProgressionStatus.insufficientData:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusLabel = 'Insufficient Data';
        break;
    }

    return ConvergenceAwareWidget(
      scopeType: 'topic',
      scopeId: progression.topicId,
      consumerStateVersion: progression.version ?? 'v0', // Assuming domain model needs or has version
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(progression.subjectName, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(progression.topicName, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (progression.status != SkillProgressionStatus.insufficientData) ...[
            Row(
              children: [
                Expanded(
                  child: _buildMetricCol('Earlier Accuracy', '${progression.previousAccuracy?.toStringAsFixed(0)}%'),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                Expanded(
                  child: _buildMetricCol('Recent Accuracy', '${progression.recentAccuracy?.toStringAsFixed(0)}%'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (progression.previousDifficulty != null && progression.currentDifficulty != null)
              Row(
                children: [
                  const Text('Difficulty: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(progression.previousDifficulty!, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 12, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(Icons.arrow_forward, color: Colors.grey, size: 12),
                  ),
                  Text(progression.currentDifficulty!, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.insights, color: Colors.deepPurple, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    progression.evidenceSummary,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to existing Practice
                  context.go('/practice');
                },
                child: const Text('Practice Topic', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
