class LearningEvidenceReconciliation {
  final String evidenceId;
  final String? sourceType;
  final String? sourceId;
  final String? sessionId;
  final String? resultId;

  final String status;

  final bool performanceSynced;
  final bool skillProgressionSynced;
  final bool revisionSynced;
  final bool adaptiveLearningSynced;
  final bool preparationHealthSynced;
  final bool decisionContextSynced;

  final DateTime? firstProcessedAt;
  final DateTime? lastProcessedAt;

  final String? failureReason;
  final String? retryAfter;

  final DateTime? completedAt;

  const LearningEvidenceReconciliation({
    required this.evidenceId,
    this.sourceType,
    this.sourceId,
    this.sessionId,
    this.resultId,
    required this.status,
    required this.performanceSynced,
    required this.skillProgressionSynced,
    required this.revisionSynced,
    required this.adaptiveLearningSynced,
    required this.preparationHealthSynced,
    required this.decisionContextSynced,
    this.firstProcessedAt,
    this.lastProcessedAt,
    this.failureReason,
    this.retryAfter,
    this.completedAt,
  });
}
