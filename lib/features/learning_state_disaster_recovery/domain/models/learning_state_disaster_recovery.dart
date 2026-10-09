enum DisasterRecoveryStatus {
  notStarted,
  preparing,
  restoring,
  validating,
  rebuildingDerivedState,
  publishing,
  distributing,
  verifying,
  recovered,
  partiallyRecovered,
  failed,
  blocked,
}

class LearningStateDisasterRecovery {
  final String id;
  final DateTime initiatedAt;
  final String recoveryPointScope;
  final DisasterRecoveryStatus status;
  final bool integrityValidated;
  final bool learningStateValidated;
  final bool provenanceValidated;
  final bool publicationValidated;
  final bool securityValidated;
  
  const LearningStateDisasterRecovery({
    required this.id,
    required this.initiatedAt,
    required this.recoveryPointScope,
    this.status = DisasterRecoveryStatus.notStarted,
    this.integrityValidated = false,
    this.learningStateValidated = false,
    this.provenanceValidated = false,
    this.publicationValidated = false,
    this.securityValidated = false,
  });

  LearningStateDisasterRecovery copyWith({
    DisasterRecoveryStatus? status,
    bool? integrityValidated,
    bool? learningStateValidated,
    bool? provenanceValidated,
    bool? publicationValidated,
    bool? securityValidated,
  }) {
    return LearningStateDisasterRecovery(
      id: id,
      initiatedAt: initiatedAt,
      recoveryPointScope: recoveryPointScope,
      status: status ?? this.status,
      integrityValidated: integrityValidated ?? this.integrityValidated,
      learningStateValidated: learningStateValidated ?? this.learningStateValidated,
      provenanceValidated: provenanceValidated ?? this.provenanceValidated,
      publicationValidated: publicationValidated ?? this.publicationValidated,
      securityValidated: securityValidated ?? this.securityValidated,
    );
  }
}
