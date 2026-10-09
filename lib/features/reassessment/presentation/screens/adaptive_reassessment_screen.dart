import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/reassessment_candidate.dart';

class AdaptiveReassessmentScreen extends StatelessWidget {
  const AdaptiveReassessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final candidates = dummyReassessmentCandidates;
    final weakCount = candidates.where((c) => c.status == 'Still Weak' || c.status == 'Declined').length;
    final improvedCount = candidates.where((c) => c.status == 'Improved').length;
    final noDataCount = candidates.where((c) => c.status == 'Insufficient Data').length;

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
          'Adaptive Reassessment',
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
                    'Use your recent performance to decide what to reassess next.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 24),
                  _buildHeroSummary(context, weakCount, improvedCount, noDataCount),
                  const SizedBox(height: 32),
                  const Text(
                    'Needs More Reinforcement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final weakCandidates = candidates.where((c) => c.status == 'Still Weak' || c.status == 'Declined').toList();
                  return _buildCandidateCard(context, weakCandidates[index]);
                },
                childCount: candidates.where((c) => c.status == 'Still Weak' || c.status == 'Declined').length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Not Enough Evidence',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  ...candidates
                      .where((c) => c.status == 'Insufficient Data')
                      .map((c) => _buildCandidateCard(context, c)),
                  const SizedBox(height: 16),
                  const Text(
                    'Improved Areas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  ...candidates
                      .where((c) => c.status == 'Improved' || c.status == 'Stable')
                      .map((c) => _buildCandidateCard(context, c)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, int weak, int improved, int noData) {
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
            child: const Text('Your Next Reassessment', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          _buildHeroBullet(Icons.refresh, '$weak topics need another review', const Color(0xFFFDECEB), Colors.redAccent),
          const SizedBox(height: 12),
          _buildHeroBullet(Icons.trending_up, '$improved topics improved', const Color(0xFFE2F0D9), Colors.green),
          const SizedBox(height: 12),
          _buildHeroBullet(Icons.help_outline, '$noData topic needs more evidence', const Color(0xFFFDF0D5), Colors.orange),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Preselect a weak topic and launch practice flow
                context.push('/practice');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F0F11),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Reassessment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBullet(IconData icon, String text, Color bgColor, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: bgColor), // using the solid color variant for visibility on dark bg
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildCandidateCard(BuildContext context, ReassessmentCandidate candidate) {
    Color statusColor = Colors.grey;
    Color statusBg = const Color(0xFFF3F4F6);
    IconData statusIcon = Icons.info_outline;

    if (candidate.status == 'Still Weak' || candidate.status == 'Declined') {
      statusColor = Colors.red;
      statusBg = const Color(0xFFFDECEB);
      statusIcon = Icons.warning_amber_rounded;
    } else if (candidate.status == 'Improved') {
      statusColor = Colors.green;
      statusBg = const Color(0xFFE2F0D9);
      statusIcon = Icons.check_circle_outline;
    } else if (candidate.status == 'Insufficient Data') {
      statusColor = Colors.orange;
      statusBg = const Color(0xFFFDF0D5);
      statusIcon = Icons.help_outline;
    } else if (candidate.status == 'Stable') {
      statusColor = Colors.blue;
      statusBg = Colors.blue.shade50;
      statusIcon = Icons.horizontal_rule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                      Text(
                        candidate.topic,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${candidate.exam} • ${candidate.subject}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        candidate.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (candidate.previousAccuracy != null || candidate.latestAccuracy != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Color(0xFFF3F4F6)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAccuracyMetric('Previous', candidate.previousAccuracy),
                  const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                  _buildAccuracyMetric('Latest', candidate.latestAccuracy),
                  Container(height: 30, width: 1, color: Colors.grey.shade300),
                  _buildChangeMetric(candidate.change),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActionTitle(candidate.status),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    candidate.reason,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, candidate),
          ],
        ),
      ),
    );
  }

  String _getActionTitle(String status) {
    switch (status) {
      case 'Still Weak':
        return 'Recommended Action:';
      case 'Declined':
        return 'Recommended Next Step:';
      case 'Insufficient Data':
        return 'Why wait?';
      case 'Improved':
      case 'Stable':
      default:
        return 'Status:';
    }
  }

  Widget _buildAccuracyMetric(String label, double? value) {
    return Column(
      children: [
        Text(
          value != null ? '${value.toStringAsFixed(0)}%' : '--',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
        ),
      ],
    );
  }

  Widget _buildChangeMetric(double? change) {
    if (change == null) {
      return _buildAccuracyMetric('Change', null);
    }
    
    final isPositive = change > 0;
    final isNeutral = change == 0;
    final color = isPositive ? Colors.green : (isNeutral ? Colors.blue : Colors.red);
    final sign = isPositive ? '+' : '';

    return Column(
      children: [
        Text(
          '$sign${change.toStringAsFixed(0)} pp',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        const Text(
          'Change',
          style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ReassessmentCandidate candidate) {
    if (candidate.status == 'Still Weak' || candidate.status == 'Declined') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.push('/topics/${candidate.id}'), // Hypothetical topic review route
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F0F11),
                side: const BorderSide(color: Color(0xFF0F0F11)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Review Topic'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push('/practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F11),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reassess'),
            ),
          ),
        ],
      );
    } else if (candidate.status == 'Insufficient Data') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => context.push('/practice'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F0F11),
            side: const BorderSide(color: Color(0xFF0F0F11)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Practice Topic'),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => context.push('/dashboard'), // Assuming dashboard or roadmap
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Continue Preparation', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }
  }
}
