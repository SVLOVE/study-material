import '../../../learning_evidence_reconciliation/domain/models/learning_evidence_reconciliation.dart';

enum LearningConsistencyStatus {
  consistent,
  pending,
  partiallyConsistent,
  inconsistent,
  recoverable,
  recoveryInProgress,
  recovered,
  unrecoverable,
  insufficientEvidence,
}

class LearningStateConsistency {
  final String evidenceId;
  final LearningConsistencyStatus status;
  final List<String> missingTargets;
  final List<String> conflictingTargets;
  final DateTime checkedAt;

  const LearningStateConsistency({
    required this.evidenceId,
    required this.status,
    this.missingTargets = const [],
    this.conflictingTargets = const [],
    required this.checkedAt,
  });

  factory LearningStateConsistency.fromReconciliation(LearningEvidenceReconciliation reconciliation) {
    if (reconciliation.status == 'SYNCED' || reconciliation.status == 'DUPLICATE') {
      return LearningStateConsistency(
        evidenceId: reconciliation.evidenceId,
        status: LearningConsistencyStatus.consistent,
        checkedAt: DateTime.now(),
      );
    }
    
    if (reconciliation.status == 'PARTIALLY_SYNCED' || reconciliation.status == 'FAILED') {
      List<String> missing = [];
      if (!reconciliation.performanceSynced) missing.add('Performance');
      if (!reconciliation.skillProgressionSynced) missing.add('Skill Progression');
      if (!reconciliation.revisionSynced) missing.add('Revision');
      if (!reconciliation.adaptiveLearningSynced) missing.add('Adaptive Learning');
      if (!reconciliation.preparationHealthSynced) missing.add('Preparation Health');
      if (!reconciliation.decisionContextSynced) missing.add('Decision Context');

      return LearningStateConsistency(
        evidenceId: reconciliation.evidenceId,
        status: LearningConsistencyStatus.recoverable,
        missingTargets: missing,
        checkedAt: DateTime.now(),
      );
    }

    if (reconciliation.status == 'INSUFFICIENT_EVIDENCE') {
      return LearningStateConsistency(
        evidenceId: reconciliation.evidenceId,
        status: LearningConsistencyStatus.insufficientEvidence,
        checkedAt: DateTime.now(),
      );
    }

    return LearningStateConsistency(
      evidenceId: reconciliation.evidenceId,
      status: LearningConsistencyStatus.unrecoverable,
      checkedAt: DateTime.now(),
    );
  }
}
