class LearningEvidenceProvenance {
  final String evidenceId;
  final String sourceType;
  final String? sourceId;
  
  final String? sessionId;
  final String? resultId;
  final String? attemptId;

  final String? examId;
  final String? subjectId;
  final String? topicId;
  final String? questionId;

  final String? activityType;
  final String status;

  final DateTime? occurredAt;
  final DateTime? recordedAt;
  final DateTime? validatedAt;

  const LearningEvidenceProvenance({
    required this.evidenceId,
    required this.sourceType,
    this.sourceId,
    this.sessionId,
    this.resultId,
    this.attemptId,
    this.examId,
    this.subjectId,
    this.topicId,
    this.questionId,
    this.activityType,
    required this.status,
    this.occurredAt,
    this.recordedAt,
    this.validatedAt,
  });

  bool get isTrustworthy => status == 'Valid' || status == 'Strong Evidence' || status == 'Valid Evidence';
}
