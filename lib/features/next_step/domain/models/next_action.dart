class NextAction {
  final String id;
  final String type;
  final String title;
  final String description;
  final String reason;
  final int? estimatedMinutes;
  final String route;
  final bool isPrimary;

  NextAction({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reason,
    this.estimatedMinutes,
    required this.route,
    this.isPrimary = false,
  });
}

class DailyContext {
  final int questionsSolved;
  final int questionsGoal;
  final int scheduledTasksRemaining;
  final int revisionDue;

  DailyContext({
    required this.questionsSolved,
    required this.questionsGoal,
    required this.scheduledTasksRemaining,
    required this.revisionDue,
  });
}

final NextAction dummyPrimaryAction = NextAction(
  id: 'a_1',
  type: 'PracticeTopic',
  title: 'Practice Modern History',
  description: 'Topic remains weak after reassessment.',
  reason: 'Your recent performance remains below your target preparation level.',
  estimatedMinutes: 20,
  route: '/practice',
  isPrimary: true,
);

final List<NextAction> dummySecondaryActions = [
  NextAction(
    id: 'a_2',
    type: 'ReviewMistakes',
    title: 'Review Mistakes',
    description: '7 repeated mistakes need attention',
    reason: 'You recorded repeated mistakes here.',
    route: '/mistake-notebook',
  ),
  NextAction(
    id: 'a_3',
    type: 'StartRevision',
    title: 'Start Smart Revision',
    description: '5 topics due for revision',
    reason: 'Spaced repetition schedule requires review.',
    route: '/revision/smart',
  ),
  NextAction(
    id: 'a_4',
    type: 'ContinueRoadmap',
    title: 'Continue Roadmap',
    description: 'Next: Polity Article 1-4',
    reason: 'You have a scheduled study task due today.',
    route: '/dashboard',
  ),
];

final DailyContext dummyDailyContext = DailyContext(
  questionsSolved: 12,
  questionsGoal: 20,
  scheduledTasksRemaining: 2,
  revisionDue: 5,
);
