enum RecoveryStatus {
  notRequired,
  detected,
  validating,
  dependenciesPending,
  stateRevalidation,
  recalculating,
  publishing,
  distributing,
  converging,
  verifying,
  restored,
  partiallyRestored,
  failed,
  retryableFailure,
  blocked,
  unknown,
}

class ServiceRecoveryState {
  final String capability;
  final RecoveryStatus status;
  final DateTime? detectedAt;
  final DateTime? recoveryStartedAt;
  final DateTime? restoredAt;
  final String? operationId;
  final String? incidentId;
  final List<String> blockedBy;
  final List<String> affectedScopes;
  final String? failureCode;

  const ServiceRecoveryState({
    required this.capability,
    this.status = RecoveryStatus.unknown,
    this.detectedAt,
    this.recoveryStartedAt,
    this.restoredAt,
    this.operationId,
    this.incidentId,
    this.blockedBy = const [],
    this.affectedScopes = const [],
    this.failureCode,
  });

  ServiceRecoveryState copyWith({
    RecoveryStatus? status,
    DateTime? detectedAt,
    DateTime? recoveryStartedAt,
    DateTime? restoredAt,
    String? operationId,
    String? incidentId,
    List<String>? blockedBy,
    List<String>? affectedScopes,
    String? failureCode,
  }) {
    return ServiceRecoveryState(
      capability: capability,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
      recoveryStartedAt: recoveryStartedAt ?? this.recoveryStartedAt,
      restoredAt: restoredAt ?? this.restoredAt,
      operationId: operationId ?? this.operationId,
      incidentId: incidentId ?? this.incidentId,
      blockedBy: blockedBy ?? this.blockedBy,
      affectedScopes: affectedScopes ?? this.affectedScopes,
      failureCode: failureCode ?? this.failureCode,
    );
  }
}
