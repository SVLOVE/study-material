import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/baseline_integrity/application/services/baseline_integrity_service.dart';
import 'package:govprep/features/baseline_integrity/domain/models/baseline_integrity_state.dart';

void main() {
  group('Release Baseline Integrity & Evolution Guard (Phase 93)', () {
    setUpAll(() {
      baselineIntegrityService.initialize();
    });

    tearDownAll(() {
      baselineIntegrityService.dispose();
    });

    test('Validates a perfect historical closed baseline', () async {
      final result = await baselineIntegrityService.validateBaseline(
        releaseId: 'rel_v1',
        isClosed: true,
        isKnownGood: true,
        isLineageIntact: true,
        isSuperseded: false,
        isEnvironmentValid: true,
      );

      expect(result.status, ReleaseBaselineStatus.valid);
      expect(result.blockingReason, isNull);
    });

    test('Blocks evolution if the baseline is missing Phase 92 closure', () async {
      final result = await baselineIntegrityService.validateBaseline(
        releaseId: 'rel_v2',
        isClosed: false,
        isKnownGood: true,
        isLineageIntact: true,
        isSuperseded: false,
        isEnvironmentValid: true,
      );

      expect(result.status, ReleaseBaselineStatus.blocked);
      expect(result.blockingReason, contains('closed'));
    });

    test('Marks as invalid if environment crosses boundaries', () async {
      final result = await baselineIntegrityService.validateBaseline(
        releaseId: 'rel_staging',
        isClosed: true,
        isKnownGood: true,
        isLineageIntact: true,
        isSuperseded: false,
        isEnvironmentValid: false, // Trying to use staging in prod
      );

      expect(result.status, ReleaseBaselineStatus.invalid);
      expect(result.blockingReason, contains('Environment'));
    });

    test('Marks as superseded if a newer baseline exists', () async {
      final result = await baselineIntegrityService.validateBaseline(
        releaseId: 'rel_v1',
        isClosed: true,
        isKnownGood: true,
        isLineageIntact: true,
        isSuperseded: true, // Newer release took over
        isEnvironmentValid: true,
      );

      expect(result.status, ReleaseBaselineStatus.superseded);
      expect(result.blockingReason, contains('newer release'));
    });
  });
}
