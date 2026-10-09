import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/business_continuity/application/services/business_continuity_service.dart';
import 'package:govprep/features/service_recovery_orchestration/application/services/service_recovery_orchestrator_service.dart';
import 'package:govprep/features/service_recovery_orchestration/domain/models/service_recovery_state.dart';
import 'package:govprep/features/recovery_stability_validation/application/services/recovery_stability_validation_service.dart';
import 'package:govprep/features/recovery_stability_validation/domain/models/recovery_stability_state.dart';

void main() {
  group('Recovery Stability & Post-Restoration Validation (Phase 84)', () {
    setUpAll(() {
      businessContinuityService.initialize();
      serviceRecoveryOrchestratorService.initialize();
      recoveryStabilityValidationService.initialize();
    });

    tearDownAll(() {
      recoveryStabilityValidationService.dispose();
      serviceRecoveryOrchestratorService.dispose();
      businessContinuityService.dispose();
    });

    test('Validates stable capability post-restoration', () async {
      const capability = 'PRACTICE';
      
      // Setup Phase 82/83: Mark as recovered
      businessContinuityService.restoreCapability(capability);
      serviceRecoveryOrchestratorService.detectRecovery(capability);
      await Future.delayed(const Duration(milliseconds: 100)); // wait for orchestrator

      // Now run Phase 84
      final stability = await recoveryStabilityValidationService.validateStability(capability: capability);

      expect(stability.status, StabilityStatus.stable);
      expect(stability.capability, capability);
    });

    test('Detects regression if capability drops in BC service', () async {
      const capability = 'MOCK_TEST';
      
      // Setup Phase 82/83: Mark as recovered
      businessContinuityService.restoreCapability(capability);
      serviceRecoveryOrchestratorService.detectRecovery(capability);
      await Future.delayed(const Duration(milliseconds: 100)); // wait for orchestrator

      // Oh no, Phase 82 sees it drop again
      businessContinuityService.degradeCapabilityDueToIncident(capability, 'Failed again');

      // Now run Phase 84
      final stability = await recoveryStabilityValidationService.validateStability(capability: capability);

      expect(stability.status, StabilityStatus.regressed);
      expect(stability.instabilityReasons, contains('Capability became unavailable after restore'));
    });

    test('Returns notApplicable if capability was never orchestrated', () async {
      const capability = 'UNKNOWN_FEATURE';
      
      final stability = await recoveryStabilityValidationService.validateStability(capability: capability);

      expect(stability.status, StabilityStatus.notApplicable);
    });
  });
}
