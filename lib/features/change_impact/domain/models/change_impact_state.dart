enum ChangeImpactStatus {
  notRequired,
  analyzing,
  analyzed,
  affected,
  noImpact,
  blocked,
  insufficientEvidence,
  unknown,
}

enum ReleaseScopeDecision {
  noImpact,
  lowScope,
  targetedScope,
  broadScope,
  criticalScope,
  blocked,
  unknown,
}

class ChangeImpactAssessment {
  final String? id;
  final String? baselineReleaseId;
  final String? changeId;
  final String? releaseCandidateId;

  final ChangeImpactStatus status;
  final ReleaseScopeDecision scope;

  final List<String> directlyAffectedAreas;
  final List<String> potentiallyAffectedAreas;
  final List<String> requiredValidations;

  final String? blockingReason;

  final DateTime? analyzedAt;

  const ChangeImpactAssessment({
    this.id,
    this.baselineReleaseId,
    this.changeId,
    this.releaseCandidateId,
    this.status = ChangeImpactStatus.unknown,
    this.scope = ReleaseScopeDecision.unknown,
    this.directlyAffectedAreas = const [],
    this.potentiallyAffectedAreas = const [],
    this.requiredValidations = const [],
    this.blockingReason,
    this.analyzedAt,
  });

  ChangeImpactAssessment copyWith({
    String? id,
    String? baselineReleaseId,
    String? changeId,
    String? releaseCandidateId,
    ChangeImpactStatus? status,
    ReleaseScopeDecision? scope,
    List<String>? directlyAffectedAreas,
    List<String>? potentiallyAffectedAreas,
    List<String>? requiredValidations,
    String? blockingReason,
    DateTime? analyzedAt,
  }) {
    return ChangeImpactAssessment(
      id: id ?? this.id,
      baselineReleaseId: baselineReleaseId ?? this.baselineReleaseId,
      changeId: changeId ?? this.changeId,
      releaseCandidateId: releaseCandidateId ?? this.releaseCandidateId,
      status: status ?? this.status,
      scope: scope ?? this.scope,
      directlyAffectedAreas: directlyAffectedAreas ?? this.directlyAffectedAreas,
      potentiallyAffectedAreas: potentiallyAffectedAreas ?? this.potentiallyAffectedAreas,
      requiredValidations: requiredValidations ?? this.requiredValidations,
      blockingReason: blockingReason ?? this.blockingReason,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}
