enum PracticeOutcomeStatus {
  stronger,
  consistent,
  needsAttention,
  insufficientEvidence,
}

class TopicOutcome {
  final String topicName;
  final double accuracy;
  final double? previousAccuracy;
  final PracticeOutcomeStatus status;

  TopicOutcome({
    required this.topicName,
    required this.accuracy,
    this.previousAccuracy,
    required this.status,
  });
}

class AdaptivePracticeOutcome {
  final String sessionId;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  
  // Composition matching
  final int weakTopicsTarget;
  final int revisionTarget;
  final int skillReinforcementTarget;

  final List<TopicOutcome> topicOutcomes;

  final String difficultyLevel;
  final String difficultyFeedback; // e.g. 'About right'

  final String explanation; // "What this tells you"

  AdaptivePracticeOutcome({
    required this.sessionId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.weakTopicsTarget,
    required this.revisionTarget,
    required this.skillReinforcementTarget,
    required this.topicOutcomes,
    required this.difficultyLevel,
    required this.difficultyFeedback,
    required this.explanation,
  });
}

final AdaptivePracticeOutcome dummyPracticeOutcome = AdaptivePracticeOutcome(
  sessionId: 'session_abc',
  totalQuestions: 15,
  correctAnswers: 12,
  accuracy: 80.0,
  weakTopicsTarget: 6,
  revisionTarget: 5,
  skillReinforcementTarget: 4,
  difficultyLevel: 'Medium',
  difficultyFeedback: 'About right',
  explanation: 'Your Percentages performance is stronger than your earlier comparable attempts. Time & Work still needs additional evidence.',
  topicOutcomes: [
    TopicOutcome(
      topicName: 'Percentages',
      accuracy: 82.0,
      previousAccuracy: 71.0,
      status: PracticeOutcomeStatus.stronger,
    ),
    TopicOutcome(
      topicName: 'Ratio & Proportion',
      accuracy: 78.0,
      previousAccuracy: 75.0,
      status: PracticeOutcomeStatus.consistent,
    ),
    TopicOutcome(
      topicName: 'Time & Work',
      accuracy: 61.0,
      previousAccuracy: 65.0,
      status: PracticeOutcomeStatus.needsAttention,
    ),
  ],
);
