enum ValidationGateDecision {
  notRequired,
  eligible,
  hold,
  blocked,
  insufficientEvidence,
  stale,
  unknown,
}

class ValidationGateDecisionRecord {
  final String id;
  final String baselineReleaseId;
  final String changeId;
  final String validationPlanId;

  final ValidationGateDecision decision;

  final List<String> blockingValidationItemIds;
  final List<String> insufficientEvidenceItemIds;
  final List<String> pendingValidationItemIds;

  final String? decisionReason;

  final DateTime evaluatedAt;

  const ValidationGateDecisionRecord({
    required this.id,
    required this.baselineReleaseId,
    required this.changeId,
    required this.validationPlanId,
    this.decision = ValidationGateDecision.unknown,
    this.blockingValidationItemIds = const [],
    this.insufficientEvidenceItemIds = const [],
    this.pendingValidationItemIds = const [],
    this.decisionReason,
    required this.evaluatedAt,
  });
}
