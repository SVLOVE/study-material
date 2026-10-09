import '../../domain/models/learning_evidence_provenance.dart';
import '../../../practice_session_integrity/domain/models/practice_session_integrity.dart';

class LearningEvidenceService {
  // A simple in-memory set to deduplicate processed results for demonstration
  final Set<String> _processedResultIds = {};

  Future<LearningEvidenceProvenance> validatePracticeEvidence({
    required PracticeSessionIntegrity sessionIntegrity,
    required String resultId,
    String? examId,
    String? subjectId,
    String? topicId,
  }) async {
    // Simulate backend verification
    await Future.delayed(const Duration(milliseconds: 300));

    final evidenceId = 'evidence-${DateTime.now().millisecondsSinceEpoch}';

    if (_processedResultIds.contains(resultId)) {
      return LearningEvidenceProvenance(
        evidenceId: evidenceId,
        sourceType: 'Practice',
        sourceId: sessionIntegrity.sessionId,
        sessionId: sessionIntegrity.sessionId,
        resultId: resultId,
        examId: examId,
        subjectId: subjectId,
        topicId: topicId,
        activityType: 'Practice',
        status: 'Duplicate',
        occurredAt: sessionIntegrity.submittedAt,
        validatedAt: DateTime.now(),
      );
    }

    if (!sessionIntegrity.isValid) {
      return LearningEvidenceProvenance(
        evidenceId: evidenceId,
        sourceType: 'Practice',
        sourceId: sessionIntegrity.sessionId,
        sessionId: sessionIntegrity.sessionId,
        resultId: resultId,
        examId: examId,
        subjectId: subjectId,
        topicId: topicId,
        activityType: 'Practice',
        status: 'Invalid',
        occurredAt: sessionIntegrity.submittedAt,
        validatedAt: DateTime.now(),
      );
    }

    if (sessionIntegrity.answeredQuestionCount == 0) {
      return LearningEvidenceProvenance(
        evidenceId: evidenceId,
        sourceType: 'Practice',
        sourceId: sessionIntegrity.sessionId,
        sessionId: sessionIntegrity.sessionId,
        resultId: resultId,
        examId: examId,
        subjectId: subjectId,
        topicId: topicId,
        activityType: 'Practice',
        status: 'InsufficientEvidence',
        occurredAt: sessionIntegrity.submittedAt,
        validatedAt: DateTime.now(),
      );
    }

    _processedResultIds.add(resultId);

    return LearningEvidenceProvenance(
      evidenceId: evidenceId,
      sourceType: 'Practice',
      sourceId: sessionIntegrity.sessionId,
      sessionId: sessionIntegrity.sessionId,
      resultId: resultId,
      examId: examId,
      subjectId: subjectId,
      topicId: topicId,
      activityType: 'Practice',
      status: 'Valid',
      occurredAt: sessionIntegrity.submittedAt,
      validatedAt: DateTime.now(),
    );
  }
}

final learningEvidenceService = LearningEvidenceService();
