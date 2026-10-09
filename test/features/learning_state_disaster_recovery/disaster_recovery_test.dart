import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/learning_state_disaster_recovery/domain/models/learning_state_disaster_recovery.dart';
import 'package:govprep/features/learning_state_disaster_recovery/application/services/learning_state_disaster_recovery_service.dart';

void main() {
  group('Learning State Disaster Recovery Validation (Phase 81)', () {
    
    setUpAll(() {
      learningStateDisasterRecoveryService.initialize();
    });

    tearDown(() {
      learningStateDisasterRecoveryService.dispose();
    });

    test('Full Disaster Recovery Lifecycle - Validation Pipeline', () async {
      const recoveryId = 'dr_test_1';
      const scope = 'exam_db_1';

      // 1. Initiate Recovery
      learningStateDisasterRecoveryService.initiateRecovery(recoveryId, scope);
      var recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery, isNotNull);
      expect(recovery!.status, DisasterRecoveryStatus.preparing);

      // 2. Execute Restore
      learningStateDisasterRecoveryService.executeRestoreOperation(recoveryId);
      recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.status, DisasterRecoveryStatus.restoring);

      // 3. Complete Restore
      learningStateDisasterRecoveryService.completeRestoreOperation(recoveryId);
      recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.status, DisasterRecoveryStatus.validating);

      // 4. Validate Integrity (Schema, Database structure)
      learningStateDisasterRecoveryService.validateIntegrity(recoveryId, success: true);
      recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.integrityValidated, isTrue);

      // 5. Validate Learning State (User Authoritative Data)
      learningStateDisasterRecoveryService.validateLearningState(recoveryId, success: true);
      recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.learningStateValidated, isTrue);

      // 6. Validate Provenance
      learningStateDisasterRecoveryService.validateProvenance(recoveryId, success: true);
      recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.provenanceValidated, isTrue);

      // 7. Validate Publication (Versions, Consumer distribution states)
      learningStateDisasterRecoveryService.validatePublication(recoveryId, success: true);
      recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.publicationValidated, isTrue);

      // 8. Validate Security (RLS) - This should trigger final 'recovered' status
      learningStateDisasterRecoveryService.validateSecurity(recoveryId, success: true);
      recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.securityValidated, isTrue);

      // Verify the final status is recovered
      expect(recovery.status, DisasterRecoveryStatus.recovered);
    });

    test('Partial Disaster Recovery Validation Failure', () async {
      const recoveryId = 'dr_test_fail';
      const scope = 'exam_db_2';

      learningStateDisasterRecoveryService.initiateRecovery(recoveryId, scope);
      learningStateDisasterRecoveryService.executeRestoreOperation(recoveryId);
      learningStateDisasterRecoveryService.completeRestoreOperation(recoveryId);

      // Simulating a schema/integrity failure during restore
      learningStateDisasterRecoveryService.validateIntegrity(recoveryId, success: false);
      learningStateDisasterRecoveryService.validateSecurity(recoveryId, success: true);

      var recovery = learningStateDisasterRecoveryService.getActiveRecovery(recoveryId);
      expect(recovery!.integrityValidated, isFalse);
      expect(recovery.securityValidated, isTrue);
      
      // Because integrity failed, status should remain in 'validating' (or 'failed' if implemented explicitly) 
      // but critically NOT 'recovered'.
      expect(recovery.status, DisasterRecoveryStatus.validating);
    });

  });
}
