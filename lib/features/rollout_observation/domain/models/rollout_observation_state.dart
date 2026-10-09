enum RolloutObservationStatus {
  notRequired,
  observing,
  healthy,
  degraded,
  unstable,
  blocked,
  hold,
  reduced,
  completed,
  insufficientEvidence,
  unknown,
}

enum RolloutDecision {
  continueExposure,
  holdExposure,
  reduceExposure,
  completeExposure,
  unknown,
}

class ReleaseObservationContext {
  final String? releaseId;
  final String? environment;
  final RolloutObservationStatus status;
  final RolloutDecision decision;
  final String? reason;
  final DateTime? observedAt;

  const ReleaseObservationContext({
    this.releaseId,
    this.environment,
    this.status = RolloutObservationStatus.unknown,
    this.decision = RolloutDecision.unknown,
    this.reason,
    this.observedAt,
  });

  ReleaseObservationContext copyWith({
    String? releaseId,
    String? environment,
    RolloutObservationStatus? status,
    RolloutDecision? decision,
    String? reason,
    DateTime? observedAt,
  }) {
    return ReleaseObservationContext(
      releaseId: releaseId ?? this.releaseId,
      environment: environment ?? this.environment,
      status: status ?? this.status,
      decision: decision ?? this.decision,
      reason: reason ?? this.reason,
      observedAt: observedAt ?? this.observedAt,
    );
  }
}
