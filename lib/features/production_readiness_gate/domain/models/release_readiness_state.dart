enum ReleaseStatus {
  notRequired,
  draft,
  validating,
  ready,
  blocked,
  failed,
  partiallyReady,
  approved,
  deploying,
  deployed,
  postDeploymentValidating,
  verified,
  rolledBack,
  unknown,
}

class ReleaseReadinessState {
  final String version;
  final ReleaseStatus status;
  final List<String> blockingChecks;
  final List<String> warnings;
  final DateTime? validatedAt;

  const ReleaseReadinessState({
    required this.version,
    this.status = ReleaseStatus.unknown,
    this.blockingChecks = const [],
    this.warnings = const [],
    this.validatedAt,
  });

  ReleaseReadinessState copyWith({
    ReleaseStatus? status,
    List<String>? blockingChecks,
    List<String>? warnings,
    DateTime? validatedAt,
  }) {
    return ReleaseReadinessState(
      version: version,
      status: status ?? this.status,
      blockingChecks: blockingChecks ?? this.blockingChecks,
      warnings: warnings ?? this.warnings,
      validatedAt: validatedAt ?? this.validatedAt,
    );
  }
}
