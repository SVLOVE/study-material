enum ReleaseCompatibilityStatus {
  compatible,
  conditionallyCompatible,
  incompatible,
  unknown,
  notApplicable,
}

enum ReleaseChangeType {
  application,
  database,
  api,
  authentication,
  authorization,
  learningState,
  payment,
  storage,
  dependency,
  configuration,
  localization,
  accessibility,
  performance,
  security,
}

class ReleaseCompatibilityResult {
  final String? previousReleaseId;
  final String? currentReleaseId;
  final ReleaseCompatibilityStatus status;
  final List<String> affectedAreas;
  final List<String> blockingIssues;
  final List<String> conditionalRequirements;
  final DateTime? evaluatedAt;

  const ReleaseCompatibilityResult({
    this.previousReleaseId,
    this.currentReleaseId,
    this.status = ReleaseCompatibilityStatus.unknown,
    this.affectedAreas = const [],
    this.blockingIssues = const [],
    this.conditionalRequirements = const [],
    this.evaluatedAt,
  });

  ReleaseCompatibilityResult copyWith({
    String? previousReleaseId,
    String? currentReleaseId,
    ReleaseCompatibilityStatus? status,
    List<String>? affectedAreas,
    List<String>? blockingIssues,
    List<String>? conditionalRequirements,
    DateTime? evaluatedAt,
  }) {
    return ReleaseCompatibilityResult(
      previousReleaseId: previousReleaseId ?? this.previousReleaseId,
      currentReleaseId: currentReleaseId ?? this.currentReleaseId,
      status: status ?? this.status,
      affectedAreas: affectedAreas ?? this.affectedAreas,
      blockingIssues: blockingIssues ?? this.blockingIssues,
      conditionalRequirements: conditionalRequirements ?? this.conditionalRequirements,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }
}
