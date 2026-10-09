enum DeploymentEligibilityGateDecision {
  notRequired,
  deploymentEligible,
  hold,
  blocked,
  insufficientEvidence,
  stale,
  unknown,
}

class DeploymentEligibilityGateDecisionRecord {
  final String id;
  final String baselineReleaseId;
  final String changeId;
  final String validationGateId;
  final String compatibilityGateId;
  final String readinessAssessmentId;
  final String environment;

  final DeploymentEligibilityGateDecision decision;

  final List<String> blockingCheckIds;
  final List<String> pendingCheckIds;
  final List<String> staleCheckIds;
  
  final String? decisionReason;

  final DateTime evaluatedAt;

  const DeploymentEligibilityGateDecisionRecord({
    required this.id,
    required this.baselineReleaseId,
    required this.changeId,
    required this.validationGateId,
    required this.compatibilityGateId,
    required this.readinessAssessmentId,
    required this.environment,
    this.decision = DeploymentEligibilityGateDecision.unknown,
    this.blockingCheckIds = const [],
    this.pendingCheckIds = const [],
    this.staleCheckIds = const [],
    this.decisionReason,
    required this.evaluatedAt,
  });
}
