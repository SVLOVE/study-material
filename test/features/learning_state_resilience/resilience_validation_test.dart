import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/learning_state_diagnostics/domain/models/learning_state_diagnostic_event.dart';
import 'package:govprep/features/learning_state_diagnostics/application/services/learning_state_diagnostic_service.dart';
import 'package:govprep/features/learning_state_reliability/domain/models/learning_state_incident.dart';
import 'package:govprep/features/learning_state_reliability/application/services/learning_state_reliability_service.dart';
import 'package:govprep/features/learning_state_recovery_verification/domain/models/learning_state_recovery_verification.dart';
import 'package:govprep/features/learning_state_recovery_verification/application/services/learning_state_recovery_verification_service.dart';

void main() {
  group('Learning State Resilience, Capacity & Reliability Validation (Phase 80)', () {
    
    setUpAll(() {
      learningStateReliabilityService.initialize();
      learningStateRecoveryVerificationService.initialize();
    });

    setUp(() {
      // Clear previous incidents to ensure test isolation
      for (var incident in learningStateReliabilityService.activeIncidents.toList()) {
        learningStateReliabilityService.resolveIncident(incident.id);
      }
    });

    test('Duplicate Events - Idempotency Validation', () async {
      final event1 = LearningStateDiagnosticEvent(
        eventType: 'RECONCILIATION_COMPLETED',
        operationId: 'op_001',
        scopeType: 'Topic',
        scopeId: 'topic_101',
        status: DiagnosticEventStatus.success,
        occurredAt: DateTime.now(),
      );

      final event2 = LearningStateDiagnosticEvent(
        eventType: 'RECONCILIATION_COMPLETED',
        operationId: 'op_001', // Same operation ID (duplicate)
        scopeType: 'Topic',
        scopeId: 'topic_101',
        status: DiagnosticEventStatus.success,
        occurredAt: DateTime.now(),
      );

      learningStateDiagnosticService.recordEvent(event1);
      learningStateDiagnosticService.recordEvent(event2);

      expect(learningStateReliabilityService.activeIncidents.isEmpty, isTrue);
    });

    test('Incident Detection and Idempotency Validation', () async {
      for (int i = 0; i < 4; i++) {
        learningStateDiagnosticService.recordEvent(
          LearningStateDiagnosticEvent(
            eventType: 'PUBLICATION_COMPLETED',
            operationId: 'op_fail_$i',
            scopeType: 'Subject',
            scopeId: 'subj_50',
            status: DiagnosticEventStatus.failed,
            occurredAt: DateTime.now(),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));

      final incidents = learningStateReliabilityService.activeIncidents;
      expect(incidents.length, 1);
      final incident = incidents.first;
      expect(incident.type, 'REPEATED_PUBLICATION_FAILURE');
      expect(incident.status, IncidentStatus.detected);
    });

    test('Recovery Verification Closure Validation', () async {
      final incident = LearningStateIncident(
        id: 'inc_test_1',
        type: 'STALE_CONSUMER',
        severity: IncidentSeverity.high,
        status: IncidentStatus.detected,
        scopeType: 'Exam',
        scopeId: 'exam_202',
        detectedAt: DateTime.now(),
      );
      
      learningStateReliabilityService.updateIncident(incident);

      learningStateRecoveryVerificationService.verifyRecoveryForIncident(incident);
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      var verification = learningStateRecoveryVerificationService.getActiveVerification(incident.id);
      expect(verification, isNotNull);
      expect(verification!.status, RecoveryVerificationStatus.verifying);

      learningStateDiagnosticService.recordEvent(LearningStateDiagnosticEvent(
        eventType: 'PUBLICATION_COMPLETED',
        scopeType: 'Exam',
        scopeId: 'exam_202',
        status: DiagnosticEventStatus.success,
        occurredAt: DateTime.now(),
      ));

      await Future.delayed(const Duration(milliseconds: 50));
      expect(learningStateRecoveryVerificationService.getActiveVerification(incident.id)?.publicationVerified, isTrue);
      
      learningStateDiagnosticService.recordEvent(LearningStateDiagnosticEvent(
        eventType: 'DISTRIBUTION_COMPLETED',
        scopeType: 'Exam',
        scopeId: 'exam_202',
        status: DiagnosticEventStatus.success,
        occurredAt: DateTime.now(),
      ));
      
      learningStateDiagnosticService.recordEvent(LearningStateDiagnosticEvent(
        eventType: 'CONVERGENCE_CHECKED',
        scopeType: 'Exam',
        scopeId: 'exam_202',
        status: DiagnosticEventStatus.success, 
        occurredAt: DateTime.now(),
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(learningStateRecoveryVerificationService.getActiveVerification(incident.id), isNull);
      
      expect(learningStateReliabilityService.activeIncidents.any((i) => i.id == incident.id), isFalse);
    });

  });
}
