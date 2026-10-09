class PracticeQuestion {
  final String id;
  final String subject;
  final String topic;
  final String difficulty;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const PracticeQuestion({
    required this.id,
    required this.subject,
    required this.topic,
    required this.difficulty,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

// Static fallback data for development
final List<PracticeQuestion> mockPracticeQuestions = [
  const PracticeQuestion(
    id: 'q1',
    subject: 'General Studies',
    topic: 'Indian Polity',
    difficulty: 'Medium',
    questionText: 'Which article of the Indian Constitution deals with the Fundamental Duties of the citizens?',
    options: ['Article 50', 'Article 51A', 'Article 52', 'Article 54'],
    correctOptionIndex: 1,
    explanation: 'Article 51A of the Indian Constitution, inserted by the 42nd Amendment Act of 1976, deals with Fundamental Duties.',
  ),
  const PracticeQuestion(
    id: 'q2',
    subject: 'Aptitude',
    topic: 'Time and Work',
    difficulty: 'Easy',
    questionText: 'If A can do a piece of work in 10 days and B can do the same work in 15 days, how long will they take if they work together?',
    options: ['5 days', '6 days', '8 days', '12 days'],
    correctOptionIndex: 1,
    explanation: 'A\'s 1-day work = 1/10. B\'s 1-day work = 1/15. Together = 1/10 + 1/15 = 3/30 + 2/30 = 5/30 = 1/6. So they take 6 days.',
  ),
  const PracticeQuestion(
    id: 'q3',
    subject: 'General Studies',
    topic: 'History',
    difficulty: 'Hard',
    questionText: 'Who was the Viceroy of India during the Partition of Bengal in 1905?',
    options: ['Lord Minto', 'Lord Curzon', 'Lord Harding', 'Lord Chelmsford'],
    correctOptionIndex: 1,
    explanation: 'The Partition of Bengal (1905) was carried out by the British viceroy in India, Lord Curzon.',
  ),
];
