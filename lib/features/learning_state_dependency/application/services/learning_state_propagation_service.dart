import '../../domain/models/learning_state_impact.dart';
import '../../../learning_state_snapshot/application/services/learning_state_snapshot_service.dart';

class LearningStatePropagationService {
  Future<void> propagateInvalidation({
    required String userId,
    required LearningStateImpact impact,
    required DateTime latestEvidenceAt,
  }) async {
    // Selectively invalidate scoped snapshots rather than a global refresh
    
    // 1. Invalidate topic-level states
    for (final topicId in impact.affectedTopics) {
      await learningStateSnapshotService.invalidateState(
        userId: userId,
        scopeType: 'topic',
        scopeId: topicId,
        latestEvidenceAt: latestEvidenceAt,
      );
    }

    // 2. Invalidate subject-level states
    for (final subjectId in impact.affectedSubjects) {
      await learningStateSnapshotService.invalidateState(
        userId: userId,
        scopeType: 'subject',
        scopeId: subjectId,
        latestEvidenceAt: latestEvidenceAt,
      );
    }

    // 3. Invalidate exam-level states
    for (final examId in impact.affectedExams) {
      await learningStateSnapshotService.invalidateState(
        userId: userId,
        scopeType: 'exam',
        scopeId: examId,
        latestEvidenceAt: latestEvidenceAt,
      );
    }

    // 4. Invalidate specific global features if required
    if (impact.affectedFeatures.isNotEmpty) {
      await learningStateSnapshotService.invalidateState(
        userId: userId,
        scopeType: 'global',
        latestEvidenceAt: latestEvidenceAt,
      );
    }
  }
}

final learningStatePropagationService = LearningStatePropagationService();
