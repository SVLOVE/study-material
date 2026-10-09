import 'dart:async';

import '../../domain/models/validation_orchestration_state.dart';

class ValidationOrchestrationService {
  final Map<String, ReleaseValidationPlan> _plans = {};

  void initialize() {}

  void dispose() {}

  ReleaseValidationPlan? getPlan(String changeId) => _plans[changeId];

  /// Phase 95: Converts Change Impact (Phase 94) into an executable validation plan
  Future<ReleaseValidationPlan> orchestratePlan({
    required String changeId,
    required String impactAssessmentId,
    required bool isImpactBlocked,
    required List<String> requiredValidations,
  }) async {
    
    if (isImpactBlocked) {
      final blockedPlan = ReleaseValidationPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        changeId: changeId,
        impactAssessmentId: impactAssessmentId,
        status: ValidationPlanStatus.blocked,
        blockingReason: 'Impact Assessment (Phase 94) is blocked. Cannot generate a plan.',
      );
      _plans[changeId] = blockedPlan;
      return blockedPlan;
    }

    if (requiredValidations.isEmpty) {
      final noPlan = ReleaseValidationPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        changeId: changeId,
        impactAssessmentId: impactAssessmentId,
        status: ValidationPlanStatus.notRequired,
      );
      _plans[changeId] = noPlan;
      return noPlan;
    }

    final List<ValidationItem> items = [];

    for (final validation in requiredValidations) {
      if (validation == 'Security Validation') {
        items.add(ValidationItem(id: 'v_sec', category: 'Security', name: 'RLS & Auth Checks'));
      } else if (validation == 'Database/Schema Validation') {
        items.add(ValidationItem(id: 'v_db', category: 'Database', name: 'Migration Integrity'));
      } else if (validation == 'Learning Pipeline Validation') {
        items.add(ValidationItem(id: 'v_learn', category: 'Learning State', name: 'Attempt & Performance Integration'));
      } else if (validation == 'UI Tests') {
        items.add(ValidationItem(id: 'v_ui', category: 'UI', name: 'Widget & Responsive Tests'));
      } else {
        items.add(ValidationItem(id: 'v_gen_${validation.hashCode}', category: 'General', name: validation));
      }
    }

    final plan = ReleaseValidationPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      changeId: changeId,
      impactAssessmentId: impactAssessmentId,
      status: ValidationPlanStatus.ready,
      items: items,
    );

    _plans[changeId] = plan;
    return plan;
  }

  /// Evaluates the plan status based on the execution of its items
  ReleaseValidationPlan evaluatePlanProgress(String changeId, Map<String, ValidationItemStatus> executionResults) {
    final currentPlan = _plans[changeId];
    if (currentPlan == null) throw Exception('Plan not found for changeId: $changeId');

    final updatedItems = currentPlan.items.map((item) {
      final newStatus = executionResults[item.id] ?? item.status;
      return item.copyWith(status: newStatus);
    }).toList();

    bool hasFailed = updatedItems.any((i) => i.required && i.status == ValidationItemStatus.failed);
    bool hasBlocked = updatedItems.any((i) => i.required && i.status == ValidationItemStatus.blocked);
    bool allPassed = updatedItems.every((i) => !i.required || i.status == ValidationItemStatus.passed);
    
    ValidationPlanStatus newPlanStatus;
    if (hasFailed) {
      newPlanStatus = ValidationPlanStatus.failed;
    } else if (hasBlocked) {
      newPlanStatus = ValidationPlanStatus.blocked;
    } else if (allPassed) {
      newPlanStatus = ValidationPlanStatus.complete;
    } else {
      newPlanStatus = ValidationPlanStatus.partiallyComplete;
    }

    final updatedPlan = currentPlan.copyWith(
      items: updatedItems,
      status: newPlanStatus,
    );
    
    _plans[changeId] = updatedPlan;
    return updatedPlan;
  }
}

final validationOrchestrationService = ValidationOrchestrationService();
