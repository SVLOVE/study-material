import 'dart:async';
import 'dart:math';

import '../../../learning_state_diagnostics/domain/models/learning_state_diagnostic_event.dart';
import '../../../learning_state_diagnostics/application/services/learning_state_diagnostic_service.dart';
import '../../domain/models/learning_state_incident.dart';

class LearningStateReliabilityService {
  final Map<String, LearningStateIncident> _activeIncidents = {};
  final Map<String, int> _failureCounters = {};
  final _incidentStreamController = StreamController<LearningStateIncident>.broadcast();
  StreamSubscription? _diagnosticSubscription;

  // Thresholds (in a real app, these would come from remote config)
  static const int _publicationFailureThreshold = 3;
  static const int _convergenceFailureThreshold = 4;

  Stream<LearningStateIncident> get incidentStream => _incidentStreamController.stream;
  List<LearningStateIncident> get activeIncidents => _activeIncidents.values.toList();

  void initialize() {
    _diagnosticSubscription = learningStateDiagnosticService.eventStream.listen(_onDiagnosticEvent);
  }

  void dispose() {
    _diagnosticSubscription?.cancel();
    _incidentStreamController.close();
  }

  void _onDiagnosticEvent(LearningStateDiagnosticEvent event) {
    if (event.status == DiagnosticEventStatus.failed || event.status == DiagnosticEventStatus.stale) {
      _handleFailure(event);
    } else if (event.status == DiagnosticEventStatus.success) {
      _handleSuccess(event);
    }
  }

  void _handleFailure(LearningStateDiagnosticEvent event) {
    final scopeKey = '${event.eventType}_${event.scopeType}_${event.scopeId}';
    final currentCount = (_failureCounters[scopeKey] ?? 0) + 1;
    _failureCounters[scopeKey] = currentCount;

    if (event.eventType == 'PUBLICATION_COMPLETED' && currentCount >= _publicationFailureThreshold) {
      _detectIncident(
        type: 'REPEATED_PUBLICATION_FAILURE',
        severity: IncidentSeverity.high,
        event: event,
      );
    } else if (event.eventType == 'CONVERGENCE_CHECKED' && currentCount >= _convergenceFailureThreshold) {
      _detectIncident(
        type: 'PERSISTENT_CONVERGENCE_FAILURE',
        severity: IncidentSeverity.medium,
        event: event,
      );
    }
  }

  void _handleSuccess(LearningStateDiagnosticEvent event) {
    final scopeKey = '${event.eventType}_${event.scopeType}_${event.scopeId}';
    _failureCounters.remove(scopeKey);

    // Note: We no longer auto-resolve incidents here. 
    // Phase 79 (LearningStateRecoveryVerificationService) is now responsible 
    // for tracking the full recovery chain and calling resolveIncident().
  }

  void _detectIncident({
    required String type,
    required IncidentSeverity severity,
    required LearningStateDiagnosticEvent event,
  }) {
    final fingerprint = '${type}_${event.scopeType}_${event.scopeId}';
    
    if (_activeIncidents.containsKey(fingerprint)) {
      return; // Already active, deduplicate
    }

    final incident = LearningStateIncident(
      id: _generateSimpleUuid(),
      type: type,
      severity: severity,
      status: IncidentStatus.detected,
      scopeType: event.scopeType,
      scopeId: event.scopeId,
      operationId: event.operationId,
      detectedAt: DateTime.now(),
    );

    _activeIncidents[fingerprint] = incident;
    _incidentStreamController.add(incident);
  }

  void updateIncident(LearningStateIncident incident) {
    final fingerprint = incident.fingerprint;
    if (_activeIncidents.containsKey(fingerprint)) {
      _activeIncidents[fingerprint] = incident;
      _incidentStreamController.add(incident);
    }
  }

  void resolveIncident(String id) {
    final fingerprint = _activeIncidents.keys.firstWhere((k) => _activeIncidents[k]?.id == id, orElse: () => '');
    if (fingerprint.isNotEmpty) {
      _resolveIncident(fingerprint);
    }
  }

  void _resolveIncident(String fingerprint) {
    final incident = _activeIncidents[fingerprint];
    if (incident != null) {
      incident.status = IncidentStatus.resolved;
      incident.resolvedAt = DateTime.now();
      _activeIncidents.remove(fingerprint);
      _incidentStreamController.add(incident); // Emit resolution update
    }
  }

  String _generateSimpleUuid() {
    final random = Random();
    return '${random.nextInt(100000)}-${random.nextInt(100000)}-${random.nextInt(100000)}';
  }
}

final learningStateReliabilityService = LearningStateReliabilityService();
