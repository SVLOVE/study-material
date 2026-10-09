import 'dart:async';
import 'dart:math';

import '../../../learning_state_diagnostics/domain/models/learning_state_diagnostic_event.dart';
import '../../../learning_state_diagnostics/application/services/learning_state_diagnostic_service.dart';
import '../../../learning_state_reliability/domain/models/learning_state_incident.dart';
import '../../../learning_state_reliability/application/services/learning_state_reliability_service.dart';
import '../../domain/models/learning_state_recovery_verification.dart';

class LearningStateRecoveryVerificationService {
  final Map<String, LearningStateRecoveryVerification> _activeVerifications = {};
  StreamSubscription? _diagnosticSubscription;
  final _verificationStreamController = StreamController<LearningStateRecoveryVerification>.broadcast();

  Stream<LearningStateRecoveryVerification> get verificationStream => _verificationStreamController.stream;

  LearningStateRecoveryVerification? getActiveVerification(String incidentId) {
    return _activeVerifications[incidentId];
  }

  void initialize() {
    _diagnosticSubscription = learningStateDiagnosticService.eventStream.listen(_onDiagnosticEvent);
  }

  void dispose() {
    _diagnosticSubscription?.cancel();
    _verificationStreamController.close();
  }

  void verifyRecoveryForIncident(LearningStateIncident incident) {
    if (_activeVerifications.containsKey(incident.id)) return; // Already verifying

    final verification = LearningStateRecoveryVerification(
      id: _generateSimpleUuid(),
      incidentId: incident.id,
      scopeType: incident.scopeType,
      scopeId: incident.scopeId,
      status: RecoveryVerificationStatus.verifying,
      startedAt: DateTime.now(),
    );

    _activeVerifications[incident.id] = verification;
    _verificationStreamController.add(verification);
    
    // Update the incident status to recovering
    incident.status = IncidentStatus.recovering;
    learningStateReliabilityService.updateIncident(incident);
  }

  void _onDiagnosticEvent(LearningStateDiagnosticEvent event) {
    if (event.status != DiagnosticEventStatus.success) {
      return; // We only care about success signals for recovery verification
    }

    final affectedVerifications = _activeVerifications.values.where(
      (v) => v.scopeType == event.scopeType && v.scopeId == event.scopeId
    ).toList();

    for (final verification in affectedVerifications) {
      // Record the version we are verifying against, if not set
      if (verification.expectedStateVersion == null && event.stateVersion != null) {
        // Dart does not allow setting final fields after initialization, 
        // but here we just observe. We can assume the first success dictates the version for this recovery pass.
        // For simplicity, we just check completion.
      }

      if (event.eventType == 'PUBLICATION_COMPLETED') {
        verification.publicationVerified = true;
      } else if (event.eventType == 'DISTRIBUTION_COMPLETED') {
        verification.distributionVerified = true;
      } else if (event.eventType == 'CONVERGENCE_CHECKED') {
        verification.convergenceVerified = true;
      }

      if (verification.isFullyVerified) {
        verification.status = RecoveryVerificationStatus.recovered;
        verification.completedAt = DateTime.now();
        
        _activeVerifications.remove(verification.incidentId);

        // Tell Phase 78 that the incident is verified as resolved
        learningStateReliabilityService.resolveIncident(verification.incidentId);
      }
      
      _verificationStreamController.add(verification);
    }
  }

  String _generateSimpleUuid() {
    final random = Random();
    return '${random.nextInt(100000)}-${random.nextInt(100000)}-${random.nextInt(100000)}';
  }
}

final learningStateRecoveryVerificationService = LearningStateRecoveryVerificationService();
