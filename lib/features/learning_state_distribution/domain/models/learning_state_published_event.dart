import '../../../learning_state_dependency/domain/models/learning_state_impact.dart';

class LearningStatePublishedEvent {
  final String userId;
  final String publicationId;
  final String stateVersion;
  final LearningStateImpact impact;
  final DateTime publishedAt;

  const LearningStatePublishedEvent({
    required this.userId,
    required this.publicationId,
    required this.stateVersion,
    required this.impact,
    required this.publishedAt,
  });
}
