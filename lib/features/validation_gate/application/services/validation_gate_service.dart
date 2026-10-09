import 'dart:async';

import '../../domain/models/validation_gate_state.dart';
import '../../../validation_evidence/domain/models/validation_evidence_state.dart';
import '../../../validation_orchestration/domain/models/validation_orchestration_state.dart';

class ValidationGateService {
  final Map<String, ValidationGateDecisionRecord> _decisions = {};

  void initialize() {}

  void dispose() {}

  ValidationGateDecisionRecord? getDecision(String changeId) => _decisions[changeId];

  /// Phase 97: Evaluates whether a validation plan is sufficiently evidenced to authorize progression to Phase 88
  Future<ValidationGateDecisionRecord> evaluateEligibility({
    required String changeId,
    required String baselineReleaseId,
    required String impactAssessmentStatus,
    required ReleaseValidationPlan validationPlan,
    required List<ValidationEvidence> validationEvidence,
  }) async {
    
    // Dependencies Check (Phase 93, 94)
    if (impactAssessmentStatus == 'BLOCKED' || impactAssessmentStatus == 'INVALID') {
       return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        planId: validationPlan.id,
        decision: ValidationGateDecision.blocked,
        reason: 'Impact Assessment (Phase 94) or Baseline (Phase 93) is invalid.',
      );
    }

    if (validationPlan.status == ValidationPlanStatus.notRequired) {
      return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        planId: validationPlan.id,
        decision: ValidationGateDecision.notRequired,
        reason: 'No validation required for this change.',
      );
    }

    if (validationPlan.status == ValidationPlanStatus.blocked || validationPlan.status == ValidationPlanStatus.failed) {
      return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        planId: validationPlan.id,
        decision: ValidationGateDecision.blocked,
        reason: 'Validation Plan (Phase 95) is blocked or failed.',
      );
    }

    List<String> blockedItems = [];
    List<String> pendingItems = [];
    List<String> insufficientItems = [];
    bool hasStale = false;

    // Evaluate each required item against its trusted evidence
    for (final item in validationPlan.items) {
      if (!item.required) continue;

      // Find the authoritative evidence for this item (not superseded or duplicate)
      final authoritativeEvidence = validationEvidence.where((e) => 
        e.validationItemId == item.id && 
        e.status != ValidationEvidenceStatus.superseded &&
        e.status != ValidationEvidenceStatus.duplicate
      ).toList();

      if (authoritativeEvidence.isEmpty) {
        pendingItems.add(item.id);
        continue;
      }

      final evidence = authoritativeEvidence.first;

      if (evidence.status == ValidationEvidenceStatus.invalid) {
        blockedItems.add(item.id);
      } else if (evidence.status == ValidationEvidenceStatus.stale) {
        hasStale = true;
      } else if (evidence.status == ValidationEvidenceStatus.insufficientEvidence || evidence.status == ValidationEvidenceStatus.unknown) {
        insufficientItems.add(item.id);
      } else if (evidence.status != ValidationEvidenceStatus.valid) {
         pendingItems.add(item.id); // e.g. pending
      }
    }

    ValidationGateDecision computedDecision;
    String? reason;

    if (blockedItems.isNotEmpty) {
      computedDecision = ValidationGateDecision.blocked;
      reason = 'Required validations failed or provided invalid evidence.';
    } else if (hasStale) {
      computedDecision = ValidationGateDecision.stale;
      reason = 'Required validation evidence is stale and must be re-executed.';
    } else if (insufficientItems.isNotEmpty) {
      computedDecision = ValidationGateDecision.insufficientEvidence;
      reason = 'Required validations lack sufficient or trusted evidence.';
    } else if (pendingItems.isNotEmpty) {
      computedDecision = ValidationGateDecision.hold;
      reason = 'Required validations are still pending.';
    } else {
      computedDecision = ValidationGateDecision.eligible;
      reason = 'All required validations are supported by trusted evidence. Eligible for Compatibility Phase.';
    }

    return _recordDecision(
      changeId: changeId,
      baselineReleaseId: baselineReleaseId,
      planId: validationPlan.id,
      decision: computedDecision,
      reason: reason,
      blockedItems: blockedItems,
      insufficientItems: insufficientItems,
      pendingItems: pendingItems,
    );
  }

  ValidationGateDecisionRecord _recordDecision({
    required String changeId,
    required String baselineReleaseId,
    required String planId,
    required ValidationGateDecision decision,
    String? reason,
    List<String> blockedItems = const [],
    List<String> insufficientItems = const [],
    List<String> pendingItems = const [],
  }) {
    final record = ValidationGateDecisionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baselineReleaseId: baselineReleaseId,
      changeId: changeId,
      validationPlanId: planId,
      decision: decision,
      decisionReason: reason,
      blockingValidationItemIds: blockedItems,
      insufficientEvidenceItemIds: insufficientItems,
      pendingValidationItemIds: pendingItems,
      evaluatedAt: DateTime.now(),
    );
    _decisions[changeId] = record;
    return record;
  }
}

final validationGateService = ValidationGateService();
