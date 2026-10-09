enum DeploymentHandoffStatus {
  notRequired,
  preparing,
  validating,
  ready,
  blocked,
  stale,
  mismatched,
  incomplete,
  failed,
  handedOff,
  cancelled,
  unknown,
}

enum DeploymentHandoffDecision {
  notRequired,
  proceed,
  hold,
  blocked,
  stale,
  mismatched,
  incomplete,
  failed,
  unknown,
}

class DeploymentHandoff {
  final String id;
  final String releaseId;
  final String changeId;
  final String environment;

  final String? version;
  final String? buildNumber;
  final String? commit;
  
  final String? artifactReference;
  final String? migrationReference;

  final DeploymentHandoffStatus status;
  final DeploymentHandoffDecision decision;
  
  final String? decisionReason;

  final DateTime createdAt;
  final DateTime? validatedAt;
  final DateTime? handedOffAt;

  const DeploymentHandoff({
    required this.id,
    required this.releaseId,
    required this.changeId,
    required this.environment,
    this.version,
    this.buildNumber,
    this.commit,
    this.artifactReference,
    this.migrationReference,
    this.status = DeploymentHandoffStatus.unknown,
    this.decision = DeploymentHandoffDecision.unknown,
    this.decisionReason,
    required this.createdAt,
    this.validatedAt,
    this.handedOffAt,
  });

  DeploymentHandoff copyWith({
    String? version,
    String? buildNumber,
    String? commit,
    String? artifactReference,
    String? migrationReference,
    DeploymentHandoffStatus? status,
    DeploymentHandoffDecision? decision,
    String? decisionReason,
    DateTime? validatedAt,
    DateTime? handedOffAt,
  }) {
    return DeploymentHandoff(
      id: id,
      releaseId: releaseId,
      changeId: changeId,
      environment: environment,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      commit: commit ?? this.commit,
      artifactReference: artifactReference ?? this.artifactReference,
      migrationReference: migrationReference ?? this.migrationReference,
      status: status ?? this.status,
      decision: decision ?? this.decision,
      decisionReason: decisionReason ?? this.decisionReason,
      createdAt: createdAt,
      validatedAt: validatedAt ?? this.validatedAt,
      handedOffAt: handedOffAt ?? this.handedOffAt,
    );
  }
}
