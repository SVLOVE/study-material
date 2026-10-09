class RevisionQueueItem {
  final String id;
  final String title;
  final String exam;
  final String subject;
  final String topic;
  final String type; // 'Mistake', 'WeakTopic', 'Scheduled', 'Bookmark'
  final String priority; // 'High', 'Medium', 'Low'
  final String reason;
  final String sourcePath; // Route to execute
  final DateTime? lastReviewedAt;
  final DateTime? dueAt;

  RevisionQueueItem({
    required this.id,
    required this.title,
    required this.exam,
    required this.subject,
    required this.topic,
    required this.type,
    required this.priority,
    required this.reason,
    required this.sourcePath,
    this.lastReviewedAt,
    this.dueAt,
  });
}

// Dummy data for the presentation layer to represent the orchestration of the queue
final List<RevisionQueueItem> dummyRevisionQueue = [
  RevisionQueueItem(
    id: 'req_1',
    title: 'Fundamental Rights - Exceptions',
    exam: 'TNPSC Group 2',
    subject: 'Indian Polity',
    topic: 'Fundamental Rights',
    type: 'Mistake',
    priority: 'High',
    reason: 'Repeated mistake',
    sourcePath: '/mistakes/1', // Will open Mistake Detail
    lastReviewedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  RevisionQueueItem(
    id: 'req_2',
    title: 'Inflation & Deflation Concepts',
    exam: 'TNPSC Group 2',
    subject: 'Indian Economy',
    topic: 'Inflation',
    type: 'Scheduled',
    priority: 'High',
    reason: 'Overdue scheduled revision',
    sourcePath: '/practice',
    dueAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  RevisionQueueItem(
    id: 'req_3',
    title: 'Physics - Motion Equations',
    exam: 'TNPSC Group 2',
    subject: 'General Science',
    topic: 'Physics - Motion',
    type: 'WeakTopic',
    priority: 'Medium',
    reason: 'Low accuracy in recent practice',
    sourcePath: '/practice',
  ),
  RevisionQueueItem(
    id: 'req_4',
    title: 'Important Articles (1-51A)',
    exam: 'TNPSC Group 2',
    subject: 'Indian Polity',
    topic: 'Articles',
    type: 'Scheduled',
    priority: 'Medium',
    reason: 'Scheduled revision',
    sourcePath: '/practice',
    dueAt: DateTime.now(),
  ),
  RevisionQueueItem(
    id: 'req_5',
    title: 'Indus Valley Civilization Sites',
    exam: 'TNPSC Group 2',
    subject: 'History',
    topic: 'Ancient India',
    type: 'Bookmark',
    priority: 'Low',
    reason: 'Saved for later review',
    sourcePath: '/practice',
  ),
];
