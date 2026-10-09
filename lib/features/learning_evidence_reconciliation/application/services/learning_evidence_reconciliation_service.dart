import '../../domain/models/learning_evidence_reconciliation.dart';
import '../../../learning_evidence_provenance/domain/models/learning_evidence_provenance.dart';

class LearningEvidenceReconciliationService {
  final Set<String> _syncedEvidenceIds = {};

  Future<LearningEvidenceReconciliation> reconcileEvidence(LearningEvidenceProvenance evidence) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!evidence.isTrustworthy) {
      return LearningEvidenceReconciliation(
        evidenceId: evidence.evidenceId,
        sourceType: evidence.sourceType,
        sourceId: evidence.sourceId,
        sessionId: evidence.sessionId,
        resultId: evidence.resultId,
        status: evidence.status == 'Duplicate' ? 'DUPLICATE' : 'INVALID',
        performanceSynced: false,
        skillProgressionSynced: false,
        revisionSynced: false,
        adaptiveLearningSynced: false,
        preparationHealthSynced: false,
        decisionContextSynced: false,
        completedAt: DateTime.now(),
      );
    }

    if (_syncedEvidenceIds.contains(evidence.evidenceId)) {
      return LearningEvidenceReconciliation(
        evidenceId: evidence.evidenceId,
        sourceType: evidence.sourceType,
        sourceId: evidence.sourceId,
        sessionId: evidence.sessionId,
        resultId: evidence.resultId,
        status: 'DUPLICATE',
        performanceSynced: true,
        skillProgressionSynced: true,
        revisionSynced: true,
        adaptiveLearningSynced: true,
        preparationHealthSynced: true,
        decisionContextSynced: true,
        completedAt: DateTime.now(),
      );
    }

    // Simulate downstream sync
    _syncedEvidenceIds.add(evidence.evidenceId);

    return LearningEvidenceReconciliation(
      evidenceId: evidence.evidenceId,
      sourceType: evidence.sourceType,
      sourceId: evidence.sourceId,
      sessionId: evidence.sessionId,
      resultId: evidence.resultId,
      status: 'SYNCED',
      performanceSynced: true,
      skillProgressionSynced: true,
      revisionSynced: true,
      adaptiveLearningSynced: true,
      preparationHealthSynced: true,
      decisionContextSynced: true,
      completedAt: DateTime.now(),
    );
  }
}

final learningEvidenceReconciliationService = LearningEvidenceReconciliationService();
