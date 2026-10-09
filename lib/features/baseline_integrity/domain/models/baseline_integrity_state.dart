enum ReleaseBaselineStatus {
  notRequired,
  validating,
  valid,
  invalid,
  stale,
  superseded,
  blocked,
  insufficientEvidence,
  unknown,
}

class ReleaseBaselineValidation {
  final String? id;
  final String? releaseId;
  final String? environment;

  final ReleaseBaselineStatus status;

  final String? knownGoodStateId;
  final String? closureId;
  final String? deploymentId;
  final String? verificationId;
  final String? migrationVersion;

  final DateTime? validatedAt;

  final String? blockingReason;
  final String? validationSummary;

  const ReleaseBaselineValidation({
    this.id,
    this.releaseId,
    this.environment,
    this.status = ReleaseBaselineStatus.unknown,
    this.knownGoodStateId,
    this.closureId,
    this.deploymentId,
    this.verificationId,
    this.migrationVersion,
    this.validatedAt,
    this.blockingReason,
    this.validationSummary,
  });

  ReleaseBaselineValidation copyWith({
    String? id,
    String? releaseId,
    String? environment,
    ReleaseBaselineStatus? status,
    String? knownGoodStateId,
    String? closureId,
    String? deploymentId,
    String? verificationId,
    String? migrationVersion,
    DateTime? validatedAt,
    String? blockingReason,
    String? validationSummary,
  }) {
    return ReleaseBaselineValidation(
      id: id ?? this.id,
      releaseId: releaseId ?? this.releaseId,
      environment: environment ?? this.environment,
      status: status ?? this.status,
      knownGoodStateId: knownGoodStateId ?? this.knownGoodStateId,
      closureId: closureId ?? this.closureId,
      deploymentId: deploymentId ?? this.deploymentId,
      verificationId: verificationId ?? this.verificationId,
      migrationVersion: migrationVersion ?? this.migrationVersion,
      validatedAt: validatedAt ?? this.validatedAt,
      blockingReason: blockingReason ?? this.blockingReason,
      validationSummary: validationSummary ?? this.validationSummary,
    );
  }
}
