class ReassessmentCandidate {
  final String id;
  final String topic;
  final String subject;
  final String exam;
  final double? previousAccuracy;
  final double? latestAccuracy;
  final String status; // 'Improved', 'Stable', 'Still Weak', 'Declined', 'Insufficient Data'
  final String reason;
  final DateTime? lastReviewedAt;
  final DateTime? lastReassessedAt;
  final String priority; // 'High', 'Medium', 'Low'

  ReassessmentCandidate({
    required this.id,
    required this.topic,
    required this.subject,
    required this.exam,
    this.previousAccuracy,
    this.latestAccuracy,
    required this.status,
    required this.reason,
    this.lastReviewedAt,
    this.lastReassessedAt,
    required this.priority,
  });

  double? get change {
    if (previousAccuracy != null && latestAccuracy != null) {
      return latestAccuracy! - previousAccuracy!;
    }
    return null;
  }
}

final List<ReassessmentCandidate> dummyReassessmentCandidates = [
  ReassessmentCandidate(
    id: 'c_1',
    topic: 'Indian Polity',
    subject: 'General Studies',
    exam: 'TNPSC Group 4',
    previousAccuracy: 52.0,
    latestAccuracy: 58.0,
    status: 'Still Weak',
    reason: 'Repeated mistakes detected.',
    priority: 'High',
    lastReviewedAt: DateTime.now().subtract(const Duration(days: 2)),
    lastReassessedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ReassessmentCandidate(
    id: 'c_2',
    topic: 'Modern History',
    subject: 'General Studies',
    exam: 'TNPSC Group 4',
    previousAccuracy: 65.0,
    latestAccuracy: 49.0,
    status: 'Declined',
    reason: 'Recent performance has declined.',
    priority: 'High',
    lastReviewedAt: DateTime.now().subtract(const Duration(days: 7)),
    lastReassessedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ReassessmentCandidate(
    id: 'c_3',
    topic: 'Number Systems',
    subject: 'Aptitude',
    exam: 'TNPSC Group 4',
    previousAccuracy: null,
    latestAccuracy: 45.0,
    status: 'Insufficient Data',
    reason: 'More practice is needed before a reliable comparison can be made.',
    priority: 'Low',
  ),
  ReassessmentCandidate(
    id: 'c_4',
    topic: 'General Science',
    subject: 'General Studies',
    exam: 'TNPSC Group 4',
    previousAccuracy: 64.0,
    latestAccuracy: 76.0,
    status: 'Improved',
    reason: 'Topic has improved successfully.',
    priority: 'Low',
  ),
  ReassessmentCandidate(
    id: 'c_5',
    topic: 'Reasoning',
    subject: 'Aptitude',
    exam: 'TNPSC Group 4',
    previousAccuracy: 78.0,
    latestAccuracy: 79.0,
    status: 'Stable',
    reason: 'Performance is stable.',
    priority: 'Medium',
  ),
];
