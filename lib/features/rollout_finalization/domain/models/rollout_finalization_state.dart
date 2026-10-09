enum RolloutFinalizationStatus {
  notRequired,
  pending,
  evaluating,
  eligible,
  hold,
  reduced,
  continuing,
  completing,
  finalized,
  blocked,
  failed,
  reopened,
  insufficientEvidence,
  unknown,
}

class ReleaseRolloutFinalization {
  final String? id;
  final String? releaseId;
  final String? environment;
  final String? observationId;
  final String? verificationId;
  final String? knownGoodStateId;

  final RolloutFinalizationStatus status;
  final String? decision;
  final String? blockingReason;
  final String? decisionReason;

  final DateTime? evaluatedAt;
  final DateTime? finalizedAt;

  const ReleaseRolloutFinalization({
    this.id,
    this.releaseId,
    this.environment,
    this.observationId,
    this.verificationId,
    this.knownGoodStateId,
    this.status = RolloutFinalizationStatus.unknown,
    this.decision,
    this.blockingReason,
    this.decisionReason,
    this.evaluatedAt,
    this.finalizedAt,
  });

  ReleaseRolloutFinalization copyWith({
    String? id,
    String? releaseId,
    String? environment,
    String? observationId,
    String? verificationId,
    String? knownGoodStateId,
    RolloutFinalizationStatus? status,
    String? decision,
    String? blockingReason,
    String? decisionReason,
    DateTime? evaluatedAt,
    DateTime? finalizedAt,
  }) {
    return ReleaseRolloutFinalization(
      id: id ?? this.id,
      releaseId: releaseId ?? this.releaseId,
      environment: environment ?? this.environment,
      observationId: observationId ?? this.observationId,
      verificationId: verificationId ?? this.verificationId,
      knownGoodStateId: knownGoodStateId ?? this.knownGoodStateId,
      status: status ?? this.status,
      decision: decision ?? this.decision,
      blockingReason: blockingReason ?? this.blockingReason,
      decisionReason: decisionReason ?? this.decisionReason,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
    );
  }
}
