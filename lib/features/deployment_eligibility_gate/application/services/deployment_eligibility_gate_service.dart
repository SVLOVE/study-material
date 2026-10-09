import 'dart:async';

import '../../domain/models/deployment_eligibility_gate_state.dart';
import '../../../validation_gate/domain/models/validation_gate_state.dart';
import '../../../compatibility_gate/domain/models/compatibility_gate_state.dart';
import '../../../production_readiness_gate/domain/models/release_readiness_state.dart';

class DeploymentEligibilityGateService {
  final Map<String, DeploymentEligibilityGateDecisionRecord> _decisions = {};

  void initialize() {}

  void dispose() {}

  DeploymentEligibilityGateDecisionRecord? getDecision(String changeId) => _decisions[changeId];

  /// Phase 99: Evaluates whether the validation, compatibility, and readiness states collectively authorize deployment
  Future<DeploymentEligibilityGateDecisionRecord> evaluateDeploymentEligibility({
    required String changeId,
    required String baselineReleaseId,
    required String environment,
    required ValidationGateDecisionRecord validationGateRecord,
    required CompatibilityGateDecisionRecord compatibilityGateRecord,
    required ReleaseReadinessState readinessAssessment,
  }) async {
    
    // Dependencies Check (Phase 97)
    if (validationGateRecord.decision != ValidationGateDecision.eligible) {
       return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        environment: environment,
        validationGateId: validationGateRecord.id,
        compatibilityGateId: compatibilityGateRecord.id,
        readinessAssessmentId: readinessAssessment.version,
        decision: ValidationGateDecision.blocked == validationGateRecord.decision ? DeploymentEligibilityGateDecision.blocked : DeploymentEligibilityGateDecision.hold,
        reason: 'Validation Gate (Phase 97) is not eligible (status: ${validationGateRecord.decision.name}).',
      );
    }

    // Dependencies Check (Phase 98)
    if (compatibilityGateRecord.decision != CompatibilityGateDecision.proceed && compatibilityGateRecord.decision != CompatibilityGateDecision.notRequired) {
       return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        environment: environment,
        validationGateId: validationGateRecord.id,
        compatibilityGateId: compatibilityGateRecord.id,
        readinessAssessmentId: readinessAssessment.version,
        decision: CompatibilityGateDecision.blocked == compatibilityGateRecord.decision ? DeploymentEligibilityGateDecision.blocked : DeploymentEligibilityGateDecision.hold,
        reason: 'Compatibility Gate (Phase 98) is not proceed (status: ${compatibilityGateRecord.decision.name}).',
      );
    }

    if (readinessAssessment.status == ReleaseStatus.notRequired) {
      return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        environment: environment,
        validationGateId: validationGateRecord.id,
        compatibilityGateId: compatibilityGateRecord.id,
        readinessAssessmentId: readinessAssessment.version,
        decision: DeploymentEligibilityGateDecision.notRequired,
        reason: 'No deployment required for this release.',
      );
    }

    // Evaluate Phase 86 readiness result
    DeploymentEligibilityGateDecision computedDecision;
    String? reason;

    if (readinessAssessment.status == ReleaseStatus.failed || readinessAssessment.status == ReleaseStatus.blocked) {
      computedDecision = DeploymentEligibilityGateDecision.blocked;
      reason = 'Phase 86 marked release as blocked or failed.';
    } else if (readinessAssessment.blockingChecks.isNotEmpty) {
      computedDecision = DeploymentEligibilityGateDecision.blocked;
      reason = 'Phase 86 contains unresolved blocking checks.';
    } else if (readinessAssessment.status == ReleaseStatus.unknown) {
      computedDecision = DeploymentEligibilityGateDecision.hold;
      reason = 'Phase 86 returned an unknown readiness result.';
    } else if (readinessAssessment.status == ReleaseStatus.partiallyReady || readinessAssessment.status == ReleaseStatus.validating || readinessAssessment.status == ReleaseStatus.draft) {
      computedDecision = DeploymentEligibilityGateDecision.hold;
      reason = 'Phase 86 indicates the readiness assessment is still evaluating or incomplete.';
    } else if (readinessAssessment.status == ReleaseStatus.ready || readinessAssessment.status == ReleaseStatus.approved) {
      computedDecision = DeploymentEligibilityGateDecision.deploymentEligible;
      reason = 'Release is deployment eligible. Proceed to Deployment Process.';
    } else {
      computedDecision = DeploymentEligibilityGateDecision.unknown;
      reason = 'Unexpected readiness status.';
    }

    return _recordDecision(
      changeId: changeId,
      baselineReleaseId: baselineReleaseId,
      environment: environment,
      validationGateId: validationGateRecord.id,
      compatibilityGateId: compatibilityGateRecord.id,
      readinessAssessmentId: readinessAssessment.version,
      decision: computedDecision,
      reason: reason,
      blockedChecks: readinessAssessment.blockingChecks,
    );
  }

  DeploymentEligibilityGateDecisionRecord _recordDecision({
    required String changeId,
    required String baselineReleaseId,
    required String environment,
    required String validationGateId,
    required String compatibilityGateId,
    required String readinessAssessmentId,
    required DeploymentEligibilityGateDecision decision,
    String? reason,
    List<String> blockedChecks = const [],
    List<String> pendingChecks = const [],
    List<String> staleChecks = const [],
  }) {
    final record = DeploymentEligibilityGateDecisionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baselineReleaseId: baselineReleaseId,
      changeId: changeId,
      validationGateId: validationGateId,
      compatibilityGateId: compatibilityGateId,
      readinessAssessmentId: readinessAssessmentId,
      environment: environment,
      decision: decision,
      decisionReason: reason,
      blockingCheckIds: blockedChecks,
      pendingCheckIds: pendingChecks,
      staleCheckIds: staleChecks,
      evaluatedAt: DateTime.now(),
    );
    _decisions[changeId] = record;
    return record;
  }
}

final deploymentEligibilityGateService = DeploymentEligibilityGateService();
