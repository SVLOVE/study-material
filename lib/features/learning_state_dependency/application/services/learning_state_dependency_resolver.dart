import '../../domain/models/learning_state_impact.dart';
import '../../../learning_evidence_provenance/domain/models/learning_evidence_provenance.dart';

class LearningStateDependencyResolver {
  Future<LearningStateImpact> resolveImpact(LearningEvidenceProvenance evidence) async {
    // In a real application, this maps evidence.topicId -> subjectId -> examId
    // For demonstration, we simulate the dependency resolution based on available data
    
    final affectedTopics = <String>{};
    final affectedSubjects = <String>{};
    final affectedExams = <String>{};
    final affectedFeatures = <String>{};

    if (evidence.topicId != null) {
      affectedTopics.add(evidence.topicId!);
      // Mock subject resolution
      affectedSubjects.add('subject-${evidence.topicId}');
      // Mock exam resolution
      affectedExams.add('exam-for-${evidence.topicId}');
    }

    if (evidence.sourceType == 'PracticeSession') {
      affectedFeatures.addAll(['Performance', 'SkillProgression', 'AdaptiveDifficulty', 'PreparationHealth', 'NextStep']);
    } else if (evidence.sourceType == 'MockTest') {
      affectedFeatures.addAll(['Performance', 'PreparationHealth', 'NextStep']);
    }

    return LearningStateImpact(
      affectedTopics: affectedTopics,
      affectedSubjects: affectedSubjects,
      affectedExams: affectedExams,
      affectedFeatures: affectedFeatures,
    );
  }
}

final learningStateDependencyResolver = LearningStateDependencyResolver();
