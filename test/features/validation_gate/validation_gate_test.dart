import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/validation_gate/application/services/validation_gate_service.dart';
import 'package:govprep/features/validation_gate/domain/models/validation_gate_state.dart';
import 'package:govprep/features/validation_orchestration/domain/models/validation_orchestration_state.dart';
import 'package:govprep/features/validation_evidence/domain/models/validation_evidence_state.dart';

void main() {
  group('Validation Gate Decision & Eligibility (Phase 97)', () {
    setUpAll(() {
      validationGateService.initialize();
    });

    tearDownAll(() {
      validationGateService.dispose();
    });

    final dummyPlan = const ReleaseValidationPlan(
      id: 'plan_1',
      changeId: 'change_1',
      impactAssessmentId: 'impact_1',
      status: ValidationPlanStatus.ready,
      items: [
        ValidationItem(id: 'item_1', category: 'Security', name: 'RLS', required: true),
        ValidationItem(id: 'item_2', category: 'Database', name: 'Migration', required: true),
      ],
    );

    test('Evaluates ELIGIBLE when all required items have valid evidence', () async {
      final evidence = [
        ValidationEvidence(
          id: 'e1', validationPlanId: 'plan_1', validationItemId: 'item_1',
          changeId: 'change_1', changeVersion: 'v1', baselineReleaseId: 'b1',
          environment: 'staging', evidenceType: 'Security', status: ValidationEvidenceStatus.valid,
        ),
        ValidationEvidence(
          id: 'e2', validationPlanId: 'plan_1', validationItemId: 'item_2',
          changeId: 'change_1', changeVersion: 'v1', baselineReleaseId: 'b1',
          environment: 'staging', evidenceType: 'Database', status: ValidationEvidenceStatus.valid,
        ),
      ];

      final decision = await validationGateService.evaluateEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b1',
        impactAssessmentStatus: 'ANALYZED',
        validationPlan: dummyPlan,
        validationEvidence: evidence,
      );

      expect(decision.decision, ValidationGateDecision.eligible);
    });

    test('Evaluates HOLD when required items are pending (no evidence)', () async {
      final evidence = [
        ValidationEvidence(
          id: 'e1', validationPlanId: 'plan_1', validationItemId: 'item_1',
          changeId: 'change_1', changeVersion: 'v1', baselineReleaseId: 'b1',
          environment: 'staging', evidenceType: 'Security', status: ValidationEvidenceStatus.valid,
        ),
        // item_2 is missing evidence
      ];

      final decision = await validationGateService.evaluateEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b1',
        impactAssessmentStatus: 'ANALYZED',
        validationPlan: dummyPlan,
        validationEvidence: evidence,
      );

      expect(decision.decision, ValidationGateDecision.hold);
      expect(decision.pendingValidationItemIds, contains('item_2'));
    });

    test('Evaluates BLOCKED when evidence is invalid', () async {
      final evidence = [
        ValidationEvidence(
          id: 'e1', validationPlanId: 'plan_1', validationItemId: 'item_1',
          changeId: 'change_1', changeVersion: 'v1', baselineReleaseId: 'b1',
          environment: 'staging', evidenceType: 'Security', status: ValidationEvidenceStatus.valid,
        ),
        ValidationEvidence(
          id: 'e2', validationPlanId: 'plan_1', validationItemId: 'item_2',
          changeId: 'change_1', changeVersion: 'v1', baselineReleaseId: 'b1',
          environment: 'staging', evidenceType: 'Database', status: ValidationEvidenceStatus.invalid,
        ),
      ];

      final decision = await validationGateService.evaluateEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b1',
        impactAssessmentStatus: 'ANALYZED',
        validationPlan: dummyPlan,
        validationEvidence: evidence,
      );

      expect(decision.decision, ValidationGateDecision.blocked);
      expect(decision.blockingValidationItemIds, contains('item_2'));
    });

    test('Blocks early if Phase 94 impact is invalid or blocked', () async {
      final decision = await validationGateService.evaluateEligibility(
        changeId: 'change_1',
        baselineReleaseId: 'b1',
        impactAssessmentStatus: 'BLOCKED',
        validationPlan: dummyPlan,
        validationEvidence: [], // Doesn't matter, blocked earlier
      );

      expect(decision.decision, ValidationGateDecision.blocked);
      expect(decision.decisionReason, contains('Phase 94'));
    });
  });
}
