enum ActionOutcomeStatus {
  improved,
  maintained,
  needsMorePractice,
  declined,
  incomplete,
  insufficientData,
}

class ActionOutcome {
  final String actionId;
  final String actionTitle;
  final String actionType;
  final int questionsCompleted;
  final ActionOutcomeStatus status;
  final double? beforeAccuracy;
  final double? afterAccuracy;
  final List<String> improvements;

  ActionOutcome({
    required this.actionId,
    required this.actionTitle,
    required this.actionType,
    required this.questionsCompleted,
    required this.status,
    this.beforeAccuracy,
    this.afterAccuracy,
    required this.improvements,
  });

  double? get changePoints {
    if (beforeAccuracy != null && afterAccuracy != null) {
      return afterAccuracy! - beforeAccuracy!;
    }
    return null;
  }
}

final ActionOutcome dummyActionOutcome = ActionOutcome(
  actionId: 'a_1',
  actionTitle: 'Percentage Problems',
  actionType: 'Practice',
  questionsCompleted: 15,
  status: ActionOutcomeStatus.improved,
  beforeAccuracy: 52.0,
  afterAccuracy: 73.0,
  improvements: [
    'Accuracy ↑',
    'Correct Answers ↑',
    'Repeated Mistakes ↓',
  ],
);
