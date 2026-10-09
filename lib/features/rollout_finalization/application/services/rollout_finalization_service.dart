import 'dart:async';

import '../../domain/models/rollout_finalization_state.dart';

class RolloutFinalizationService {
  ReleaseRolloutFinalization? _currentFinalization;

  void initialize() {}

  void dispose() {}

  ReleaseRolloutFinalization? get currentFinalization => _currentFinalization;

  /// Phase 91: Evaluates if a rollout can be finalized as the new known-good production state
  Future<ReleaseRolloutFinalization> evaluateFinalization({
    required String releaseId,
    required bool isCompatible,
    required bool isProductionReady,
    required bool isPostDeploymentVerified,
    required bool isRolloutObservationHealthy,
    required bool isRolloutObservationCompleted,
    required bool hasActiveIncidents,
  }) async {
    
    RolloutFinalizationStatus finalStatus;
    String decision;
    String? blockingReason;
    String decisionReason;

    // Evaluate Blocking conditions first
    if (hasActiveIncidents) {
      finalStatus = RolloutFinalizationStatus.blocked;
      decision = 'BLOCKED';
      blockingReason = 'Active incident detected on production environment.';
      decisionReason = 'Cannot finalize a release while an incident is active.';
    } else if (!isCompatible) {
      finalStatus = RolloutFinalizationStatus.blocked;
      decision = 'BLOCKED';
      blockingReason = 'Release is not compatible (Phase 88).';
      decisionReason = 'Incompatible releases cannot become the known-good state.';
    } else if (!isProductionReady || !isPostDeploymentVerified) {
      finalStatus = RolloutFinalizationStatus.blocked;
      decision = 'BLOCKED';
      blockingReason = 'Deployment readiness or post-deployment verification failed (Phase 86/87).';
      decisionReason = 'Only fully verified deployments can be finalized.';
    } else if (!isRolloutObservationHealthy) {
      finalStatus = RolloutFinalizationStatus.hold;
      decision = 'HOLD';
      blockingReason = 'Observation health is not strictly healthy (Phase 90).';
      decisionReason = 'Release exposure must be completely healthy to finalize.';
    } else if (!isRolloutObservationCompleted) {
      finalStatus = RolloutFinalizationStatus.continuing;
      decision = 'CONTINUE';
      decisionReason = 'Release remains safe, but intended exposure observation has not yet completed.';
    } else {
      finalStatus = RolloutFinalizationStatus.finalized;
      decision = 'COMPLETE';
      decisionReason = 'Rollout completed successfully. Authorizing as the new known-good production state.';
    }

    _currentFinalization = ReleaseRolloutFinalization(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      releaseId: releaseId,
      environment: 'production',
      status: finalStatus,
      decision: decision,
      blockingReason: blockingReason,
      decisionReason: decisionReason,
      evaluatedAt: DateTime.now(),
      finalizedAt: finalStatus == RolloutFinalizationStatus.finalized ? DateTime.now() : null,
    );

    return _currentFinalization!;
  }
}

final rolloutFinalizationService = RolloutFinalizationService();
