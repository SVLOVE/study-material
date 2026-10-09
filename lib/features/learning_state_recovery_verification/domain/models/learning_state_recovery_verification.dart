enum RecoveryVerificationStatus {
  pending,
  verifying,
  recovered,
  partiallyRecovered,
  stillInconsistent,
  blocked,
  insufficientEvidence,
  failed,
  unknown,
}

class LearningStateRecoveryVerification {
  final String id;
  final String incidentId;
  final String? operationId;

  final String? scopeType;
  final String? scopeId;

  final String? expectedStateVersion;
  final String? observedStateVersion;

  RecoveryVerificationStatus status;

  bool publicationVerified;
  bool distributionVerified;
  bool convergenceVerified;

  final DateTime startedAt;
  DateTime? completedAt;

  LearningStateRecoveryVerification({
    required this.id,
    required this.incidentId,
    this.operationId,
    this.scopeType,
    this.scopeId,
    this.expectedStateVersion,
    this.observedStateVersion,
    this.status = RecoveryVerificationStatus.pending,
    this.publicationVerified = false,
    this.distributionVerified = false,
    this.convergenceVerified = false,
    required this.startedAt,
    this.completedAt,
  });

  bool get isFullyVerified => publicationVerified && distributionVerified && convergenceVerified;
}
