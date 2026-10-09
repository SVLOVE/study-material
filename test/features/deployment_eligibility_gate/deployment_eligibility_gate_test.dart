import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/deployment_eligibility_gate/application/services/deployment_eligibility_gate_service.dart';
import 'package:govprep/features/deployment_eligibility_gate/domain/models/deployment_eligibility_gate_state.dart';
import 'package:govprep/features/validation_gate/domain/models/validation_gate_state.dart';
import 'package:govprep/features/compatibility_gate/domain/models/compatibility_gate_state.dart';
import 'package:govprep/features/production_readiness_gate/domain/models/release_readiness_state.dart';

void main() {
  group('Production Readiness Gate Decision (Phase 99)', () {
    setUpAll(() {
      deploymentEligibilityGateService.initialize();
    });

    tearDownAll(() {
      deploymentEligibilityGateService.dispose();
    });

    final eligibleValidationGate = ValidationGateDecisionRecord(
      id: 'vg_1',
      baselineReleaseId: 'b_1',
      changeId: 'change_1',
      validationPlanId: 'vp_1',
      decision: ValidationGateDecision.eligible,
      evaluatedAt: DateTime.now(),
    );

    final proceedCompatibilityGate = CompatibilityGateDecisionRecord(
      id: 'cg_1',
      baselineReleaseId: 'b_1',
      changeId: 'change_1',
      validationGateId: 'vg_1',
      decision: CompatibilityGateDecision.proceed,
      evaluatedAt: DateTime.now(),
    );

    test('Evaluates DEPLOYMENT_ELIGIBLE when all upstream gates and readiness pass', () async {
      final readiness = ReleaseReadinessState(
        version: 'v1.0.0',
        status: ReleaseStatus.ready,
      );

      final decision = await deploymentEligibilityGateService.evaluateDeploymentEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        environment: 'production',
        validationGateRecord: eligibleValidationGate,
        compatibilityGateRecord: proceedCompatibilityGate,
        readinessAssessment: readiness,
      );

      expect(decision.decision, DeploymentEligibilityGateDecision.deploymentEligible);
    });

    test('Evaluates BLOCKED when Validation Gate (Phase 97) is blocked', () async {
      final blockedValidationGate = ValidationGateDecisionRecord(
        id: 'vg_2',
        baselineReleaseId: 'b_1',
        changeId: 'change_2',
        validationPlanId: 'vp_2',
        decision: ValidationGateDecision.blocked,
        evaluatedAt: DateTime.now(),
      );

      final readiness = ReleaseReadinessState(
        version: 'v1.0.0',
        status: ReleaseStatus.ready,
      );

      final decision = await deploymentEligibilityGateService.evaluateDeploymentEligibility(
        changeId: 'change_2',
        baselineReleaseId: 'b_1',
        environment: 'production',
        validationGateRecord: blockedValidationGate,
        compatibilityGateRecord: proceedCompatibilityGate,
        readinessAssessment: readiness,
      );

      expect(decision.decision, DeploymentEligibilityGateDecision.blocked);
      expect(decision.decisionReason, contains('Validation Gate'));
    });

    test('Evaluates HOLD when Compatibility Gate (Phase 98) is conditional', () async {
      final conditionalCompatibilityGate = CompatibilityGateDecisionRecord(
        id: 'cg_2',
        baselineReleaseId: 'b_1',
        changeId: 'change_3',
        validationGateId: 'vg_1',
        decision: CompatibilityGateDecision.conditional, // Not proceed
        evaluatedAt: DateTime.now(),
      );

      final readiness = ReleaseReadinessState(
        version: 'v1.0.0',
        status: ReleaseStatus.ready,
      );

      final decision = await deploymentEligibilityGateService.evaluateDeploymentEligibility(
        changeId: 'change_3',
        baselineReleaseId: 'b_1',
        environment: 'production',
        validationGateRecord: eligibleValidationGate,
        compatibilityGateRecord: conditionalCompatibilityGate,
        readinessAssessment: readiness,
      );

      expect(decision.decision, DeploymentEligibilityGateDecision.hold);
      expect(decision.decisionReason, contains('Compatibility Gate'));
    });

    test('Evaluates BLOCKED when Phase 86 readiness is failed', () async {
      final readiness = ReleaseReadinessState(
        version: 'v1.0.0',
        status: ReleaseStatus.failed, // Failed
      );

      final decision = await deploymentEligibilityGateService.evaluateDeploymentEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        environment: 'production',
        validationGateRecord: eligibleValidationGate,
        compatibilityGateRecord: proceedCompatibilityGate,
        readinessAssessment: readiness,
      );

      expect(decision.decision, DeploymentEligibilityGateDecision.blocked);
    });

    test('Evaluates BLOCKED when Phase 86 contains blocking checks', () async {
      final readiness = ReleaseReadinessState(
        version: 'v1.0.0',
        status: ReleaseStatus.partiallyReady, 
        blockingChecks: ['Database Migration Failed'], // Explicit blocker
      );

      final decision = await deploymentEligibilityGateService.evaluateDeploymentEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        environment: 'production',
        validationGateRecord: eligibleValidationGate,
        compatibilityGateRecord: proceedCompatibilityGate,
        readinessAssessment: readiness,
      );

      expect(decision.decision, DeploymentEligibilityGateDecision.blocked);
      expect(decision.blockingCheckIds, contains('Database Migration Failed'));
    });

    test('Evaluates HOLD when Phase 86 is still validating', () async {
      final readiness = ReleaseReadinessState(
        version: 'v1.0.0',
        status: ReleaseStatus.validating, // Incomplete
      );

      final decision = await deploymentEligibilityGateService.evaluateDeploymentEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        environment: 'production',
        validationGateRecord: eligibleValidationGate,
        compatibilityGateRecord: proceedCompatibilityGate,
        readinessAssessment: readiness,
      );

      expect(decision.decision, DeploymentEligibilityGateDecision.hold);
    });
  });
}
