import '../../domain/models/learning_state_consistency.dart';
import '../../../learning_evidence_reconciliation/domain/models/learning_evidence_reconciliation.dart';
import '../../../learning_evidence_reconciliation/application/services/learning_evidence_reconciliation_service.dart';

class LearningStateConsistencyService {
  Future<LearningStateConsistency> checkEvidenceConsistency(LearningEvidenceReconciliation reconciliation) async {
    // In a real app, this would query backend to verify all downstream targets
    await Future.delayed(const Duration(milliseconds: 200));
    return LearningStateConsistency.fromReconciliation(reconciliation);
  }

  Future<LearningStateConsistency> requestRecovery(String evidenceId, List<String> missingTargets) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate recovery success
    return LearningStateConsistency(
      evidenceId: evidenceId,
      status: LearningConsistencyStatus.recovered,
      checkedAt: DateTime.now(),
    );
  }
}

final learningStateConsistencyService = LearningStateConsistencyService();
