enum LearningStateFreshness {
  current,
  stale,
  updating,
  pending,
  invalidated,
  unknown,
}

class LearningStateSnapshot {
  final String id;
  final String userId;
  final String? scopeId;
  final String scopeType; // e.g., 'global', 'exam', 'subject', 'topic'

  final int stateVersion;
  final DateTime generatedAt;
  final DateTime? latestEvidenceAt;
  final LearningStateFreshness status;

  const LearningStateSnapshot({
    required this.id,
    required this.userId,
    this.scopeId,
    required this.scopeType,
    required this.stateVersion,
    required this.generatedAt,
    this.latestEvidenceAt,
    required this.status,
  });

  bool get isCurrent => status == LearningStateFreshness.current;
  bool get isStale => status == LearningStateFreshness.stale;
  bool get isUpdating => status == LearningStateFreshness.updating;
}
