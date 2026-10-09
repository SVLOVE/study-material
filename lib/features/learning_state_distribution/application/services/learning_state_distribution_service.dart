import 'dart:async';

import '../../domain/models/learning_state_published_event.dart';
import '../../../learning_state_dependency/application/services/learning_state_propagation_service.dart';
import '../../../learning_state_diagnostics/domain/models/learning_state_diagnostic_event.dart';
import '../../../learning_state_diagnostics/application/services/learning_state_diagnostic_service.dart';

class LearningStateDistributionService {
  final _publicationStreamController = StreamController<LearningStatePublishedEvent>.broadcast();

  Stream<LearningStatePublishedEvent> get publicationStream => _publicationStreamController.stream;

  Future<void> distributePublishedState(LearningStatePublishedEvent event) async {
    // 1. Notify propagation service to update the snapshot validity (Phase 72 invalidation)
    await learningStatePropagationService.propagateInvalidation(
      userId: event.userId,
      impact: event.impact,
      latestEvidenceAt: event.publishedAt,
    );

    // 2. Broadcast the event so active UI providers can safely refresh 
    // to the identical newly published version without tearing down the whole screen.
    _publicationStreamController.add(event);

    // Emit diagnostic event
    learningStateDiagnosticService.recordEvent(
      LearningStateDiagnosticEvent(
        eventType: 'DISTRIBUTION_COMPLETED',
        operationId: event.publicationId,
        stateVersion: event.stateVersion,
        status: DiagnosticEventStatus.success,
        occurredAt: DateTime.now(),
      ),
    );
  }

  void dispose() {
    _publicationStreamController.close();
  }
}

final learningStateDistributionService = LearningStateDistributionService();
