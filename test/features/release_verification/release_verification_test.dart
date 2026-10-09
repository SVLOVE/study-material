import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/release_verification/application/services/release_verification_service.dart';
import 'package:govprep/features/release_verification/domain/models/release_verification_state.dart';

void main() {
  group('Production Release Verification & Post-Deployment Acceptance (Phase 87)', () {
    setUpAll(() {
      releaseVerificationService.initialize();
    });

    tearDownAll(() {
      releaseVerificationService.dispose();
    });

    test('Fully accepted when all verifications pass', () async {
      const releaseId = 'rel_prod_1';
      
      final result = await releaseVerificationService.verifyRelease(releaseId);

      expect(result.status, ReleaseVerificationStatus.accepted);
      expect(result.learningStateVerified, isTrue);
      expect(result.authVerified, isTrue);
      expect(result.releaseId, releaseId);
    });
  });
}
