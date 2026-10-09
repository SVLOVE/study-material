import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/change_impact/application/services/change_impact_service.dart';
import 'package:govprep/features/change_impact/domain/models/change_impact_state.dart';

void main() {
  group('Change Impact Assessment & Release Scope Control (Phase 94)', () {
    setUpAll(() {
      changeImpactService.initialize();
    });

    tearDownAll(() {
      changeImpactService.dispose();
    });

    test('Identifies CRITICAL_SCOPE when RLS or Auth is changed', () async {
      final result = await changeImpactService.assessImpact(
        changeId: 'change_1',
        baselineReleaseId: 'baseline_1',
        isBaselineValid: true,
        changedComponents: ['RLS'],
      );

      expect(result.status, ChangeImpactStatus.analyzed);
      expect(result.scope, ReleaseScopeDecision.criticalScope);
      expect(result.requiredValidations, contains('Security Validation'));
    });

    test('Identifies BROAD_SCOPE when Database or Learning State is changed', () async {
      final result = await changeImpactService.assessImpact(
        changeId: 'change_2',
        baselineReleaseId: 'baseline_1',
        isBaselineValid: true,
        changedComponents: ['Question Retrieval'],
      );

      expect(result.scope, ReleaseScopeDecision.broadScope);
      expect(result.requiredValidations, contains('Learning Pipeline Validation'));
      expect(result.potentiallyAffectedAreas, contains('Practice'));
    });

    test('Identifies TARGETED_SCOPE when only UI is changed', () async {
      final result = await changeImpactService.assessImpact(
        changeId: 'change_3',
        baselineReleaseId: 'baseline_1',
        isBaselineValid: true,
        changedComponents: ['DashboardUIWidget'],
      );

      expect(result.scope, ReleaseScopeDecision.targetedScope);
      expect(result.requiredValidations, contains('UI Tests'));
    });

    test('Blocks assessment if baseline is invalid (Phase 93 failure)', () async {
      final result = await changeImpactService.assessImpact(
        changeId: 'change_4',
        baselineReleaseId: 'baseline_invalid',
        isBaselineValid: false,
        changedComponents: ['DashboardUIWidget'],
      );

      expect(result.status, ChangeImpactStatus.blocked);
      expect(result.scope, ReleaseScopeDecision.blocked);
      expect(result.blockingReason, contains('invalid'));
    });
  });
}
