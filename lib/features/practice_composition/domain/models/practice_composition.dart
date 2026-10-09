class PracticeCompositionItem {
  final String sourceType;
  final String? sourceId;
  final int questionCount;
  final String? difficulty;
  final String? reason;

  PracticeCompositionItem({
    required this.sourceType,
    this.sourceId,
    required this.questionCount,
    this.difficulty,
    this.reason,
  });
}

class PracticeComposition {
  final String? examId;
  final String? subjectId;
  final String? topicId;
  final String mode; // e.g., 'Adaptive', 'Balanced', 'Manual'
  final int questionCount;
  final List<PracticeCompositionItem> items;
  final String? explanation;
  final bool isAdaptive;

  PracticeComposition({
    this.examId,
    this.subjectId,
    this.topicId,
    required this.mode,
    required this.questionCount,
    required this.items,
    this.explanation,
    required this.isAdaptive,
  });
}

final PracticeComposition dummyAdaptiveComposition = PracticeComposition(
  mode: 'Adaptive',
  questionCount: 15,
  isAdaptive: true,
  explanation: 'This session prioritizes topics where your recent performance needs reinforcement while keeping some questions from areas where your skills are improving.',
  items: [
    PracticeCompositionItem(
      sourceType: 'Weak Topics',
      questionCount: 6,
      reason: 'Needs reinforcement based on recent performance',
    ),
    PracticeCompositionItem(
      sourceType: 'Revision',
      questionCount: 5,
      reason: 'Currently in your revision queue',
    ),
    PracticeCompositionItem(
      sourceType: 'Skill Reinforcement',
      questionCount: 4,
      reason: 'Maintain proficiency in improving topics',
    ),
  ],
);
