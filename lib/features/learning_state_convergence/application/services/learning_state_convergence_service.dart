import '../../domain/models/learning_state_convergence_status.dart';
import '../../../learning_state_distribution/domain/models/learning_state_published_event.dart';
import '../../../learning_state_distribution/application/services/learning_state_distribution_service.dart';
import '../../../learning_state_diagnostics/domain/models/learning_state_diagnostic_event.dart';
import '../../../learning_state_diagnostics/application/services/learning_state_diagnostic_service.dart';

class LearningStateConvergenceService {
  String? _latestPublishedVersion;
  final Map<String, String> _latestPublishedVersionByScope = {};

  LearningStateConvergenceService() {
    // Listen to Phase 75 distribution events to know what the expected state is
    learningStateDistributionService.publicationStream.listen(_onStatePublished);
  }

  void _onStatePublished(LearningStatePublishedEvent event) {
    _latestPublishedVersion = event.stateVersion;
    
    // Store expected versions by scope
    for (final topic in event.impact.affectedTopics) {
      _latestPublishedVersionByScope['topic_$topic'] = event.stateVersion;
    }
    for (final subject in event.impact.affectedSubjects) {
      _latestPublishedVersionByScope['subject_$subject'] = event.stateVersion;
    }
    for (final exam in event.impact.affectedExams) {
      _latestPublishedVersionByScope['exam_$exam'] = event.stateVersion;
    }
  }

  ConsumerConvergenceStatus verifyConvergence({
    required String scopeType,
    required String? scopeId,
    required String consumerStateVersion,
  }) {
    final scopeKey = scopeId != null ? '${scopeType}_$scopeId' : scopeType;
    final expectedVersion = _latestPublishedVersionByScope[scopeKey] ?? _latestPublishedVersion;

    if (expectedVersion == null) {
      return ConsumerConvergenceStatus.notApplicable;
    }

    if (consumerStateVersion == expectedVersion) {
      _emitConvergenceEvent(scopeType, scopeId, consumerStateVersion, DiagnosticEventStatus.success);
      return ConsumerConvergenceStatus.converged;
    }

    // In a real app we'd compare versions to see if it's strictly older.
    // For now, if it doesn't match the expected version, it's stale.
    _emitConvergenceEvent(scopeType, scopeId, consumerStateVersion, DiagnosticEventStatus.stale);
    return ConsumerConvergenceStatus.stale;
  }

  void _emitConvergenceEvent(String scopeType, String? scopeId, String version, DiagnosticEventStatus status) {
    learningStateDiagnosticService.recordEvent(
      LearningStateDiagnosticEvent(
        eventType: 'CONVERGENCE_CHECKED',
        scopeType: scopeType,
        scopeId: scopeId,
        stateVersion: version,
        status: status,
        occurredAt: DateTime.now(),
      ),
    );
  }
}

final learningStateConvergenceService = LearningStateConvergenceService();
