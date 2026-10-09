import '../../domain/models/learning_state_recalculation_plan.dart';
import '../../../learning_state_dependency/domain/models/learning_state_impact.dart';

class LearningStateOrchestratorService {
  LearningStateRecalculationPlan createPlan({
    required String userId,
    required String evidenceId,
    required LearningStateImpact impact,
  }) {
    final targets = <LearningStateTarget>[];

    // Level 1 - Direct Derived State
    for (final topicId in impact.affectedTopics) {
      targets.add(LearningStateTarget(stateType: 'TopicPerformance', scopeId: topicId, dependencyLevel: 1));
    }

    // Level 2 - Aggregated Learning State
    for (final subjectId in impact.affectedSubjects) {
      targets.add(LearningStateTarget(stateType: 'SubjectPerformance', scopeId: subjectId, dependencyLevel: 2));
    }
    for (final examId in impact.affectedExams) {
      targets.add(LearningStateTarget(stateType: 'ExamPerformance', scopeId: examId, dependencyLevel: 2));
    }
    if (impact.affectedFeatures.contains('SkillProgression')) {
      targets.add(LearningStateTarget(stateType: 'SkillProgression', dependencyLevel: 2));
    }

    // Level 3 - Preparation State
    if (impact.affectedFeatures.contains('PreparationHealth')) {
      targets.add(LearningStateTarget(stateType: 'PreparationHealth', dependencyLevel: 3));
    }

    // Level 4 - Decisions
    if (impact.affectedFeatures.contains('NextStep')) {
      targets.add(LearningStateTarget(stateType: 'NextStep', dependencyLevel: 4));
    }
    if (impact.affectedFeatures.contains('AdaptiveDifficulty')) {
      targets.add(LearningStateTarget(stateType: 'AdaptiveDifficulty', dependencyLevel: 4));
    }

    // Sort by dependency level to ensure topological processing
    targets.sort((a, b) => a.dependencyLevel.compareTo(b.dependencyLevel));

    return LearningStateRecalculationPlan(
      userId: userId,
      evidenceId: evidenceId,
      targets: targets,
      createdAt: DateTime.now(),
    );
  }

  Future<void> executePlan(LearningStateRecalculationPlan plan) async {
    for (final target in plan.targets) {
      target.status = RecalculationStatus.calculating;
      
      // Simulate authoritative backend call that computes the actual state
      await Future.delayed(const Duration(milliseconds: 150));
      
      target.status = RecalculationStatus.updated;
    }
  }
}

final learningStateOrchestratorService = LearningStateOrchestratorService();
