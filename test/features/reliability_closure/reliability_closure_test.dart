import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/business_continuity/application/services/business_continuity_service.dart';
import 'package:govprep/features/service_recovery_orchestration/application/services/service_recovery_orchestrator_service.dart';
import 'package:govprep/features/recovery_stability_validation/application/services/recovery_stability_validation_service.dart';
import 'package:govprep/features/reliability_closure/application/services/reliability_closure_coordinator_service.dart';
import 'package:govprep/features/reliability_closure/domain/models/reliability_closure_state.dart';

void main() {
  group('Reliability Closure & Known-Good State Restoration (Phase 85)', () {
    setUpAll(() {
      businessContinuityService.initialize();
      serviceRecoveryOrchestratorService.initialize();
      recoveryStabilityValidationService.initialize();
      reliabilityClosureCoordinatorService.initialize();
    });

    tearDownAll(() {
      reliabilityClosureCoordinatorService.dispose();
      recoveryStabilityValidationService.dispose();
      serviceRecoveryOrchestratorService.dispose();
      businessContinuityService.dispose();
    });

    test('Closes workflow when stability is confirmed', () async {
      const capability = 'PRACTICE';
      
      // 1. Recover capability
      businessContinuityService.restoreCapability(capability);
      serviceRecoveryOrchestratorService.detectRecovery(capability);
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 2. Validate stability
      await recoveryStabilityValidationService.validateStability(capability: capability);

      // 3. Coordinate Closure
      final closure = await reliabilityClosureCoordinatorService.validateClosure(capability: capability);
      
      expect(closure.status, ClosureStatus.closed);
    });

    test('Blocks closure with insufficient evidence if stability is unknown', () async {
      const capability = 'MOCK_TEST';
      
      // Orchestrator starts recovery but we DO NOT validate stability (simulating unknown stability state)
      businessContinuityService.restoreCapability(capability);
      serviceRecoveryOrchestratorService.detectRecovery(capability);
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 3. Coordinate Closure
      final closure = await reliabilityClosureCoordinatorService.validateClosure(capability: capability);
      
      expect(closure.status, ClosureStatus.insufficientEvidence);
      expect(closure.blockingConditions, contains('Stability not confirmed yet'));
    });

    test('Reopens closure if stability regressed', () async {
      const capability = 'LEADERBOARD';
      
      // 1. Recover capability
      businessContinuityService.restoreCapability(capability);
      serviceRecoveryOrchestratorService.detectRecovery(capability);
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 2. Regress capability
      businessContinuityService.degradeCapabilityDueToIncident(capability, 'Failed again');
      await recoveryStabilityValidationService.validateStability(capability: capability);

      // 3. Coordinate Closure
      final closure = await reliabilityClosureCoordinatorService.validateClosure(capability: capability);
      
      expect(closure.status, ClosureStatus.reopened);
      expect(closure.blockingConditions, contains('Stability validation failed, regressed'));
    });
  });
}
