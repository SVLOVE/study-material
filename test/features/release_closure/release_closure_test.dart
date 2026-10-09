import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/release_closure/application/services/release_closure_service.dart';
import 'package:govprep/features/release_closure/domain/models/release_closure_state.dart';

void main() {
  group('Release Lifecycle Closure & Historical Traceability (Phase 92)', () {
    setUpAll(() {
      releaseClosureService.initialize();
    });

    tearDownAll(() {
      releaseClosureService.dispose();
    });

    test('Closes finalized known-good release and sets it as baseline', () async {
      final result = await releaseClosureService.closeRelease(
        releaseId: 'rel_v1',
        isFinalizedKnownGood: true,
        hasMissingPrerequisites: false,
      );

      expect(result.status, ReleaseClosureStatus.closed);
      expect(result.closedAt, isNotNull);
      expect(releaseClosureService.currentBaselineId, 'rel_v1');
    });

    test('Blocks closure if mandatory prerequisites are missing', () async {
      final result = await releaseClosureService.closeRelease(
        releaseId: 'rel_v2',
        isFinalizedKnownGood: true,
        hasMissingPrerequisites: true, // Missing something critical
      );

      expect(result.status, ReleaseClosureStatus.blocked);
      expect(releaseClosureService.currentBaselineId, 'rel_v1'); // Baseline doesn't change
    });

    test('Blocks closure if release is not finalized as known-good (Phase 91 failure)', () async {
      final result = await releaseClosureService.closeRelease(
        releaseId: 'rel_v2',
        isFinalizedKnownGood: false,
        hasMissingPrerequisites: false,
      );

      expect(result.status, ReleaseClosureStatus.blocked);
      expect(releaseClosureService.currentBaselineId, 'rel_v1');
    });

    test('Supersedes older baseline when newer release is closed', () async {
      // close a new one successfully
      final newResult = await releaseClosureService.closeRelease(
        releaseId: 'rel_v2',
        isFinalizedKnownGood: true,
        hasMissingPrerequisites: false,
      );

      expect(newResult.status, ReleaseClosureStatus.closed);
      expect(releaseClosureService.currentBaselineId, 'rel_v2');

      // Check the old baseline (rel_v1)
      final oldRecord = releaseClosureService.getRecord('rel_v1');
      expect(oldRecord?.status, ReleaseClosureStatus.superseded);
      expect(oldRecord?.supersededAt, isNotNull);
    });
  });
}
