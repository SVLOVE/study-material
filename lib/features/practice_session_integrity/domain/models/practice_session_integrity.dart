class PracticeSessionIntegrity {
  final String sessionId;
  final String status;

  final int expectedQuestionCount;
  final int deliveredQuestionCount;
  final int answeredQuestionCount;
  final int unansweredQuestionCount;

  final bool questionSetConsistent;
  final bool attemptCountConsistent;
  final bool submissionConsistent;

  final DateTime? startedAt;
  final DateTime? submittedAt;
  final String? integrityIssue;
  final DateTime? validatedAt;

  const PracticeSessionIntegrity({
    required this.sessionId,
    required this.status,
    required this.expectedQuestionCount,
    required this.deliveredQuestionCount,
    required this.answeredQuestionCount,
    required this.unansweredQuestionCount,
    required this.questionSetConsistent,
    required this.attemptCountConsistent,
    required this.submissionConsistent,
    this.startedAt,
    this.submittedAt,
    this.integrityIssue,
    this.validatedAt,
  });

  bool get isValid => 
      questionSetConsistent && 
      attemptCountConsistent && 
      submissionConsistent && 
      integrityIssue == null;
}
