enum ReleaseClosureStatus {
  notRequired,
  pending,
  validating,
  readyToClose,
  closing,
  closed,
  blocked,
  failed,
  reopened,
  superseded,
  unknown,
}

class ReleaseLifecycleRecord {
  final String? id;
  final String? releaseId;
  final String? version;
  final String? environment;

  final String? deploymentId;
  final String? verificationId;
  final String? compatibilityId;
  final String? rolloutId;
  final String? observationId;
  final String? finalizationId;
  final String? knownGoodStateId;

  final ReleaseClosureStatus status;

  final DateTime? finalizedAt;
  final DateTime? closedAt;
  final DateTime? supersededAt;

  const ReleaseLifecycleRecord({
    this.id,
    this.releaseId,
    this.version,
    this.environment,
    this.deploymentId,
    this.verificationId,
    this.compatibilityId,
    this.rolloutId,
    this.observationId,
    this.finalizationId,
    this.knownGoodStateId,
    this.status = ReleaseClosureStatus.unknown,
    this.finalizedAt,
    this.closedAt,
    this.supersededAt,
  });

  ReleaseLifecycleRecord copyWith({
    String? id,
    String? releaseId,
    String? version,
    String? environment,
    String? deploymentId,
    String? verificationId,
    String? compatibilityId,
    String? rolloutId,
    String? observationId,
    String? finalizationId,
    String? knownGoodStateId,
    ReleaseClosureStatus? status,
    DateTime? finalizedAt,
    DateTime? closedAt,
    DateTime? supersededAt,
  }) {
    return ReleaseLifecycleRecord(
      id: id ?? this.id,
      releaseId: releaseId ?? this.releaseId,
      version: version ?? this.version,
      environment: environment ?? this.environment,
      deploymentId: deploymentId ?? this.deploymentId,
      verificationId: verificationId ?? this.verificationId,
      compatibilityId: compatibilityId ?? this.compatibilityId,
      rolloutId: rolloutId ?? this.rolloutId,
      observationId: observationId ?? this.observationId,
      finalizationId: finalizationId ?? this.finalizationId,
      knownGoodStateId: knownGoodStateId ?? this.knownGoodStateId,
      status: status ?? this.status,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      closedAt: closedAt ?? this.closedAt,
      supersededAt: supersededAt ?? this.supersededAt,
    );
  }
}
