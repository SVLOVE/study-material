import 'dart:async';

import '../../domain/models/deployment_handoff_state.dart';
import '../../../deployment_eligibility_gate/domain/models/deployment_eligibility_gate_state.dart';

class DeploymentHandoffService {
  final Map<String, DeploymentHandoff> _handoffs = {};

  void initialize() {}

  void dispose() {}

  DeploymentHandoff? getHandoff(String changeId) => _handoffs[changeId];

  /// Phase 100: Validates that the exact eligible release is safely and correctly identified before handoff
  Future<DeploymentHandoff> validateDeploymentHandoff({
    required String releaseId,
    required String changeId,
    required String environment,
    required DeploymentEligibilityGateDecisionRecord eligibilityRecord,
    String? artifactReference,
    String? expectedArtifactReference,
    String? migrationReference,
    String? expectedMigrationReference,
    bool missingRequiredConfiguration = false,
  }) async {
    
    // Dependencies Check (Phase 99)
    if (eligibilityRecord.decision != DeploymentEligibilityGateDecision.deploymentEligible && eligibilityRecord.decision != DeploymentEligibilityGateDecision.notRequired) {
       return _recordDecision(
        releaseId: releaseId,
        changeId: changeId,
        environment: environment,
        artifactReference: artifactReference,
        migrationReference: migrationReference,
        status: DeploymentHandoffStatus.blocked,
        decision: DeploymentEligibilityGateDecision.stale == eligibilityRecord.decision ? DeploymentHandoffDecision.stale : DeploymentHandoffDecision.blocked,
        reason: 'Deployment Eligibility Gate (Phase 99) is not eligible (status: ${eligibilityRecord.decision.name}).',
      );
    }

    if (eligibilityRecord.decision == DeploymentEligibilityGateDecision.notRequired) {
      return _recordDecision(
        releaseId: releaseId,
        changeId: changeId,
        environment: environment,
        status: DeploymentHandoffStatus.notRequired,
        decision: DeploymentHandoffDecision.notRequired,
        reason: 'No deployment required for this release.',
      );
    }

    // Release Identity Checks
    if (eligibilityRecord.changeId != changeId || eligibilityRecord.baselineReleaseId != releaseId) {
      return _recordDecision(
        releaseId: releaseId,
        changeId: changeId,
        environment: environment,
        status: DeploymentHandoffStatus.mismatched,
        decision: DeploymentHandoffDecision.mismatched,
        reason: 'Release identity mismatch. Eligible release: ${eligibilityRecord.baselineReleaseId}, Handoff release: $releaseId.',
      );
    }

    // Environment Identity Checks
    if (eligibilityRecord.environment != environment) {
      return _recordDecision(
        releaseId: releaseId,
        changeId: changeId,
        environment: environment,
        status: DeploymentHandoffStatus.mismatched,
        decision: DeploymentHandoffDecision.mismatched,
        reason: 'Environment mismatch. Eligible for ${eligibilityRecord.environment}, but attempted handoff to $environment.',
      );
    }

    // Artifact Identity Checks
    if (expectedArtifactReference != null) {
      if (artifactReference == null) {
        return _recordDecision(
          releaseId: releaseId,
          changeId: changeId,
          environment: environment,
          status: DeploymentHandoffStatus.incomplete,
          decision: DeploymentHandoffDecision.blocked,
          reason: 'Expected artifact reference is missing.',
        );
      }
      if (artifactReference != expectedArtifactReference) {
        return _recordDecision(
          releaseId: releaseId,
          changeId: changeId,
          environment: environment,
          status: DeploymentHandoffStatus.mismatched,
          decision: DeploymentHandoffDecision.mismatched,
          reason: 'Artifact mismatch. Expected: $expectedArtifactReference, Actual: $artifactReference.',
        );
      }
    }

    // Migration Identity Checks
    if (expectedMigrationReference != null) {
      if (migrationReference == null) {
        return _recordDecision(
          releaseId: releaseId,
          changeId: changeId,
          environment: environment,
          status: DeploymentHandoffStatus.incomplete,
          decision: DeploymentHandoffDecision.blocked,
          reason: 'Expected database migration reference is missing.',
        );
      }
      if (migrationReference != expectedMigrationReference) {
         return _recordDecision(
          releaseId: releaseId,
          changeId: changeId,
          environment: environment,
          status: DeploymentHandoffStatus.mismatched,
          decision: DeploymentHandoffDecision.mismatched,
          reason: 'Migration mismatch. Expected: $expectedMigrationReference, Actual: $migrationReference.',
        );
      }
    }

    // Configuration Check
    if (missingRequiredConfiguration) {
       return _recordDecision(
        releaseId: releaseId,
        changeId: changeId,
        environment: environment,
        status: DeploymentHandoffStatus.incomplete,
        decision: DeploymentHandoffDecision.incomplete,
        reason: 'Missing required configuration for environment $environment.',
      );
    }

    // All validation passed
    return _recordDecision(
      releaseId: releaseId,
      changeId: changeId,
      environment: environment,
      artifactReference: artifactReference,
      migrationReference: migrationReference,
      status: DeploymentHandoffStatus.ready,
      decision: DeploymentHandoffDecision.proceed,
      reason: 'Deployment handoff integrity verified. Safe to proceed to Deployment System.',
    );
  }

  DeploymentHandoff _recordDecision({
    required String releaseId,
    required String changeId,
    required String environment,
    String? artifactReference,
    String? migrationReference,
    required DeploymentHandoffStatus status,
    required DeploymentHandoffDecision decision,
    String? reason,
  }) {
    final handoff = DeploymentHandoff(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      releaseId: releaseId,
      changeId: changeId,
      environment: environment,
      artifactReference: artifactReference,
      migrationReference: migrationReference,
      status: status,
      decision: decision,
      decisionReason: reason,
      createdAt: DateTime.now(),
      validatedAt: DateTime.now(),
    );
    _handoffs[changeId] = handoff;
    return handoff;
  }
}

final deploymentHandoffService = DeploymentHandoffService();
