enum CompatibilityGateDecision {
  notRequired,
  proceed,
  conditional,
  hold,
  blocked,
  insufficientEvidence,
  stale,
  unknown,
}

class CompatibilityGateDecisionRecord {
  final String id;
  final String baselineReleaseId;
  final String changeId;
  final String validationGateId;
  final String? compatibilityResultId;

  final CompatibilityGateDecision decision;

  final List<String> blockingConditions;
  final List<String> pendingConditions;
  
  final String? decisionReason;

  final DateTime evaluatedAt;

  const CompatibilityGateDecisionRecord({
    required this.id,
    required this.baselineReleaseId,
    required this.changeId,
    required this.validationGateId,
    this.compatibilityResultId,
    this.decision = CompatibilityGateDecision.unknown,
    this.blockingConditions = const [],
    this.pendingConditions = const [],
    this.decisionReason,
    required this.evaluatedAt,
  });
}
