class StudySessionConfiguration {
  final String? activityType;
  final String? examId;
  final String? subjectId;
  final String? topicId;
  
  final String language;
  final int questionCount;
  final String difficulty;
  final String mode;

  final String? sourceActionId;
  final String? sourceTaskId;

  final bool isPersonalized;
  final String? personalizationExplanation;

  StudySessionConfiguration({
    this.activityType,
    this.examId,
    this.subjectId,
    this.topicId,
    this.language = 'English',
    this.questionCount = 10,
    this.difficulty = 'Medium',
    this.mode = 'Practice',
    this.sourceActionId,
    this.sourceTaskId,
    this.isPersonalized = false,
    this.personalizationExplanation,
  });

  StudySessionConfiguration copyWith({
    String? language,
    int? questionCount,
    String? difficulty,
    String? mode,
  }) {
    return StudySessionConfiguration(
      activityType: activityType,
      examId: examId,
      subjectId: subjectId,
      topicId: topicId,
      language: language ?? this.language,
      questionCount: questionCount ?? this.questionCount,
      difficulty: difficulty ?? this.difficulty,
      mode: mode ?? this.mode,
      sourceActionId: sourceActionId,
      sourceTaskId: sourceTaskId,
      isPersonalized: isPersonalized,
      personalizationExplanation: personalizationExplanation,
    );
  }
}

final StudySessionConfiguration dummyConfiguration = StudySessionConfiguration(
  activityType: 'Practice',
  language: 'Tamil',
  questionCount: 15,
  difficulty: 'Medium',
  mode: 'Topic Practice',
  isPersonalized: true,
  personalizationExplanation: 'You often complete shorter focused practice sessions.',
);
