import 'dart:async';

import '../../domain/models/validation_evidence_state.dart';

class ValidationEvidenceService {
  final Map<String, ValidationEvidence> _evidenceStore = {};

  void initialize() {}

  void dispose() {}

  ValidationEvidence? getEvidence(String evidenceId) => _evidenceStore[evidenceId];
  List<ValidationEvidence> getEvidenceForPlan(String validationPlanId) {
    return _evidenceStore.values.where((e) => e.validationPlanId == validationPlanId).toList();
  }

  /// Phase 96: Validates the integrity of incoming test/validation evidence
  Future<ValidationEvidence> processEvidence({
    required String evidenceId,
    required String validationPlanId,
    required String validationItemId,
    required String changeId,
    required String reportedChangeVersion,
    required String currentChangeVersion,
    required String reportedBaselineReleaseId,
    required String currentBaselineReleaseId,
    required String reportedEnvironment,
    required String expectedEnvironment,
    required String evidenceType,
    required String? resultReference,
  }) async {
    
    // Check duplication
    final existingEvidence = _evidenceStore.values.where((e) => 
      e.validationPlanId == validationPlanId &&
      e.validationItemId == validationItemId &&
      e.changeVersion == reportedChangeVersion &&
      e.resultReference == resultReference
    ).toList();

    if (existingEvidence.isNotEmpty) {
      return existingEvidence.first.copyWith(
        status: ValidationEvidenceStatus.duplicate,
        failureReason: 'Duplicate evidence submitted.',
      );
    }

    ValidationEvidenceStatus computedStatus = ValidationEvidenceStatus.valid;
    String? reason;

    if (reportedChangeVersion != currentChangeVersion) {
      computedStatus = ValidationEvidenceStatus.stale;
      reason = 'Evidence change version ($reportedChangeVersion) does not match current change version ($currentChangeVersion).';
    } else if (reportedBaselineReleaseId != currentBaselineReleaseId) {
      computedStatus = ValidationEvidenceStatus.invalid;
      reason = 'Evidence baseline ($reportedBaselineReleaseId) does not match required baseline ($currentBaselineReleaseId).';
    } else if (reportedEnvironment != expectedEnvironment) {
      computedStatus = ValidationEvidenceStatus.invalid;
      reason = 'Evidence environment ($reportedEnvironment) does not match expected environment ($expectedEnvironment).';
    } else if (resultReference == null || resultReference.isEmpty) {
      computedStatus = ValidationEvidenceStatus.insufficientEvidence;
      reason = 'Missing trustworthy result reference.';
    }

    // Handle supersession logic for older valid evidence on the same item
    if (computedStatus == ValidationEvidenceStatus.valid) {
      final priorEvidence = _evidenceStore.values.where((e) => 
        e.validationPlanId == validationPlanId &&
        e.validationItemId == validationItemId &&
        e.status == ValidationEvidenceStatus.valid
      ).toList();

      for (var prior in priorEvidence) {
        _evidenceStore[prior.id] = prior.copyWith(
          status: ValidationEvidenceStatus.superseded,
          failureReason: 'Superseded by newer valid evidence: $evidenceId'
        );
      }
    }

    final newEvidence = ValidationEvidence(
      id: evidenceId,
      validationPlanId: validationPlanId,
      validationItemId: validationItemId,
      changeId: changeId,
      changeVersion: reportedChangeVersion,
      baselineReleaseId: reportedBaselineReleaseId,
      environment: reportedEnvironment,
      evidenceType: evidenceType,
      status: computedStatus,
      resultReference: resultReference,
      failureReason: reason,
      recordedAt: DateTime.now(),
    );

    _evidenceStore[evidenceId] = newEvidence;
    return newEvidence;
  }
}

final validationEvidenceService = ValidationEvidenceService();
