import 'dart:math';

import '../../domain/models/learning_state_publication.dart';
import '../../../learning_state_recalculation/domain/models/learning_state_recalculation_plan.dart';
import '../../../learning_state_dependency/domain/models/learning_state_impact.dart';
import '../../../learning_state_distribution/domain/models/learning_state_published_event.dart';
import '../../../learning_state_distribution/application/services/learning_state_distribution_service.dart';
import '../../../learning_state_diagnostics/domain/models/learning_state_diagnostic_event.dart';
import '../../../learning_state_diagnostics/application/services/learning_state_diagnostic_service.dart';

class LearningStatePublicationService {

  LearningStatePublication preparePublication({
    required String userId,
    required String evidenceId,
    required LearningStateRecalculationPlan plan,
    required String targetVersion,
  }) {
    return LearningStatePublication(
      publicationId: 'pub_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      userId: userId,
      evidenceId: evidenceId,
      recalculationPlan: plan,
      targetVersion: targetVersion,
      preparedAt: DateTime.now(),
      status: PublicationStatus.validating,
    );
  }

  Future<void> commitAndPublish({
    required LearningStatePublication publication,
    required LearningStateImpact impact,
  }) async {
    // 1. Validate dependencies and versions
    if (!publication.isReadyToPublish) {
      publication.status = PublicationStatus.blocked;
      // In a real system we might still publish partial state if some dependencies are optional
      return;
    }

    publication.status = PublicationStatus.readyToPublish;

    // 2. Commit logic (e.g. backend transaction to mark version as authoritative)
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate commit
    
    publication.publishedAt = DateTime.now();
    publication.status = PublicationStatus.published;

    // Emit diagnostic event
    learningStateDiagnosticService.recordEvent(
      LearningStateDiagnosticEvent(
        eventType: 'PUBLICATION_COMPLETED',
        operationId: publication.publicationId,
        stateVersion: publication.targetVersion,
        status: DiagnosticEventStatus.success,
        occurredAt: DateTime.now(),
      ),
    );

    // 3. Distribute the published state to consumers
    final event = LearningStatePublishedEvent(
      userId: publication.userId,
      publicationId: publication.publicationId,
      stateVersion: publication.targetVersion,
      impact: impact,
      publishedAt: publication.publishedAt!,
    );
    
    await learningStateDistributionService.distributePublishedState(event);
  }
}

final learningStatePublicationService = LearningStatePublicationService();
