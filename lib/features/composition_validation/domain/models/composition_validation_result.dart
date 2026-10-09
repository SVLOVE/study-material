class CompositionAdjustment {
  final String type;
  final String reason;
  final String? previousValue;
  final String? newValue;

  CompositionAdjustment({
    required this.type,
    required this.reason,
    this.previousValue,
    this.newValue,
  });
}

class CompositionCoverageItem {
  final String attribute;
  final String status; // 'Complete', 'Partial', 'Mismatch', 'InsufficientEvidence', 'NotApplicable'
  final String details;

  CompositionCoverageItem({
    required this.attribute,
    required this.status,
    required this.details,
  });
}

class CompositionValidationResult {
  final String status; // 'FullyAvailable', 'PartiallyAvailable', 'Unavailable', 'Adjusted', 'InsufficientData', 'ValidationError'

  final int requestedQuestionCount;
  final int availableQuestionCount;
  final int deliveredQuestionCount;

  final String? requestedLanguage;
  final String? deliveredLanguage;

  final String? requestedDifficulty;
  final String? deliveredDifficulty;

  final bool topicScopeSatisfied;
  final bool examScopeSatisfied;
  final bool duplicateFree;

  final List<CompositionAdjustment> adjustments;
  final List<CompositionCoverageItem> coverage;

  final String? explanation;
  final DateTime? validatedAt;

  CompositionValidationResult({
    required this.status,
    required this.requestedQuestionCount,
    required this.availableQuestionCount,
    required this.deliveredQuestionCount,
    this.requestedLanguage,
    this.deliveredLanguage,
    this.requestedDifficulty,
    this.deliveredDifficulty,
    required this.topicScopeSatisfied,
    required this.examScopeSatisfied,
    required this.duplicateFree,
    required this.adjustments,
    required this.coverage,
    this.explanation,
    this.validatedAt,
  });
}

// Dummy object for Phase 66 UI dev
final CompositionValidationResult dummyValidationResult = CompositionValidationResult(
  status: 'Adjusted',
  requestedQuestionCount: 15,
  availableQuestionCount: 12,
  deliveredQuestionCount: 12,
  requestedLanguage: 'English',
  deliveredLanguage: 'English',
  requestedDifficulty: 'Medium',
  deliveredDifficulty: 'Medium',
  topicScopeSatisfied: true,
  examScopeSatisfied: true,
  duplicateFree: true,
  explanation: '12 eligible questions were available, so this practice contains 12 questions.',
  adjustments: [
    CompositionAdjustment(
      type: 'QUESTION_COUNT_REDUCED',
      reason: 'Insufficient questions available for the selected topic and difficulty.',
      previousValue: '15',
      newValue: '12',
    ),
  ],
  coverage: [
    CompositionCoverageItem(
      attribute: 'Topic Coverage',
      status: 'Complete',
      details: 'All requested topics are covered.',
    ),
    CompositionCoverageItem(
      attribute: 'Difficulty',
      status: 'Complete',
      details: 'Matched Medium difficulty.',
    ),
    CompositionCoverageItem(
      attribute: 'Question Count',
      status: 'Partial',
      details: '12 of 15 requested questions.',
    ),
  ],
  validatedAt: DateTime.now(),
);
