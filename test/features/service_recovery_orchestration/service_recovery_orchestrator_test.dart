import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/service_recovery_orchestration/domain/models/service_recovery_state.dart';
import 'package:govprep/features/service_recovery_orchestration/application/services/service_recovery_orchestrator_service.dart';
import 'package:govprep/features/business_continuity/application/services/business_continuity_service.dart';

void main() {
  group('Service Recovery Orchestration & Controlled Restoration (Phase 83)', () {
    
    setUpAll(() {
      businessContinuityService.initialize();
      serviceRecoveryOrchestratorService.initialize();
    });

    tearDownAll(() {
      serviceRecoveryOrchestratorService.dispose();
      businessContinuityService.dispose();
    });

    test('Recovery Lifecycle: Detected -> Validated -> Restored', () async {
      const capability = 'PRACTICE';
      
      // Initially degrade the feature using Phase 82
      businessContinuityService.degradeCapabilityDueToIncident(capability, 'Backend offline');
      expect(businessContinuityService.isAvailable(capability), isFalse);

      // Trigger Phase 83 Recovery Detection
      serviceRecoveryOrchestratorService.detectRecovery(capability, incidentId: 'inc_123');
      
      // Give the async orchestrator a tick to process
      await Future.delayed(const Duration(milliseconds: 100));

      // After successful orchestration, capability should be Restored in Phase 83
      final recoveryState = serviceRecoveryOrchestratorService.getRecoveryState(capability);
      expect(recoveryState, isNotNull);
      expect(recoveryState!.status, RecoveryStatus.restored);

      // And it should be fully available in Phase 82 (Business Continuity)
      expect(businessContinuityService.isAvailable(capability), isTrue);
    });

    test('Idempotency: Ignores duplicate recovery triggers', () async {
      const capability = 'MOCK_TEST';
      
      serviceRecoveryOrchestratorService.detectRecovery(capability);
      final firstState = serviceRecoveryOrchestratorService.getRecoveryState(capability);
      
      // Trigger again immediately
      serviceRecoveryOrchestratorService.detectRecovery(capability);
      final secondState = serviceRecoveryOrchestratorService.getRecoveryState(capability);
      
      // Identical instance (no overwrite while in progress)
      expect(identical(firstState, secondState), isTrue);
    });
  });
}
