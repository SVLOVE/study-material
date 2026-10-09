import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/compatibility_gate/application/services/compatibility_gate_service.dart';
import 'package:govprep/features/compatibility_gate/domain/models/compatibility_gate_state.dart';
import 'package:govprep/features/validation_gate/domain/models/validation_gate_state.dart';
import 'package:govprep/features/release_compatibility/domain/models/release_compatibility_state.dart';

void main() {
  group('Compatibility Gate Evaluation (Phase 98)', () {
    setUpAll(() {
      compatibilityGateService.initialize();
    });

    tearDownAll(() {
      compatibilityGateService.dispose();
    });

    final eligibleValidationGate = ValidationGateDecisionRecord(
      id: 'vg_1',
      baselineReleaseId: 'b_1',
      changeId: 'change_1',
      validationPlanId: 'vp_1',
      decision: ValidationGateDecision.eligible,
      evaluatedAt: DateTime.now(),
    );

    final blockedValidationGate = ValidationGateDecisionRecord(
      id: 'vg_2',
      baselineReleaseId: 'b_1',
      changeId: 'change_2',
      validationPlanId: 'vp_2',
      decision: ValidationGateDecision.blocked,
      evaluatedAt: DateTime.now(),
    );

    test('Evaluates PROCEED when Phase 88 is compatible', () async {
      final compResult = ReleaseCompatibilityResult(
        previousReleaseId: 'b_1',
        currentReleaseId: 'change_1',
        status: ReleaseCompatibilityStatus.compatible,
      );

      final decision = await compatibilityGateService.evaluateCompatibilityGate(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        validationGateRecord: eligibleValidationGate,
        compatibilityResult: compResult,
        conditionalSatisfactions: {},
      );

      expect(decision.decision, CompatibilityGateDecision.proceed);
    });

    test('Evaluates BLOCKED when Validation Gate (Phase 97) is blocked', () async {
       final compResult = ReleaseCompatibilityResult(
        previousReleaseId: 'b_1',
        currentReleaseId: 'change_2',
        status: ReleaseCompatibilityStatus.compatible,
      );

      final decision = await compatibilityGateService.evaluateCompatibilityGate(
        changeId: 'change_2',
        baselineReleaseId: 'b_1',
        validationGateRecord: blockedValidationGate, // Blocked
        compatibilityResult: compResult,
        conditionalSatisfactions: {},
      );

      expect(decision.decision, CompatibilityGateDecision.blocked);
      expect(decision.decisionReason, contains('Validation Gate'));
    });

    test('Evaluates CONDITIONAL when conditionally compatible but unresolved', () async {
      final compResult = ReleaseCompatibilityResult(
        previousReleaseId: 'b_1',
        currentReleaseId: 'change_1',
        status: ReleaseCompatibilityStatus.conditionallyCompatible,
        conditionalRequirements: ['Feature Flag Enabled'],
      );

      final decision = await compatibilityGateService.evaluateCompatibilityGate(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        validationGateRecord: eligibleValidationGate,
        compatibilityResult: compResult,
        conditionalSatisfactions: {}, // Missing condition
      );

      expect(decision.decision, CompatibilityGateDecision.conditional);
      expect(decision.pendingConditions, contains('Feature Flag Enabled'));
    });

    test('Evaluates PROCEED when all conditions are satisfied', () async {
      final compResult = ReleaseCompatibilityResult(
        previousReleaseId: 'b_1',
        currentReleaseId: 'change_1',
        status: ReleaseCompatibilityStatus.conditionallyCompatible,
        conditionalRequirements: ['Migration M1 Required'],
      );

      final decision = await compatibilityGateService.evaluateCompatibilityGate(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        validationGateRecord: eligibleValidationGate,
        compatibilityResult: compResult,
        conditionalSatisfactions: {
          'Migration M1 Required': true // Satisfied
        }, 
      );

      expect(decision.decision, CompatibilityGateDecision.proceed);
      expect(decision.pendingConditions, isEmpty);
      expect(decision.blockingConditions, isEmpty);
    });

    test('Evaluates BLOCKED when a condition explicitly fails', () async {
       final compResult = ReleaseCompatibilityResult(
        previousReleaseId: 'b_1',
        currentReleaseId: 'change_1',
        status: ReleaseCompatibilityStatus.conditionallyCompatible,
        conditionalRequirements: ['Old API Accessible'],
      );

      final decision = await compatibilityGateService.evaluateCompatibilityGate(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        validationGateRecord: eligibleValidationGate,
        compatibilityResult: compResult,
        conditionalSatisfactions: {
          'Old API Accessible': false // Failed
        }, 
      );

      expect(decision.decision, CompatibilityGateDecision.blocked);
      expect(decision.blockingConditions, contains('Old API Accessible'));
    });

    test('Evaluates BLOCKED when Phase 88 is incompatible', () async {
       final compResult = ReleaseCompatibilityResult(
        previousReleaseId: 'b_1',
        currentReleaseId: 'change_1',
        status: ReleaseCompatibilityStatus.incompatible,
        blockingIssues: ['Breaking Schema Change'],
      );

      final decision = await compatibilityGateService.evaluateCompatibilityGate(
        changeId: 'change_1',
        baselineReleaseId: 'b_1',
        validationGateRecord: eligibleValidationGate,
        compatibilityResult: compResult,
        conditionalSatisfactions: {}, 
      );

      expect(decision.decision, CompatibilityGateDecision.blocked);
      expect(decision.blockingConditions, contains('Breaking Schema Change'));
    });
  });
}
