class PreparationHealth {
  final String status; // 'Improving', 'Stable', 'Needs Attention', 'Recovery', 'Insufficient Data'
  final String statusDescription;
  final double accuracy;
  final int topicsImproved;
  final int topicsNeedingAttention;
  final int questionsSolved;
  final double? recentMockAverage;
  final int repeatedMistakes;
  final double syllabusCoverage;

  final List<PreparationGap> gaps;

  PreparationHealth({
    required this.status,
    required this.statusDescription,
    required this.accuracy,
    required this.topicsImproved,
    required this.topicsNeedingAttention,
    required this.questionsSolved,
    this.recentMockAverage,
    required this.repeatedMistakes,
    required this.syllabusCoverage,
    required this.gaps,
  });
}

class PreparationGap {
  final String id;
  final String title;
  final String description;
  final String actionTitle;
  final String actionRoute;

  PreparationGap({
    required this.id,
    required this.title,
    required this.description,
    required this.actionTitle,
    required this.actionRoute,
  });
}

final PreparationHealth dummyPreparationHealth = PreparationHealth(
  status: 'Improving',
  statusDescription: 'Recent performance is trending upward across your active preparation areas.',
  accuracy: 74.0,
  topicsImproved: 8,
  topicsNeedingAttention: 3,
  questionsSolved: 1248,
  recentMockAverage: 72.0,
  repeatedMistakes: 7,
  syllabusCoverage: 42.0,
  gaps: [
    PreparationGap(
      id: 'g_1',
      title: 'Modern History',
      description: 'Low recent practice coverage',
      actionTitle: 'Practice',
      actionRoute: '/practice',
    ),
    PreparationGap(
      id: 'g_2',
      title: 'Full-Length Mock Tests',
      description: 'No recent full-length attempt',
      actionTitle: 'Take Mock Test',
      actionRoute: '/mock-tests',
    ),
  ],
);
