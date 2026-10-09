enum SkillProgressionStatus {
  improving,
  stable,
  declining,
  recovering,
  strong,
  needsAttention,
  insufficientData,
}

class SkillProgression {
  final String id;
  final String subjectName;
  final String topicId;
  final String topicName;
  final SkillProgressionStatus status;
  final String? version;
  
  final double? previousAccuracy;
  final double? recentAccuracy;
  
  final int previousAttempts;
  final int recentAttempts;
  
  final String? previousDifficulty;
  final String? currentDifficulty;
  
  final String evidenceSummary;

  SkillProgression({
    required this.id,
    required this.subjectName,
    required this.topicId,
    required this.topicName,
    required this.status,
    this.version,
    this.previousAccuracy,
    this.recentAccuracy,
    required this.previousAttempts,
    required this.recentAttempts,
    this.previousDifficulty,
    this.currentDifficulty,
    required this.evidenceSummary,
  });
}

final List<SkillProgression> dummySkillProgressions = [
  SkillProgression(
    id: 'sp_1',
    subjectName: 'Quantitative Aptitude',
    topicId: 't_percentages',
    topicName: 'Percentages',
    status: SkillProgressionStatus.improving,
    version: 'v42',
    previousAccuracy: 58.0,
    recentAccuracy: 81.0,
    previousAttempts: 20,
    recentAttempts: 15,
    previousDifficulty: 'Easy',
    currentDifficulty: 'Medium',
    evidenceSummary: 'Accuracy improved from 58% to 81% while practicing at a higher difficulty.',
  ),
  SkillProgression(
    id: 'sp_2',
    subjectName: 'Quantitative Aptitude',
    topicId: 't_ratio_proportion',
    topicName: 'Ratio & Proportion',
    status: SkillProgressionStatus.strong,
    version: 'v42',
    previousAccuracy: 85.0,
    recentAccuracy: 88.0,
    previousAttempts: 30,
    recentAttempts: 25,
    previousDifficulty: 'Medium',
    currentDifficulty: 'Hard',
    evidenceSummary: 'Consistently strong performance at high difficulty.',
  ),
  SkillProgression(
    id: 'sp_3',
    subjectName: 'Quantitative Aptitude',
    topicId: 't_time_work',
    topicName: 'Time & Work',
    status: SkillProgressionStatus.needsAttention,
    version: 'v42',
    previousAccuracy: 72.0,
    recentAccuracy: 59.0,
    previousAttempts: 15,
    recentAttempts: 10,
    previousDifficulty: 'Medium',
    currentDifficulty: 'Medium',
    evidenceSummary: 'Recent accuracy is lower than your earlier results.',
  ),
  SkillProgression(
    id: 'sp_4',
    subjectName: 'Quantitative Aptitude',
    topicId: 't_probability',
    topicName: 'Probability',
    status: SkillProgressionStatus.insufficientData,
    version: 'v42',
    previousAttempts: 0,
    recentAttempts: 4,
    evidenceSummary: 'Complete a few more practice attempts to establish a reliable progression trend.',
  ),
];
