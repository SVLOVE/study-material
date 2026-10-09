class LearningStateImpact {
  final Set<String> affectedTopics;
  final Set<String> affectedSubjects;
  final Set<String> affectedExams;
  final Set<String> affectedFeatures;

  const LearningStateImpact({
    this.affectedTopics = const {},
    this.affectedSubjects = const {},
    this.affectedExams = const {},
    this.affectedFeatures = const {},
  });

  bool get hasImpact =>
      affectedTopics.isNotEmpty ||
      affectedSubjects.isNotEmpty ||
      affectedExams.isNotEmpty ||
      affectedFeatures.isNotEmpty;
}
