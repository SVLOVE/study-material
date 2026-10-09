import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/rollout_finalization/application/services/rollout_finalization_service.dart';
import 'package:govprep/features/rollout_finalization/domain/models/rollout_finalization_state.dart';

void main() {
  group('Release Rollout Decision & Finalization (Phase 91)', () {
    setUpAll(() {
      rolloutFinalizationService.initialize();
    });

    tearDownAll(() {
      rolloutFinalizationService.dispose();
    });

    test('Finalizes release when all prerequisite gates pass', () async {
      final result = await rolloutFinalizationService.evaluateFinalization(
        releaseId: 'rel_prod',
        isCompatible: true,
        isProductionReady: true,
        isPostDeploymentVerified: true,
        isRolloutObservationHealthy: true,
        isRolloutObservationCompleted: true,
        hasActiveIncidents: false,
      );

      expect(result.status, RolloutFinalizationStatus.finalized);
      expect(result.decision, 'COMPLETE');
      expect(result.finalizedAt, isNotNull);
    });

    test('Blocks finalization if an active incident exists', () async {
      final result = await rolloutFinalizationService.evaluateFinalization(
        releaseId: 'rel_prod',
        isCompatible: true,
        isProductionReady: true,
        isPostDeploymentVerified: true,
        isRolloutObservationHealthy: true,
        isRolloutObservationCompleted: true,
        hasActiveIncidents: true,
      );

      expect(result.status, RolloutFinalizationStatus.blocked);
      expect(result.decision, 'BLOCKED');
      expect(result.blockingReason, isNotNull);
    });

    test('Holds finalization if observation is incomplete (Continue)', () async {
      final result = await rolloutFinalizationService.evaluateFinalization(
        releaseId: 'rel_prod',
        isCompatible: true,
        isProductionReady: true,
        isPostDeploymentVerified: true,
        isRolloutObservationHealthy: true,
        isRolloutObservationCompleted: false, // Observation ongoing
        hasActiveIncidents: false,
      );

      expect(result.status, RolloutFinalizationStatus.continuing);
      expect(result.decision, 'CONTINUE');
      expect(result.finalizedAt, isNull);
    });

    test('Blocks finalization if compatibility gate failed', () async {
      final result = await rolloutFinalizationService.evaluateFinalization(
        releaseId: 'rel_prod',
        isCompatible: false, // Phase 88 failure
        isProductionReady: true,
        isPostDeploymentVerified: true,
        isRolloutObservationHealthy: true,
        isRolloutObservationCompleted: true,
        hasActiveIncidents: false,
      );

      expect(result.status, RolloutFinalizationStatus.blocked);
      expect(result.decision, 'BLOCKED');
      expect(result.blockingReason, contains('not compatible'));
    });
  });
}
