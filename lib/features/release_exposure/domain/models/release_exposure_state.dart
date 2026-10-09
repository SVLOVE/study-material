enum ReleaseExposureStatus {
  notRequired,
  pending,
  eligible,
  staged,
  active,
  held,
  reduced,
  blocked,
  completed,
  failed,
  unknown,
}

enum ReleaseExposureScope {
  internal,
  limited,
  general,
}

class ReleaseExposureContext {
  final String? releaseId;
  final String? environment;
  final ReleaseExposureStatus status;
  final ReleaseExposureScope scope;
  final bool eligible;
  final String? reason;
  final DateTime? evaluatedAt;

  const ReleaseExposureContext({
    this.releaseId,
    this.environment,
    this.status = ReleaseExposureStatus.unknown,
    this.scope = ReleaseExposureScope.internal,
    this.eligible = false,
    this.reason,
    this.evaluatedAt,
  });

  ReleaseExposureContext copyWith({
    String? releaseId,
    String? environment,
    ReleaseExposureStatus? status,
    ReleaseExposureScope? scope,
    bool? eligible,
    String? reason,
    DateTime? evaluatedAt,
  }) {
    return ReleaseExposureContext(
      releaseId: releaseId ?? this.releaseId,
      environment: environment ?? this.environment,
      status: status ?? this.status,
      scope: scope ?? this.scope,
      eligible: eligible ?? this.eligible,
      reason: reason ?? this.reason,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }
}
