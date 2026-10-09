import 'dart:async';

import '../../domain/models/compatibility_gate_state.dart';
import '../../../validation_gate/domain/models/validation_gate_state.dart';
import '../../../release_compatibility/domain/models/release_compatibility_state.dart';

class CompatibilityGateService {
  final Map<String, CompatibilityGateDecisionRecord> _decisions = {};

  void initialize() {}

  void dispose() {}

  CompatibilityGateDecisionRecord? getDecision(String changeId) => _decisions[changeId];

  /// Phase 98: Evaluates whether the compatibility assessment is sufficient to authorize progression to Phase 86
  Future<CompatibilityGateDecisionRecord> evaluateCompatibilityGate({
    required String changeId,
    required String baselineReleaseId,
    required ValidationGateDecisionRecord validationGateRecord,
    required ReleaseCompatibilityResult compatibilityResult,
    required Map<String, bool> conditionalSatisfactions, // True if satisfied
  }) async {
    
    // Dependencies Check (Phase 97)
    if (validationGateRecord.decision != ValidationGateDecision.eligible) {
       return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        validationGateId: validationGateRecord.id,
        decision: ValidationGateDecision.blocked == validationGateRecord.decision ? CompatibilityGateDecision.blocked : CompatibilityGateDecision.hold,
        reason: 'Validation Gate (Phase 97) is not eligible (status: ${validationGateRecord.decision.name}).',
      );
    }

    if (compatibilityResult.status == ReleaseCompatibilityStatus.notApplicable) {
      return _recordDecision(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        validationGateId: validationGateRecord.id,
        decision: CompatibilityGateDecision.notRequired,
        reason: 'No compatibility evaluation required.',
      );
    }

    List<String> blockedConditions = [];
    List<String> pendingConditions = [];

    // Evaluate Phase 88 compatibility result
    CompatibilityGateDecision computedDecision;
    String? reason;

    if (compatibilityResult.status == ReleaseCompatibilityStatus.incompatible) {
      computedDecision = CompatibilityGateDecision.blocked;
      reason = 'Phase 88 marked release as incompatible.';
      blockedConditions.addAll(compatibilityResult.blockingIssues);
    } else if (compatibilityResult.status == ReleaseCompatibilityStatus.unknown) {
      computedDecision = CompatibilityGateDecision.hold;
      reason = 'Phase 88 returned an unknown compatibility result.';
    } else if (compatibilityResult.status == ReleaseCompatibilityStatus.conditionallyCompatible) {
      bool allSatisfied = true;
      for (final req in compatibilityResult.conditionalRequirements) {
        final satisfied = conditionalSatisfactions[req];
        if (satisfied == null) {
          pendingConditions.add(req);
          allSatisfied = false;
        } else if (satisfied == false) {
          blockedConditions.add(req);
          allSatisfied = false;
        }
      }

      if (blockedConditions.isNotEmpty) {
         computedDecision = CompatibilityGateDecision.blocked;
         reason = 'Unsatisfied mandatory compatibility conditions blocked progression.';
      } else if (pendingConditions.isNotEmpty) {
         computedDecision = CompatibilityGateDecision.conditional;
         reason = 'Holding for pending compatibility condition resolution.';
      } else if (allSatisfied) {
         computedDecision = CompatibilityGateDecision.proceed;
         reason = 'All required compatibility conditions are satisfied. Proceed to Phase 86.';
      } else {
         computedDecision = CompatibilityGateDecision.unknown;
      }
    } else if (compatibilityResult.status == ReleaseCompatibilityStatus.compatible) {
      computedDecision = CompatibilityGateDecision.proceed;
      reason = 'Release is compatible. Proceed to Phase 86.';
    } else {
      computedDecision = CompatibilityGateDecision.unknown;
      reason = 'Unexpected compatibility status.';
    }

    return _recordDecision(
      changeId: changeId,
      baselineReleaseId: baselineReleaseId,
      validationGateId: validationGateRecord.id,
      decision: computedDecision,
      reason: reason,
      blockedConditions: blockedConditions,
      pendingConditions: pendingConditions,
    );
  }

  CompatibilityGateDecisionRecord _recordDecision({
    required String changeId,
    required String baselineReleaseId,
    required String validationGateId,
    required CompatibilityGateDecision decision,
    String? reason,
    List<String> blockedConditions = const [],
    List<String> pendingConditions = const [],
  }) {
    final record = CompatibilityGateDecisionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baselineReleaseId: baselineReleaseId,
      changeId: changeId,
      validationGateId: validationGateId,
      decision: decision,
      decisionReason: reason,
      blockingConditions: blockedConditions,
      pendingConditions: pendingConditions,
      evaluatedAt: DateTime.now(),
    );
    _decisions[changeId] = record;
    return record;
  }
}

final compatibilityGateService = CompatibilityGateService();
