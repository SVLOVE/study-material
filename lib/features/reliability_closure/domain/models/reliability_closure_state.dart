enum ClosureStatus {
  notRequired,
  pending,
  validating,
  blocked,
  readyToClose,
  closing,
  closed,
  partiallyClosed,
  failed,
  reopened,
  insufficientEvidence,
  unknown,
}

class ReliabilityClosureState {
  final String capability;
  final String? incidentId;
  final String? recoveryOperationId;
  final ClosureStatus status;
  final List<String> affectedScopes;
  final List<String> blockingConditions;
  final DateTime? validatedAt;
  final String? stateVersion;

  const ReliabilityClosureState({
    required this.capability,
    this.status = ClosureStatus.unknown,
    this.incidentId,
    this.recoveryOperationId,
    this.affectedScopes = const [],
    this.blockingConditions = const [],
    this.validatedAt,
    this.stateVersion,
  });

  ReliabilityClosureState copyWith({
    ClosureStatus? status,
    String? incidentId,
    String? recoveryOperationId,
    List<String>? affectedScopes,
    List<String>? blockingConditions,
    DateTime? validatedAt,
    String? stateVersion,
  }) {
    return ReliabilityClosureState(
      capability: capability,
      status: status ?? this.status,
      incidentId: incidentId ?? this.incidentId,
      recoveryOperationId: recoveryOperationId ?? this.recoveryOperationId,
      affectedScopes: affectedScopes ?? this.affectedScopes,
      blockingConditions: blockingConditions ?? this.blockingConditions,
      validatedAt: validatedAt ?? this.validatedAt,
      stateVersion: stateVersion ?? this.stateVersion,
    );
  }
}
