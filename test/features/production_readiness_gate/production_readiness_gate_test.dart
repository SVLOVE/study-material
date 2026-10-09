import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/production_readiness_gate/application/services/production_readiness_gate_service.dart';
import 'package:govprep/features/production_readiness_gate/domain/models/release_readiness_state.dart';

void main() {
  group('Production Readiness Gate & Safe Release Validation (Phase 86)', () {
    setUpAll(() {
      productionReadinessGateService.initialize();
    });

    tearDownAll(() {
      productionReadinessGateService.dispose();
    });

    test('Validates release readiness for safe deployment', () async {
      const version = 'v1.2.0';
      
      final state = await productionReadinessGateService.validateReleaseReadiness(version);

      expect(state.status, ReleaseStatus.ready);
      expect(state.blockingChecks, isEmpty);
      expect(state.version, version);
    });

    test('Validates post-deployment smoke tests', () async {
      const version = 'v1.2.0';
      
      // Assume deployed, run smoke tests
      final state = await productionReadinessGateService.validatePostDeploymentSmoke(version);

      expect(state.status, ReleaseStatus.verified);
      expect(state.blockingChecks, isEmpty);
      expect(state.version, version);
    });
  });
}
