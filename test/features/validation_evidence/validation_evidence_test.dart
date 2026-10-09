import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/validation_evidence/application/services/validation_evidence_service.dart';
import 'package:govprep/features/validation_evidence/domain/models/validation_evidence_state.dart';

void main() {
  group('Validation Evidence Integrity & Traceability (Phase 96)', () {
    setUpAll(() {
      validationEvidenceService.initialize();
    });

    tearDownAll(() {
      validationEvidenceService.dispose();
    });

    test('Validates and accepts trustworthy evidence', () async {
      final evidence = await validationEvidenceService.processEvidence(
        evidenceId: 'e_valid',
        validationPlanId: 'plan_1',
        validationItemId: 'item_1',
        changeId: 'change_1',
        reportedChangeVersion: 'v2',
        currentChangeVersion: 'v2',
        reportedBaselineReleaseId: 'base_1',
        currentBaselineReleaseId: 'base_1',
        reportedEnvironment: 'staging',
        expectedEnvironment: 'staging',
        evidenceType: 'Static Analysis',
        resultReference: 'CI_RUN_8992',
      );

      expect(evidence.status, ValidationEvidenceStatus.valid);
    });

    test('Marks evidence STALE if change version mismatches', () async {
      final evidence = await validationEvidenceService.processEvidence(
        evidenceId: 'e_stale',
        validationPlanId: 'plan_2',
        validationItemId: 'item_2',
        changeId: 'change_2',
        reportedChangeVersion: 'v1',
        currentChangeVersion: 'v2', // Mismatch
        reportedBaselineReleaseId: 'base_1',
        currentBaselineReleaseId: 'base_1',
        reportedEnvironment: 'staging',
        expectedEnvironment: 'staging',
        evidenceType: 'Unit Test',
        resultReference: 'CI_RUN_8993',
      );

      expect(evidence.status, ValidationEvidenceStatus.stale);
      expect(evidence.failureReason, contains('change version'));
    });

    test('Marks evidence INVALID if baseline or environment mismatches', () async {
      final evidence = await validationEvidenceService.processEvidence(
        evidenceId: 'e_invalid_env',
        validationPlanId: 'plan_3',
        validationItemId: 'item_3',
        changeId: 'change_3',
        reportedChangeVersion: 'v1',
        currentChangeVersion: 'v1',
        reportedBaselineReleaseId: 'base_1',
        currentBaselineReleaseId: 'base_1',
        reportedEnvironment: 'development',
        expectedEnvironment: 'production', // Mismatch
        evidenceType: 'RLS Check',
        resultReference: 'SEC_RUN_404',
      );

      expect(evidence.status, ValidationEvidenceStatus.invalid);
      expect(evidence.failureReason, contains('environment'));
    });

    test('Identifies duplicate evidence safely', () async {
      await validationEvidenceService.processEvidence(
        evidenceId: 'e_dup_orig',
        validationPlanId: 'plan_4',
        validationItemId: 'item_4',
        changeId: 'change_4',
        reportedChangeVersion: 'v1',
        currentChangeVersion: 'v1',
        reportedBaselineReleaseId: 'base_1',
        currentBaselineReleaseId: 'base_1',
        reportedEnvironment: 'staging',
        expectedEnvironment: 'staging',
        evidenceType: 'API Check',
        resultReference: 'API_RUN_11',
      );

      final duplicate = await validationEvidenceService.processEvidence(
        evidenceId: 'e_dup_new',
        validationPlanId: 'plan_4',
        validationItemId: 'item_4',
        changeId: 'change_4',
        reportedChangeVersion: 'v1',
        currentChangeVersion: 'v1',
        reportedBaselineReleaseId: 'base_1',
        currentBaselineReleaseId: 'base_1',
        reportedEnvironment: 'staging',
        expectedEnvironment: 'staging',
        evidenceType: 'API Check',
        resultReference: 'API_RUN_11', // Same result reference
      );

      expect(duplicate.status, ValidationEvidenceStatus.duplicate);
    });

    test('Supersedes older valid evidence with newer valid evidence', () async {
      final firstEvidence = await validationEvidenceService.processEvidence(
        evidenceId: 'e_super_1',
        validationPlanId: 'plan_5',
        validationItemId: 'item_5',
        changeId: 'change_5',
        reportedChangeVersion: 'v1',
        currentChangeVersion: 'v1',
        reportedBaselineReleaseId: 'base_1',
        currentBaselineReleaseId: 'base_1',
        reportedEnvironment: 'staging',
        expectedEnvironment: 'staging',
        evidenceType: 'Build Check',
        resultReference: 'BUILD_1',
      );
      expect(firstEvidence.status, ValidationEvidenceStatus.valid);

      final secondEvidence = await validationEvidenceService.processEvidence(
        evidenceId: 'e_super_2',
        validationPlanId: 'plan_5',
        validationItemId: 'item_5',
        changeId: 'change_5',
        reportedChangeVersion: 'v1',
        currentChangeVersion: 'v1',
        reportedBaselineReleaseId: 'base_1',
        currentBaselineReleaseId: 'base_1',
        reportedEnvironment: 'staging',
        expectedEnvironment: 'staging',
        evidenceType: 'Build Check',
        resultReference: 'BUILD_2', // New result
      );
      expect(secondEvidence.status, ValidationEvidenceStatus.valid);

      final updatedFirstEvidence = validationEvidenceService.getEvidence('e_super_1');
      expect(updatedFirstEvidence?.status, ValidationEvidenceStatus.superseded);
    });
  });
}
