enum RecalculationStatus {
  pending,
  ready,
  calculating,
  updated,
  skipped,
  failed,
  retryable,
  blocked,
  stale,
  superseded,
}

class LearningStateTarget {
  final String stateType;
  final String? scopeId;
  final int dependencyLevel;
  RecalculationStatus status;

  LearningStateTarget({
    required this.stateType,
    this.scopeId,
    required this.dependencyLevel,
    this.status = RecalculationStatus.pending,
  });
}

class LearningStateRecalculationPlan {
  final String userId;
  final String? evidenceId;
  final List<LearningStateTarget> targets;
  final DateTime createdAt;

  const LearningStateRecalculationPlan({
    required this.userId,
    this.evidenceId,
    required this.targets,
    required this.createdAt,
  });

  bool get isComplete => targets.every((t) =>
      t.status == RecalculationStatus.updated ||
      t.status == RecalculationStatus.skipped ||
      t.status == RecalculationStatus.superseded);
      
  bool get hasFailures => targets.any((t) =>
      t.status == RecalculationStatus.failed ||
      t.status == RecalculationStatus.retryable ||
      t.status == RecalculationStatus.blocked);
}
