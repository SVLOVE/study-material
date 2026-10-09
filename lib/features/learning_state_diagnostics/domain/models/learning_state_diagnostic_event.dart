enum DiagnosticEventStatus {
  success,
  pending,
  skipped,
  partial,
  failed,
  retryable,
  invalid,
  stale,
  duplicate,
  superseded,
}

enum DiagnosticFailureCategory {
  none,
  authorizationError,
  validationError,
  dependencyError,
  versionConflict,
  dataUnavailable,
  networkError,
  timeout,
  duplicateOperation,
  concurrencyConflict,
  backendError,
  unknownError,
}

class LearningStateDiagnosticEvent {
  final String eventType;
  final String? operationId;
  final String? scopeType;
  final String? scopeId;
  final String? stateVersion;
  final DiagnosticEventStatus status;
  final DateTime occurredAt;
  final DiagnosticFailureCategory failureCategory;
  final String? errorCode;

  const LearningStateDiagnosticEvent({
    required this.eventType,
    this.operationId,
    this.scopeType,
    this.scopeId,
    this.stateVersion,
    required this.status,
    required this.occurredAt,
    this.failureCategory = DiagnosticFailureCategory.none,
    this.errorCode,
  });

  @override
  String toString() {
    return 'DiagnosticEvent: $eventType (Op: $operationId, Scope: $scopeType:$scopeId, Version: $stateVersion) -> $status [FailCat: $failureCategory]';
  }
}
