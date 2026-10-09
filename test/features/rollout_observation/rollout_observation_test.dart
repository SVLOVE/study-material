import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/rollout_observation/application/services/rollout_observation_service.dart';
import 'package:govprep/features/rollout_observation/domain/models/rollout_observation_state.dart';

void main() {
  group('Release Rollout Observation & Exposure Decision (Phase 90)', () {
    setUpAll(() {
      rolloutObservationService.initialize();
    });

    tearDownAll(() {
      rolloutObservationService.dispose();
    });

    test('Reduces exposure if an active incident is detected (Phase 78 hook)', () async {
      final result = await rolloutObservationService.observeRelease(
        releaseId: 'rel_prod',
        hasActiveIncident: true,
        hasStabilityRegression: false,
        hasMissingMandatoryEvidence: false,
        isFullyExposedAndVerified: false,
      );

      expect(result.status, RolloutObservationStatus.degraded);
      expect(result.decision, RolloutDecision.reduceExposure);
    });

    test('Holds exposure if stability regression is detected (Phase 84 hook)', () async {
      final result = await rolloutObservationService.observeRelease(
        releaseId: 'rel_prod',
        hasActiveIncident: false,
        hasStabilityRegression: true,
        hasMissingMandatoryEvidence: false,
        isFullyExposedAndVerified: false,
      );

      expect(result.status, RolloutObservationStatus.unstable);
      expect(result.decision, RolloutDecision.holdExposure);
    });

    test('Holds exposure if evidence is missing (Unknown ≠ Continue)', () async {
      final result = await rolloutObservationService.observeRelease(
        releaseId: 'rel_prod',
        hasActiveIncident: false,
        hasStabilityRegression: false,
        hasMissingMandatoryEvidence: true,
        isFullyExposedAndVerified: false,
      );

      expect(result.status, RolloutObservationStatus.insufficientEvidence);
      expect(result.decision, RolloutDecision.holdExposure);
    });

    test('Continues exposure when all signals remain healthy', () async {
      final result = await rolloutObservationService.observeRelease(
        releaseId: 'rel_prod',
        hasActiveIncident: false,
        hasStabilityRegression: false,
        hasMissingMandatoryEvidence: false,
        isFullyExposedAndVerified: false,
      );

      expect(result.status, RolloutObservationStatus.healthy);
      expect(result.decision, RolloutDecision.continueExposure);
    });
  });
}
