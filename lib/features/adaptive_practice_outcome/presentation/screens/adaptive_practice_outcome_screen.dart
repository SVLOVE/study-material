import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/adaptive_practice_outcome.dart';
import '../../../learning_evidence_provenance/domain/models/learning_evidence_provenance.dart';
import '../../../learning_evidence_provenance/application/services/learning_evidence_service.dart';
import '../../../practice_session_integrity/domain/models/practice_session_integrity.dart';
import '../../../learning_evidence_reconciliation/domain/models/learning_evidence_reconciliation.dart';
import '../../../learning_evidence_reconciliation/application/services/learning_evidence_reconciliation_service.dart';
import '../../../learning_state_consistency/domain/models/learning_state_consistency.dart';
import '../../../learning_state_consistency/application/services/learning_state_consistency_service.dart';
import '../../../learning_state_snapshot/domain/models/learning_state_snapshot.dart';
import '../../../learning_state_snapshot/application/services/learning_state_snapshot_service.dart';
import '../../../learning_state_dependency/application/services/learning_state_dependency_resolver.dart';
import '../../../learning_state_dependency/application/services/learning_state_propagation_service.dart';
import '../../../learning_state_recalculation/application/services/learning_state_orchestrator_service.dart';
import '../../../learning_state_publication/application/services/learning_state_publication_service.dart';

class AdaptivePracticeOutcomeScreen extends StatefulWidget {
  final String sessionId;

  const AdaptivePracticeOutcomeScreen({super.key, required this.sessionId});

  @override
  State<AdaptivePracticeOutcomeScreen> createState() => _AdaptivePracticeOutcomeScreenState();
}

class _AdaptivePracticeOutcomeScreenState extends State<AdaptivePracticeOutcomeScreen> {
  LearningEvidenceProvenance? _provenance;
  LearningEvidenceReconciliation? _reconciliation;
  LearningStateConsistency? _consistency;
  LearningStateSnapshot? _snapshot;
  bool _isLoading = true;
  bool _isRecovering = false;

  @override
  void initState() {
    super.initState();
    _processEvidence();
  }

  Future<void> _processEvidence() async {
    // Simulate fetching integrity and verifying provenance before showing outcome
    final mockIntegrity = PracticeSessionIntegrity(
      sessionId: widget.sessionId,
      status: 'Valid',
      expectedQuestionCount: 10,
      deliveredQuestionCount: 10,
      answeredQuestionCount: 10,
      unansweredQuestionCount: 0,
      questionSetConsistent: true,
      attemptCountConsistent: true,
      submissionConsistent: true,
      submittedAt: DateTime.now(),
    );

    final provenance = await learningEvidenceService.validatePracticeEvidence(
      sessionIntegrity: mockIntegrity,
      resultId: 'result-${widget.sessionId}',
      topicId: 'mixed-topic',
    );

    final reconciliation = await learningEvidenceReconciliationService.reconcileEvidence(provenance);
    final consistency = await learningStateConsistencyService.checkEvidenceConsistency(reconciliation);
    
    // Resolve impact and propagate selective invalidation
    if (consistency.status != LearningConsistencyStatus.consistent) {
      final impact = await learningStateDependencyResolver.resolveImpact(provenance);
      
      final plan = learningStateOrchestratorService.createPlan(
        userId: 'user123',
        evidenceId: provenance.evidenceId,
        impact: impact,
      );
      
      await learningStateOrchestratorService.executePlan(plan);
      
      final targetVersion = 'v_${DateTime.now().millisecondsSinceEpoch}';
      final publication = learningStatePublicationService.preparePublication(
        userId: 'user123',
        evidenceId: provenance.evidenceId,
        plan: plan,
        targetVersion: targetVersion,
      );
      
      await learningStatePublicationService.commitAndPublish(
        publication: publication,
        impact: impact,
      );
    }
    
    final snapshot = await learningStateSnapshotService.getSnapshot(userId: 'user123');

    if (mounted) {
      setState(() {
        _provenance = provenance;
        _reconciliation = reconciliation;
        _consistency = consistency;
        _snapshot = snapshot;
        _isLoading = false;
      });
    }
  }

  Future<void> _recoverState() async {
    if (_consistency == null || _consistency!.missingTargets.isEmpty) return;

    setState(() {
      _isRecovering = true;
    });

    await learningStateSnapshotService.markUpdating(userId: 'user123');

    final newConsistency = await learningStateConsistencyService.requestRecovery(
      _consistency!.evidenceId,
      _consistency!.missingTargets,
    );

    await learningStateSnapshotService.publishNewVersion(
      userId: 'user123',
      latestEvidenceAt: DateTime.now(),
    );

    final newSnapshot = await learningStateSnapshotService.getSnapshot(userId: 'user123');

    if (mounted) {
      setState(() {
        _consistency = newConsistency;
        _snapshot = newSnapshot;
        _isRecovering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAE4F7),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F0F11)),
        ),
      );
    }

    final outcome = dummyPracticeOutcome;

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
          'Adaptive Practice Complete',
          style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_provenance != null) _buildProvenanceBanner(_provenance!),
              if (_consistency != null) ...[
                const SizedBox(height: 12),
                _buildConsistencyBanner(_consistency!),
              ],
              if (_snapshot != null) ...[
                const SizedBox(height: 12),
                _buildFreshnessBanner(_snapshot!),
              ],
              const SizedBox(height: 16),
              _buildResultSummary(outcome),
              const SizedBox(height: 24),
              const Text('Composition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              _buildCompositionSummary(outcome),
              const SizedBox(height: 24),
              const Text('Topic Outcomes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              ...outcome.topicOutcomes.map(_buildTopicOutcomeCard),
              const SizedBox(height: 24),
              const Text('Difficulty Outcome', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              _buildDifficultyCard(outcome),
              const SizedBox(height: 24),
              const Text('What this tells you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2ECE9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  outcome.explanation,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11), height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/skill-progression');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('View Skill Progression', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/practice'); // practice again conceptually
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0F0F11)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Practice Again', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProvenanceBanner(LearningEvidenceProvenance provenance) {
    Color bgColor = const Color(0xFFF3F4F6);
    Color textColor = const Color(0xFF0F0F11);
    IconData icon = Icons.info_outline;

    if (provenance.status == 'Valid') {
      bgColor = const Color(0xFFE2F0D9);
      textColor = Colors.green.shade900;
      icon = Icons.verified_user_outlined;
    } else if (provenance.status == 'Duplicate' || provenance.status == 'Invalid') {
      bgColor = const Color(0xFFFDE8E8);
      textColor = Colors.red.shade900;
      icon = Icons.error_outline;
    } else if (provenance.status == 'InsufficientEvidence') {
      bgColor = const Color(0xFFFDF0D5);
      textColor = Colors.orange.shade900;
      icon = Icons.warning_amber_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Evidence Provenance: ${provenance.status} | Source: ${provenance.sourceType}',
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyBanner(LearningStateConsistency consistency) {
    Color bgColor = const Color(0xFFF3F4F6);
    Color textColor = const Color(0xFF0F0F11);
    IconData icon = Icons.sync;
    String message = 'Syncing...';
    bool showRetry = false;

    switch (consistency.status) {
      case LearningConsistencyStatus.consistent:
      case LearningConsistencyStatus.recovered:
        bgColor = const Color(0xFFE2F0D9);
        textColor = Colors.green.shade900;
        icon = Icons.done_all;
        message = 'Your preparation progress is up to date.';
        break;
      case LearningConsistencyStatus.recoverable:
      case LearningConsistencyStatus.partiallyConsistent:
        bgColor = const Color(0xFFFDF0D5);
        textColor = Colors.orange.shade900;
        icon = Icons.sync_problem;
        message = 'Some preparation insights are still updating.';
        showRetry = true;
        break;
      case LearningConsistencyStatus.unrecoverable:
      case LearningConsistencyStatus.inconsistent:
        bgColor = const Color(0xFFFDE8E8);
        textColor = Colors.red.shade900;
        icon = Icons.error_outline;
        message = 'Your result is safe, but some preparation insights could not be updated yet.';
        showRetry = true;
        break;
      case LearningConsistencyStatus.recoveryInProgress:
        bgColor = const Color(0xFFE2ECE9);
        textColor = Colors.teal.shade900;
        icon = Icons.hourglass_top;
        message = 'Recovering your preparation insights...';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF0F0F11);
        icon = Icons.info_outline;
        message = 'Verifying progress state...';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          if (showRetry)
            TextButton(
              onPressed: _isRecovering ? null : _recoverState,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: _isRecovering
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildFreshnessBanner(LearningStateSnapshot snapshot) {
    Color bgColor = const Color(0xFFF3F4F6);
    Color textColor = const Color(0xFF0F0F11);
    IconData icon = Icons.info_outline;
    String message = 'Progress freshness is currently unavailable.';

    switch (snapshot.status) {
      case LearningStateFreshness.current:
        bgColor = const Color(0xFFE2F0D9);
        textColor = Colors.green.shade900;
        icon = Icons.check_circle_outline;
        message = 'Your progress is up to date (Version ${snapshot.stateVersion}).';
        break;
      case LearningStateFreshness.stale:
        bgColor = const Color(0xFFFDF0D5);
        textColor = Colors.orange.shade900;
        icon = Icons.update;
        message = 'New progress is available.';
        break;
      case LearningStateFreshness.updating:
        bgColor = const Color(0xFFE2ECE9);
        textColor = Colors.teal.shade900;
        icon = Icons.hourglass_top;
        message = 'Updating your progress...';
        break;
      case LearningStateFreshness.pending:
        bgColor = const Color(0xFFFDF0D5);
        textColor = Colors.orange.shade900;
        icon = Icons.access_time;
        message = 'Your latest activity is still being processed.';
        break;
      case LearningStateFreshness.invalidated:
        bgColor = const Color(0xFFFDE8E8);
        textColor = Colors.red.shade900;
        icon = Icons.error_outline;
        message = 'Progress data is outdated. Please refresh.';
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSummary(AdaptivePracticeOutcome outcome) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('${outcome.totalQuestions}', 'Questions', Colors.white),
              _buildSummaryItem('${outcome.correctAnswers}', 'Correct', Colors.greenAccent),
              _buildSummaryItem('${outcome.accuracy.toStringAsFixed(0)}%', 'Accuracy', Colors.tealAccent),
            ],
          ),
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

  Widget _buildCompositionSummary(AdaptivePracticeOutcome outcome) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompositionRow('Weak Topics', outcome.weakTopicsTarget),
          const SizedBox(height: 12),
          _buildCompositionRow('Revision', outcome.revisionTarget),
          const SizedBox(height: 12),
          _buildCompositionRow('Skill Reinforcement', outcome.skillReinforcementTarget),
        ],
      ),
    );
  }

  Widget _buildCompositionRow(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
        Text('$count questions', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
      ],
    );
  }

  Widget _buildTopicOutcomeCard(TopicOutcome topic) {
    Color statusColor = Colors.grey;
    String statusLabel = '';

    switch (topic.status) {
      case PracticeOutcomeStatus.stronger:
        statusColor = Colors.green;
        statusLabel = 'Stronger';
        break;
      case PracticeOutcomeStatus.consistent:
        statusColor = Colors.teal;
        statusLabel = 'Consistent';
        break;
      case PracticeOutcomeStatus.needsAttention:
        statusColor = Colors.orange;
        statusLabel = 'Needs Attention';
        break;
      case PracticeOutcomeStatus.insufficientEvidence:
        statusColor = Colors.grey;
        statusLabel = 'Insufficient Data';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Text(topic.topicName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Text(
                statusLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (topic.previousAccuracy != null) ...[
                _buildMetricCol('Previous', '${topic.previousAccuracy?.toStringAsFixed(0)}%'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                ),
              ],
              _buildMetricCol('This Session', '${topic.accuracy.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(AdaptivePracticeOutcome outcome) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Level', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(outcome.difficultyLevel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Outcome', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(outcome.difficultyFeedback, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
