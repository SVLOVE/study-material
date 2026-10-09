class AdaptiveDifficultyState {
  final String? topicId;
  final String? subjectId;
  final String currentDifficulty;
  final String recommendedDifficulty;
  final String? reason;
  final String status; // e.g., 'stable', 'increase', 'decrease', 'insufficientData'

  AdaptiveDifficultyState({
    this.topicId,
    this.subjectId,
    required this.currentDifficulty,
    required this.recommendedDifficulty,
    this.reason,
    required this.status,
  });
}

final AdaptiveDifficultyState dummyAdaptiveState = AdaptiveDifficultyState(
  topicId: 't_percentage',
  currentDifficulty: 'Medium',
  recommendedDifficulty: 'Hard',
  status: 'increase',
  reason: 'Your recent Medium-level results have been consistently strong.',
);
