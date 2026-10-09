import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/release_compatibility/application/services/release_compatibility_service.dart';
import 'package:govprep/features/release_compatibility/domain/models/release_compatibility_state.dart';

void main() {
  group('Release Compatibility & Version Traceability (Phase 88)', () {
    setUpAll(() {
      releaseCompatibilityService.initialize();
    });

    tearDownAll(() {
      releaseCompatibilityService.dispose();
    });

    test('Marks compatible when no blockers or conditions exist', () async {
      final result = await releaseCompatibilityService.evaluateCompatibility(
        currentReleaseId: 'v1.1.0',
        previousReleaseId: 'v1.0.0',
      );

      expect(result.status, ReleaseCompatibilityStatus.compatible);
      expect(result.blockingIssues, isEmpty);
      expect(result.conditionalRequirements, isEmpty);
    });

    test('Marks incompatible when destructive migrations exist', () async {
      final result = await releaseCompatibilityService.evaluateCompatibility(
        currentReleaseId: 'v2.0.0',
        previousReleaseId: 'v1.1.0',
        containsDestructiveMigrations: true,
      );

      expect(result.status, ReleaseCompatibilityStatus.incompatible);
      expect(result.blockingIssues, isNotEmpty);
    });

    test('Marks conditionally compatible when backend must deploy first', () async {
      final result = await releaseCompatibilityService.evaluateCompatibility(
        currentReleaseId: 'v1.2.0',
        previousReleaseId: 'v1.1.0',
        requiresBackendFirst: true,
      );

      expect(result.status, ReleaseCompatibilityStatus.conditionallyCompatible);
      expect(result.conditionalRequirements, isNotEmpty);
      expect(result.blockingIssues, isEmpty);
    });
  });
}
