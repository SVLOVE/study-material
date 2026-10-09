class MockTest {
  final String id;
  final String title;
  final String type; // Full Length, Sectional, Topic, Daily
  final String targetExamId;
  final int questionCount;
  final int durationMinutes;
  final String difficulty;
  final String status; // Not Attempted, In Progress, Completed
  final bool isDaily;

  const MockTest({
    required this.id,
    required this.title,
    required this.type,
    required this.targetExamId,
    required this.questionCount,
    required this.durationMinutes,
    required this.difficulty,
    this.status = 'Not Attempted',
    this.isDaily = false,
  });
}

// Static mock data for development
final List<MockTest> mockCatalog = [
  const MockTest(
    id: 'mt1',
    title: 'TNPSC Group 4 — Full Mock 01',
    type: 'Full Length',
    targetExamId: 'tnpsc_group4',
    questionCount: 200,
    durationMinutes: 180,
    difficulty: 'Mixed',
    status: 'Completed',
  ),
  const MockTest(
    id: 'mt2',
    title: 'General Studies Sectional 01',
    type: 'Sectional',
    targetExamId: 'tnpsc_group4',
    questionCount: 75,
    durationMinutes: 60,
    difficulty: 'Medium',
  ),
  const MockTest(
    id: 'mt3',
    title: 'Daily Assessment - Polity',
    type: 'Daily',
    targetExamId: 'tnpsc_group4',
    questionCount: 20,
    durationMinutes: 15,
    difficulty: 'Easy',
    isDaily: true,
  ),
  const MockTest(
    id: 'mt4',
    title: 'SSC CGL Tier 1 Mock 01',
    type: 'Full Length',
    targetExamId: 'ssc_cgl',
    questionCount: 100,
    durationMinutes: 60,
    difficulty: 'Hard',
  ),
];
