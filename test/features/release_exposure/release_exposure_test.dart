import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/release_exposure/application/services/release_exposure_service.dart';
import 'package:govprep/features/release_exposure/domain/models/release_exposure_state.dart';

void main() {
  group('Controlled Release Rollout & Exposure Safety (Phase 89)', () {
    setUpAll(() {
      releaseExposureService.initialize();
    });

    tearDownAll(() {
      releaseExposureService.dispose();
    });

    test('Activates full exposure when compatible, verified, and stable', () async {
      final result = await releaseExposureService.evaluateExposure(
        releaseId: 'rel_1',
        isCompatible: true,
        isVerified: true,
        isStable: true,
      );

      expect(result.status, ReleaseExposureStatus.active);
      expect(result.scope, ReleaseExposureScope.general);
      expect(result.eligible, isTrue);
    });

    test('Blocks exposure if release is incompatible (Phase 88 failure)', () async {
      final result = await releaseExposureService.evaluateExposure(
        releaseId: 'rel_2',
        isCompatible: false,
        isVerified: true,
        isStable: true,
      );

      expect(result.status, ReleaseExposureStatus.blocked);
      expect(result.eligible, isFalse);
    });

    test('Holds exposure if post-deployment verification fails (Phase 87 failure)', () async {
      final result = await releaseExposureService.evaluateExposure(
        releaseId: 'rel_3',
        isCompatible: true,
        isVerified: false,
        isStable: true,
      );

      expect(result.status, ReleaseExposureStatus.held);
      expect(result.eligible, isFalse);
    });

    test('Reduces exposure to internal scope if stability checks flag a regression', () async {
      final result = await releaseExposureService.evaluateExposure(
        releaseId: 'rel_4',
        isCompatible: true,
        isVerified: true,
        isStable: false,
      );

      expect(result.status, ReleaseExposureStatus.reduced);
      expect(result.scope, ReleaseExposureScope.internal);
      expect(result.eligible, isFalse);
    });
  });
}
