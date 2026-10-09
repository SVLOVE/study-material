import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/validation_orchestration/application/services/validation_orchestration_service.dart';
import 'package:govprep/features/validation_orchestration/domain/models/validation_orchestration_state.dart';

void main() {
  group('Validation Plan Orchestration & Scope (Phase 95)', () {
    setUpAll(() {
      validationOrchestrationService.initialize();
    });

    tearDownAll(() {
      validationOrchestrationService.dispose();
    });

    test('Creates a ready validation plan from required validations', () async {
      final plan = await validationOrchestrationService.orchestratePlan(
        changeId: 'change_v1',
        impactAssessmentId: 'impact_v1',
        isImpactBlocked: false,
        requiredValidations: ['Security Validation', 'Learning Pipeline Validation'],
      );

      expect(plan.status, ValidationPlanStatus.ready);
      expect(plan.items.length, 2);
      expect(plan.items.any((i) => i.category == 'Security'), isTrue);
      expect(plan.items.any((i) => i.category == 'Learning State'), isTrue);
    });

    test('Evaluates plan progress correctly to complete', () async {
      final plan = await validationOrchestrationService.orchestratePlan(
        changeId: 'change_v2',
        impactAssessmentId: 'impact_v2',
        isImpactBlocked: false,
        requiredValidations: ['UI Tests'],
      );

      final uiItemId = plan.items.firstWhere((i) => i.category == 'UI').id;

      final updatedPlan = validationOrchestrationService.evaluatePlanProgress('change_v2', {
        uiItemId: ValidationItemStatus.passed,
      });

      expect(updatedPlan.status, ValidationPlanStatus.complete);
    });

    test('Marks plan as failed if a required validation fails', () async {
      final plan = await validationOrchestrationService.orchestratePlan(
        changeId: 'change_v3',
        impactAssessmentId: 'impact_v3',
        isImpactBlocked: false,
        requiredValidations: ['Database/Schema Validation'],
      );

      final dbItemId = plan.items.firstWhere((i) => i.category == 'Database').id;

      final updatedPlan = validationOrchestrationService.evaluatePlanProgress('change_v3', {
        dbItemId: ValidationItemStatus.failed,
      });

      expect(updatedPlan.status, ValidationPlanStatus.failed);
    });

    test('Blocks plan generation if Phase 94 impact is blocked', () async {
      final plan = await validationOrchestrationService.orchestratePlan(
        changeId: 'change_v4',
        impactAssessmentId: 'impact_v4',
        isImpactBlocked: true, // Baseline or Impact failed
        requiredValidations: ['Security Validation'],
      );

      expect(plan.status, ValidationPlanStatus.blocked);
      expect(plan.blockingReason, contains('Impact Assessment'));
    });
  });
}
