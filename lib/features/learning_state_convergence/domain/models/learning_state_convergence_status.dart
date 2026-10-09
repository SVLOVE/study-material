enum ConsumerConvergenceStatus {
  converged,
  pending,
  stale,
  unavailable,
  failed,
  notApplicable,
}

class LearningStateConvergenceContext {
  final String? expectedPublishedVersion;
  final String scopeType;
  final String? scopeId;
  final Map<String, ConsumerConvergenceStatus> consumerStatuses;
  final DateTime checkedAt;

  const LearningStateConvergenceContext({
    this.expectedPublishedVersion,
    required this.scopeType,
    this.scopeId,
    required this.consumerStatuses,
    required this.checkedAt,
  });

  bool get isFullyConverged {
    if (consumerStatuses.isEmpty) return true;
    return consumerStatuses.values.every((status) =>
        status == ConsumerConvergenceStatus.converged ||
        status == ConsumerConvergenceStatus.notApplicable);
  }
}
