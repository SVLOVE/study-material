import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/mock_test.dart';

class MockTestResultsScreen extends ConsumerStatefulWidget {
  final String testId;
  
  const MockTestResultsScreen({
    super.key,
    required this.testId,
  });

  @override
  ConsumerState<MockTestResultsScreen> createState() => _MockTestResultsScreenState();
}

class _MockTestResultsScreenState extends ConsumerState<MockTestResultsScreen> {
  bool _isLoading = true;
  MockTest? _test;
  
  // Simulated Result Data
  final int _totalQuestions = 100;
  final int _correct = 78;
  final int _incorrect = 14;
  final int _unanswered = 8;
  final String _timeUsed = '01:12:42';
  final String _avgTime = '43 sec';
  
  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate fetch
      final matches = mockCatalog.where((t) => t.id == widget.testId).toList();
      if (matches.isNotEmpty) {
        _test = matches.first;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _accuracy => _correct / (_correct + _incorrect) * 100;
  double get _scorePercentage => _correct / _totalQuestions * 100;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAE4F7),
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF0F0F11)))),
      );
    }

    if (_test == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAE4F7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(0xFF0F0F11)),
              const SizedBox(height: 16),
              const Text('Couldn\'t load your results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text('Your test was submitted, but we couldn\'t load the result details right now.', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadResults();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/mock-tests'),
                child: const Text('Back to Mock Tests', style: TextStyle(color: Color(0xFF0F0F11))),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F0F11)),
          onPressed: () => context.go('/mock-tests'),
        ),
        title: const Text('Mock Test Completed', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildScoreCard(),
                  const SizedBox(height: 24),
                  _buildQuickMetrics(),
                  const SizedBox(height: 32),
                  _buildTimePerformance(),
                  const SizedBox(height: 32),
                  _buildPerformanceMessage(),
                  const SizedBox(height: 32),
                  _buildSectionPerformance(),
                  const SizedBox(height: 32),
                  _buildTopicPerformance(),
                  const SizedBox(height: 32),
                  _buildStrengthsAndFocus(),
                  const SizedBox(height: 32),
                  _buildRecommendedActions(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _test!.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 8),
        Text(
          'Completed today', // Ideally from actual submission timestamp
          style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'YOUR SCORE',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            '${_scorePercentage.round()}%',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), height: 1),
          ),
          const SizedBox(height: 16),
          Text(
            '$_correct / $_totalQuestions',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE4DBF6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Accuracy: ${_accuracy.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetrics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 5;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth < 600 ? 1.5 : 1.2,
          children: [
            _buildMetricCard('Questions', '$_totalQuestions', const Color(0xFFF3F4F6)),
            _buildMetricCard('Attempted', '${_correct + _incorrect}', const Color(0xFFF3F4F6)),
            _buildMetricCard('Correct', '$_correct', const Color(0xFFE2F0D9)),
            _buildMetricCard('Incorrect', '$_incorrect', const Color(0xFFFDE8E8)), // Subtle red variant
            _buildMetricCard('Unanswered', '$_unanswered', const Color(0xFFF3F4F6)),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF0F0F11).withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Used', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                    const SizedBox(height: 8),
                    Text(_timeUsed, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Avg Time / Question', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                    const SizedBox(height: 8),
                    Text(_avgTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE4DBF6).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DBF6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights, color: Color(0xFF0F0F11)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Good attempt. Improving accuracy in a few weak areas can significantly raise your score.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F0F11).withValues(alpha: 0.8), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPerformance() {
    // Simulated section data
    final sections = [
      {'name': 'General Studies', 'score': 84},
      {'name': 'Aptitude', 'score': 76},
      {'name': 'Reasoning', 'score': 88},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: sections.map((s) {
              final score = s['score'] as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(s['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
                    ),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE4DBF6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 40,
                      child: Text('$score%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)), textAlign: TextAlign.right),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topic Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildTopicList('Strong Topics', const Color(0xFFE2F0D9), [
                    {'name': 'Indian Polity', 'score': '92%'},
                    {'name': 'Geography', 'score': '88%'},
                  ]),
                ),
                if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 16),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildTopicList('Needs Attention', const Color(0xFFFDF0D5), [
                    {'name': 'Economy', 'score': '61%'},
                    {'name': 'Current Affairs', 'score': '58%'},
                  ]),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopicList(String title, Color headerColor, List<Map<String, String>> topics) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: topics.map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F0F11))),
                      Text(t['score']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsAndFocus() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildListCard('What You Did Well', [
                '✓ Strong accuracy in Reasoning',
                '✓ Good performance in Indian Polity',
                '✓ High completion rate',
              ]),
            ),
            if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 16),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildListCard('Focus Next', [
                'Economy (61% accuracy)',
                'Current Affairs (58% accuracy)',
              ], action: 'Practice Weak Areas'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListCard(String title, List<String> items, {String? action}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          ...items.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!i.startsWith('✓')) const Padding(padding: EdgeInsets.only(top: 4, right: 8), child: Icon(Icons.circle, size: 8, color: Color(0xFF0F0F11))),
                Expanded(child: Text(i, style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.8), height: 1.4))),
              ],
            ),
          )),
          if (action != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/practice'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F0F11),
                side: const BorderSide(color: Color(0xFF0F0F11)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(action),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendedActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Next Steps',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: ElevatedButton(
                    onPressed: () => context.push('/mock-tests/review/${widget.testId}'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: const Color(0xFF0F0F11),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Review Answers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: OutlinedButton(
                    onPressed: () => context.go('/mock-tests'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      foregroundColor: const Color(0xFF0F0F11),
                      side: const BorderSide(color: Color(0xFF0F0F11)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Take Another Mock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
