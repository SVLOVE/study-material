enum ValidationEvidenceStatus {
  pending,
  valid,
  partial,
  invalid,
  stale,
  duplicate,
  superseded,
  insufficientEvidence,
  unknown,
}

class ValidationEvidence {
  final String id;
  final String validationPlanId;
  final String validationItemId;

  final String changeId;
  final String changeVersion;
  final String baselineReleaseId;
  final String environment;

  final String evidenceType;
  final ValidationEvidenceStatus status;

  final String? resultReference;
  final String? failureReason;

  final DateTime? recordedAt;

  const ValidationEvidence({
    required this.id,
    required this.validationPlanId,
    required this.validationItemId,
    required this.changeId,
    required this.changeVersion,
    required this.baselineReleaseId,
    required this.environment,
    required this.evidenceType,
    this.status = ValidationEvidenceStatus.pending,
    this.resultReference,
    this.failureReason,
    this.recordedAt,
  });

  ValidationEvidence copyWith({
    String? id,
    String? validationPlanId,
    String? validationItemId,
    String? changeId,
    String? changeVersion,
    String? baselineReleaseId,
    String? environment,
    String? evidenceType,
    ValidationEvidenceStatus? status,
    String? resultReference,
    String? failureReason,
    DateTime? recordedAt,
  }) {
    return ValidationEvidence(
      id: id ?? this.id,
      validationPlanId: validationPlanId ?? this.validationPlanId,
      validationItemId: validationItemId ?? this.validationItemId,
      changeId: changeId ?? this.changeId,
      changeVersion: changeVersion ?? this.changeVersion,
      baselineReleaseId: baselineReleaseId ?? this.baselineReleaseId,
      environment: environment ?? this.environment,
      evidenceType: evidenceType ?? this.evidenceType,
      status: status ?? this.status,
      resultReference: resultReference ?? this.resultReference,
      failureReason: failureReason ?? this.failureReason,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
