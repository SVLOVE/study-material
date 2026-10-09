class MistakeRecord {
  final String id;
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final int userSelectedAnswerIndex;
  final String explanation;
  final String examName;
  final String subjectName;
  final String topicName;
  final String difficulty;
  final String sourceType; // "Mock Test", "Practice", "Daily Quiz"
  final DateTime firstRecordedAt;
  final DateTime lastRecordedAt;
  final int incorrectAttemptCount;
  final bool isResolved;
  final String? mistakeCategory; // "Conceptual Error", "Calculation Error", etc.
  final String? personalNote;

  MistakeRecord({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.userSelectedAnswerIndex,
    required this.explanation,
    required this.examName,
    required this.subjectName,
    required this.topicName,
    required this.difficulty,
    required this.sourceType,
    required this.firstRecordedAt,
    required this.lastRecordedAt,
    required this.incorrectAttemptCount,
    required this.isResolved,
    this.mistakeCategory,
    this.personalNote,
  });
}

// Dummy data
final List<MistakeRecord> dummyMistakes = [
  MistakeRecord(
    id: 'm1',
    questionId: 'q101',
    questionText: 'Which Article of the Indian Constitution deals with Constitutional Remedies?',
    options: ['Article 32', 'Article 14', 'Article 21', 'Article 19'],
    correctAnswerIndex: 0,
    userSelectedAnswerIndex: 2,
    explanation: 'Article 32 of the Indian Constitution provides the right to constitutional remedies. It allows citizens to approach the Supreme Court directly for the enforcement of fundamental rights.',
    examName: 'TNPSC Group 2',
    subjectName: 'Polity',
    topicName: 'Indian Constitution',
    difficulty: 'Medium',
    sourceType: 'Practice Arena',
    firstRecordedAt: DateTime.now().subtract(const Duration(days: 10)),
    lastRecordedAt: DateTime.now().subtract(const Duration(days: 2)),
    incorrectAttemptCount: 3,
    isResolved: false,
    mistakeCategory: 'Conceptual Error',
    personalNote: 'Need to review all fundamental rights articles again.',
  ),
  MistakeRecord(
    id: 'm2',
    questionId: 'q205',
    questionText: 'If 20% of a = b, then b% of 20 is the same as:',
    options: ['4% of a', '5% of a', '20% of a', 'None of these'],
    correctAnswerIndex: 0,
    userSelectedAnswerIndex: 3,
    explanation: '20% of a = b => 0.2a = b.\nb% of 20 = (b/100) * 20 = (0.2a/100) * 20 = 4% of a.',
    examName: 'SSC CGL',
    subjectName: 'Quantitative Aptitude',
    topicName: 'Percentages',
    difficulty: 'Hard',
    sourceType: 'Mock Test 4',
    firstRecordedAt: DateTime.now().subtract(const Duration(days: 5)),
    lastRecordedAt: DateTime.now().subtract(const Duration(days: 5)),
    incorrectAttemptCount: 1,
    isResolved: false,
    mistakeCategory: 'Calculation Error',
  ),
  MistakeRecord(
    id: 'm3',
    questionId: 'q310',
    questionText: 'Which of the following is a scalar quantity?',
    options: ['Velocity', 'Force', 'Momentum', 'Speed'],
    correctAnswerIndex: 3,
    userSelectedAnswerIndex: 0,
    explanation: 'Speed is a scalar quantity as it only has magnitude, not direction. Velocity, force, and momentum are vector quantities.',
    examName: 'RRB NTPC',
    subjectName: 'General Science',
    topicName: 'Physics',
    difficulty: 'Easy',
    sourceType: 'Daily Quiz',
    firstRecordedAt: DateTime.now().subtract(const Duration(days: 15)),
    lastRecordedAt: DateTime.now().subtract(const Duration(days: 1)),
    incorrectAttemptCount: 2,
    isResolved: true,
  ),
  MistakeRecord(
    id: 'm4',
    questionId: 'q412',
    questionText: 'The Battle of Plassey was fought in the year:',
    options: ['1757', '1764', '1857', '1707'],
    correctAnswerIndex: 0,
    userSelectedAnswerIndex: 1,
    explanation: 'The Battle of Plassey was a decisive victory of the British East India Company over the Nawab of Bengal and his French allies on 23 June 1757.',
    examName: 'UPSC CSE',
    subjectName: 'History',
    topicName: 'Modern India',
    difficulty: 'Medium',
    sourceType: 'Question Bank',
    firstRecordedAt: DateTime.now().subtract(const Duration(days: 20)),
    lastRecordedAt: DateTime.now().subtract(const Duration(days: 20)),
    incorrectAttemptCount: 1,
    isResolved: false,
    mistakeCategory: 'Memory Gap',
    personalNote: 'I always confuse Plassey (1757) with Buxar (1764).',
  ),
];
