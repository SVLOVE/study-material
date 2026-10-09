enum StabilityStatus {
  notApplicable,
  validating,
  stable,
  degraded,
  unstable,
  recovering,
  regressed,
  insufficientEvidence,
  unknown,
}

class RecoveryStabilityState {
  final String capability;
  final StabilityStatus status;
  final String? incidentId;
  final String? recoveryOperationId;
  final DateTime? recoveryVerifiedAt;
  final DateTime? stabilityCheckedAt;
  final List<String> affectedScopes;
  final List<String> instabilityReasons;

  const RecoveryStabilityState({
    required this.capability,
    this.status = StabilityStatus.unknown,
    this.incidentId,
    this.recoveryOperationId,
    this.recoveryVerifiedAt,
    this.stabilityCheckedAt,
    this.affectedScopes = const [],
    this.instabilityReasons = const [],
  });

  RecoveryStabilityState copyWith({
    StabilityStatus? status,
    String? incidentId,
    String? recoveryOperationId,
    DateTime? recoveryVerifiedAt,
    DateTime? stabilityCheckedAt,
    List<String>? affectedScopes,
    List<String>? instabilityReasons,
  }) {
    return RecoveryStabilityState(
      capability: capability,
      status: status ?? this.status,
      incidentId: incidentId ?? this.incidentId,
      recoveryOperationId: recoveryOperationId ?? this.recoveryOperationId,
      recoveryVerifiedAt: recoveryVerifiedAt ?? this.recoveryVerifiedAt,
      stabilityCheckedAt: stabilityCheckedAt ?? this.stabilityCheckedAt,
      affectedScopes: affectedScopes ?? this.affectedScopes,
      instabilityReasons: instabilityReasons ?? this.instabilityReasons,
    );
  }
}
