import '../../domain/models/practice_session_integrity.dart';

class PracticeSessionIntegrityService {
  
  /// Validates a practice session before finalizing it.
  Future<PracticeSessionIntegrity> validateSessionIntegrity({
    required String sessionId,
    required int expectedQuestions,
    required int deliveredQuestions,
    required int answeredQuestions,
  }) async {
    // Simulate backend verification
    await Future.delayed(const Duration(milliseconds: 500));
    
    final int unansweredCount = deliveredQuestions - answeredQuestions;
    final bool questionSetConsistent = expectedQuestions >= deliveredQuestions;
    final bool attemptConsistent = answeredQuestions <= deliveredQuestions;
    
    String? issue;
    if (!questionSetConsistent) {
      issue = 'Delivered questions exceed expected questions.';
    } else if (!attemptConsistent) {
      issue = 'More answers recorded than delivered questions.';
    }

    return PracticeSessionIntegrity(
      sessionId: sessionId,
      status: issue == null ? 'Valid' : 'Inconsistent',
      expectedQuestionCount: expectedQuestions,
      deliveredQuestionCount: deliveredQuestions,
      answeredQuestionCount: answeredQuestions,
      unansweredQuestionCount: unansweredCount,
      questionSetConsistent: questionSetConsistent,
      attemptCountConsistent: attemptConsistent,
      submissionConsistent: true,
      integrityIssue: issue,
      validatedAt: DateTime.now(),
    );
  }

  /// Represents final authoritative submission to the backend.
  Future<bool> submitAuthoritativeSession({
    required String sessionId,
    required PracticeSessionIntegrity integrity,
  }) async {
    if (!integrity.isValid) {
      return false;
    }
    // Simulate backend successful submission
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

final practiceSessionIntegrityService = PracticeSessionIntegrityService();
