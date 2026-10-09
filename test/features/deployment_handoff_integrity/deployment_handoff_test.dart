import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/deployment_handoff_integrity/application/services/deployment_handoff_service.dart';
import 'package:govprep/features/deployment_handoff_integrity/domain/models/deployment_handoff_state.dart';
import 'package:govprep/features/deployment_eligibility_gate/domain/models/deployment_eligibility_gate_state.dart';

void main() {
  group('Deployment Handoff Integrity (Phase 100)', () {
    setUpAll(() {
      deploymentHandoffService.initialize();
    });

    tearDownAll(() {
      deploymentHandoffService.dispose();
    });

    final eligibleDeploymentGate = DeploymentEligibilityGateDecisionRecord(
      id: 'deg_1',
      baselineReleaseId: 'b_1',
      changeId: 'change_1',
      validationGateId: 'vg_1',
      compatibilityGateId: 'cg_1',
      readinessAssessmentId: 'ra_1',
      environment: 'production',
      decision: DeploymentEligibilityGateDecision.deploymentEligible,
      evaluatedAt: DateTime.now(),
    );

    test('Evaluates PROCEED when all handoff constraints match the eligible release', () async {
      final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_1',
        changeId: 'change_1',
        environment: 'production',
        eligibilityRecord: eligibleDeploymentGate,
      );

      expect(handoff.decision, DeploymentHandoffDecision.proceed);
      expect(handoff.status, DeploymentHandoffStatus.ready);
    });

    test('Evaluates BLOCKED when Deployment Eligibility Gate (Phase 99) is not eligible', () async {
      final blockedDeploymentGate = DeploymentEligibilityGateDecisionRecord(
        id: 'deg_2',
        baselineReleaseId: 'b_1',
        changeId: 'change_2',
        validationGateId: 'vg_1',
        compatibilityGateId: 'cg_1',
        readinessAssessmentId: 'ra_1',
        environment: 'production',
        decision: DeploymentEligibilityGateDecision.blocked,
        evaluatedAt: DateTime.now(),
      );

      final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_1',
        changeId: 'change_2',
        environment: 'production',
        eligibilityRecord: blockedDeploymentGate, // Blocked Phase 99
      );

      expect(handoff.decision, DeploymentHandoffDecision.blocked);
      expect(handoff.decisionReason, contains('Deployment Eligibility Gate'));
    });

    test('Evaluates MISMATCHED when attempting to handoff a different release', () async {
      final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_2', // Mismatched release ID
        changeId: 'change_1',
        environment: 'production',
        eligibilityRecord: eligibleDeploymentGate,
      );

      expect(handoff.decision, DeploymentHandoffDecision.mismatched);
      expect(handoff.status, DeploymentHandoffStatus.mismatched);
      expect(handoff.decisionReason, contains('Release identity mismatch'));
    });

    test('Evaluates MISMATCHED when attempting to handoff to a different environment', () async {
      final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_1',
        changeId: 'change_1',
        environment: 'staging', // Eligible for production, attempting staging
        eligibilityRecord: eligibleDeploymentGate,
      );

      expect(handoff.decision, DeploymentHandoffDecision.mismatched);
      expect(handoff.status, DeploymentHandoffStatus.mismatched);
      expect(handoff.decisionReason, contains('Environment mismatch'));
    });

    test('Evaluates MISMATCHED when actual artifact reference deviates from expected', () async {
       final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_1',
        changeId: 'change_1',
        environment: 'production',
        eligibilityRecord: eligibleDeploymentGate,
        expectedArtifactReference: 'commit-abc',
        artifactReference: 'commit-def', // Mismatch
      );

      expect(handoff.decision, DeploymentHandoffDecision.mismatched);
      expect(handoff.status, DeploymentHandoffStatus.mismatched);
      expect(handoff.decisionReason, contains('Artifact mismatch'));
    });

    test('Evaluates BLOCKED when an expected artifact is entirely missing', () async {
       final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_1',
        changeId: 'change_1',
        environment: 'production',
        eligibilityRecord: eligibleDeploymentGate,
        expectedArtifactReference: 'commit-abc',
        artifactReference: null, // Missing
      );

      expect(handoff.decision, DeploymentHandoffDecision.blocked);
      expect(handoff.status, DeploymentHandoffStatus.incomplete);
    });
    
    test('Evaluates INCOMPLETE when missing required deployment configuration', () async {
       final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_1',
        changeId: 'change_1',
        environment: 'production',
        eligibilityRecord: eligibleDeploymentGate,
        missingRequiredConfiguration: true, // Missing config
      );

      expect(handoff.decision, DeploymentHandoffDecision.incomplete);
      expect(handoff.status, DeploymentHandoffStatus.incomplete);
    });
    
    test('Evaluates PROCEED when artifact and migration references perfectly match', () async {
      final handoff = await deploymentHandoffService.validateDeploymentHandoff(
        releaseId: 'b_1',
        changeId: 'change_1',
        environment: 'production',
        eligibilityRecord: eligibleDeploymentGate,
        expectedArtifactReference: 'commit-abc',
        artifactReference: 'commit-abc', 
        expectedMigrationReference: 'mig-123',
        migrationReference: 'mig-123',
      );

      expect(handoff.decision, DeploymentHandoffDecision.proceed);
      expect(handoff.status, DeploymentHandoffStatus.ready);
    });
  });
}
