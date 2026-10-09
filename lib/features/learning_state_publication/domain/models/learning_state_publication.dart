import '../../../learning_state_recalculation/domain/models/learning_state_recalculation_plan.dart';

enum PublicationStatus {
  pending,
  validating,
  readyToPublish,
  published,
  blocked,
  superseded,
  partiallyPublished,
  failed,
}

class LearningStatePublication {
  final String publicationId;
  final String userId;
  final String evidenceId;
  final LearningStateRecalculationPlan recalculationPlan;
  final String targetVersion;
  PublicationStatus status;
  final DateTime preparedAt;
  DateTime? publishedAt;

  LearningStatePublication({
    required this.publicationId,
    required this.userId,
    required this.evidenceId,
    required this.recalculationPlan,
    required this.targetVersion,
    this.status = PublicationStatus.pending,
    required this.preparedAt,
    this.publishedAt,
  });

  bool get isReadyToPublish {
    // Only ready to publish if all recalculation targets are complete without failures.
    // In a real system, we'd distinguish between required vs optional missing data.
    return !recalculationPlan.hasFailures;
  }
}
