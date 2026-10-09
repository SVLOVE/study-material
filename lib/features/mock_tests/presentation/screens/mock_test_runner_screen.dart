import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../practice/domain/practice_question.dart'; // Reuse question model for now
import '../../domain/mock_test.dart';

enum TestRunnerState { loading, active, submitting, submitted, error }
enum QuestionStatus { unvisited, visited, answered, markedForReview }

class MockTestRunnerScreen extends ConsumerStatefulWidget {
  final String testId;
  const MockTestRunnerScreen({super.key, required this.testId});

  @override
  ConsumerState<MockTestRunnerScreen> createState() => _MockTestRunnerScreenState();
}

class _MockTestRunnerScreenState extends ConsumerState<MockTestRunnerScreen> {
  TestRunnerState _state = TestRunnerState.loading;
  MockTest? _test;
  List<PracticeQuestion> _questions = [];
  
  int _currentIndex = 0;
  Map<int, int> _answers = {};
  Map<int, QuestionStatus> _statuses = {};
  
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initTest();
  }

  Future<void> _initTest() async {
    try {
      // Simulate network delay and test fetch
      await Future.delayed(const Duration(seconds: 1));
      
      final matches = mockCatalog.where((t) => t.id == widget.testId).toList();
      if (matches.isEmpty) throw Exception('Test not found');
      
      _test = matches.first;
      
      // In a real app, fetch questions for this test. Reusing mockPracticeQuestions.
      // We will clone them to meet the questionCount if needed, just for UI simulation.
      _questions = List.generate(_test!.questionCount, (index) {
        final base = mockPracticeQuestions[index % mockPracticeQuestions.length];
        return PracticeQuestion(
          id: '${base.id}_$index',
          subject: base.subject,
          topic: base.topic,
          difficulty: base.difficulty,
          questionText: 'Q${index + 1}: ${base.questionText}',
          options: base.options,
          correctOptionIndex: base.correctOptionIndex,
          explanation: base.explanation,
        );
      });
      
      // Initialize statuses
      for (int i = 0; i < _questions.length; i++) {
        _statuses[i] = QuestionStatus.unvisited;
      }
      _statuses[0] = QuestionStatus.visited;
      
      _remainingSeconds = _test!.durationMinutes * 60;
      
      if (mounted) {
        setState(() => _state = TestRunnerState.active);
        _startTimer();
      }
    } catch (e) {
      if (mounted) setState(() => _state = TestRunnerState.error);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _state != TestRunnerState.active) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _autoSubmit();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _autoSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time is up. Your test has been submitted automatically.')),
    );
    _performSubmission();
  }

  void _performSubmission() async {
    setState(() => _state = TestRunnerState.submitting);
    
    // Simulate submission API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      if (context.canPop()) {
        context.pushReplacement('/mock-tests/results/${widget.testId}');
      } else {
        context.go('/mock-tests/results/${widget.testId}');
      }
    }
  }
  
  void _selectAnswer(int optionIndex) {
    setState(() {
      _answers[_currentIndex] = optionIndex;
      _statuses[_currentIndex] = QuestionStatus.answered;
    });
    // In a real app, trigger a debounced save to backend here.
  }

  void _clearResponse() {
    setState(() {
      _answers.remove(_currentIndex);
      _statuses[_currentIndex] = QuestionStatus.visited;
    });
  }

  void _toggleReview() {
    setState(() {
      final current = _statuses[_currentIndex] ?? QuestionStatus.visited;
      if (current == QuestionStatus.markedForReview) {
        _statuses[_currentIndex] = _answers.containsKey(_currentIndex) ? QuestionStatus.answered : QuestionStatus.visited;
      } else {
        _statuses[_currentIndex] = QuestionStatus.markedForReview;
      }
    });
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentIndex = index;
      if ((_statuses[index] ?? QuestionStatus.unvisited) == QuestionStatus.unvisited) {
        _statuses[index] = QuestionStatus.visited;
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_state == TestRunnerState.active) {
      final exit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Leave Test?', style: TextStyle(color: Color(0xFF0F0F11))),
          content: const Text('Your progress may be saved, but leaving the test will end this session depending on the test rules.', style: TextStyle(color: Color(0xFF0F0F11))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continue Test', style: TextStyle(color: Color(0xFF0F0F11))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
              child: const Text('Leave Test'),
            ),
          ],
        ),
      );
      return exit ?? false;
    }
    return true;
  }

  void _showSubmitConfirmation() {
    final answered = _answers.length;
    final unanswered = _questions.length - answered;
    final reviewed = _statuses.values.where((s) => s == QuestionStatus.markedForReview).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Test Summary', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Total Questions', '${_questions.length}'),
            const SizedBox(height: 8),
            _buildDialogRow('Answered', '$answered'),
            const SizedBox(height: 8),
            _buildDialogRow('Unanswered', '$unanswered', color: unanswered > 0 ? Colors.red[700] : null),
            const SizedBox(height: 8),
            _buildDialogRow('Marked for Review', '$reviewed'),
            if (unanswered > 0) ...[
              const SizedBox(height: 16),
              Text(
                '$unanswered questions are unanswered. Are you sure you want to submit?',
                style: const TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
        actions: [
          if (unanswered > 0)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally route to first unanswered
                final idx = List.generate(_questions.length, (i) => i).firstWhere((i) => !_answers.containsKey(i), orElse: () => -1);
                if (idx != -1) _goToQuestion(idx);
              },
              child: const Text('Review Unanswered', style: TextStyle(color: Color(0xFF0F0F11))),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Test', style: TextStyle(color: Color(0xFF0F0F11))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSubmission();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
            child: const Text('Submit Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.7))),
        Text(value, style: TextStyle(color: color ?? const Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatTimer(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAE4F7),
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case TestRunnerState.loading:
        return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF0F0F11))));
      case TestRunnerState.error:
        return _buildErrorState();
      case TestRunnerState.active:
        return _buildActiveState();
      case TestRunnerState.submitting:
        return _buildSubmittingState();
      case TestRunnerState.submitted:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFF0F0F11)),
          const SizedBox(height: 16),
          const Text('Unable to start test', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('We couldn\'t start this test right now.', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() => _state = TestRunnerState.loading);
              _initTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          Text('Submitting your test...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
        ],
      ),
    );
  }



  Widget _buildActiveState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        
        return Column(
          children: [
            _buildTopBar(isMobile),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: _buildQuestionArea(),
                              ),
                            ),
                          ),
                        ),
                        _buildBottomControls(),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    Container(
                      width: 320,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        border: Border(left: BorderSide(color: Color(0xFFF3F4F6))),
                      ),
                      child: _buildQuestionPalette(),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(bool isMobile) {
    Color timerColor = const Color(0xFF0F0F11);
    if (_remainingSeconds <= 60) {
      timerColor = Colors.red[700]!;
    } else if (_remainingSeconds <= 600) {
      timerColor = Colors.orange[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFFFFFFFF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isMobile)
                  const Text('GovPrep AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
                if (!isMobile)
                  const SizedBox(width: 16),
                if (!isMobile)
                  Container(width: 1, height: 20, color: const Color(0xFFF3F4F6)),
                if (!isMobile)
                  const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _test!.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F0F11)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.grid_view, color: Color(0xFF0F0F11)),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.4,
                    maxChildSize: 0.9,
                    builder: (_, controller) => Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: _buildQuestionPalette(controller: controller),
                    ),
                  ),
                );
              },
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 18, color: timerColor),
                const SizedBox(width: 8),
                Text(
                  _formatTimer(_remainingSeconds),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: timerColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    final question = _questions[_currentIndex];
    final isMarkedForReview = _statuses[_currentIndex] == QuestionStatus.markedForReview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
            ),
            TextButton.icon(
              onPressed: _toggleReview,
              icon: Icon(isMarkedForReview ? Icons.star : Icons.star_border, color: const Color(0xFF0F0F11)),
              label: Text(
                isMarkedForReview ? 'Marked for Review' : 'Mark for Review',
                style: const TextStyle(color: Color(0xFF0F0F11)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0F0F11), height: 1.5),
        ),
        const SizedBox(height: 32),
        ...List.generate(question.options.length, (index) {
          final isSelected = _answers[_currentIndex] == index;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => _selectAnswer(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6), width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF0F0F11),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomControls() {
    final hasAnswer = _answers.containsKey(_currentIndex);
    final isLast = _currentIndex == _questions.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: const Color(0xFF0F0F11).withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              OutlinedButton(
                onPressed: _currentIndex > 0 ? () => _goToQuestion(_currentIndex - 1) : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F0F11),
                  side: BorderSide(color: _currentIndex > 0 ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Previous'),
              ),
              const SizedBox(width: 12),
              if (hasAnswer)
                TextButton(
                  onPressed: _clearResponse,
                  child: const Text('Clear Response', style: TextStyle(color: Color(0xFF0F0F11))),
                ),
            ],
          ),
          if (isLast)
            ElevatedButton(
              onPressed: _showSubmitConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F11),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Review & Submit'),
            )
          else
            ElevatedButton(
              onPressed: () => _goToQuestion(_currentIndex + 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F11),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Next'),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionPalette({ScrollController? controller}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Question Palette', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              _buildPaletteLegend(),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        Expanded(
          child: GridView.builder(
            controller: controller,
            padding: const EdgeInsets.all(24.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final status = _statuses[index] ?? QuestionStatus.unvisited;
              final isCurrent = index == _currentIndex;
              
              Color bgColor = const Color(0xFFFFFFFF);
              Color textColor = const Color(0xFF0F0F11);
              Color borderColor = const Color(0xFFF3F4F6);
              IconData? icon;
              Color? iconColor;

              switch (status) {
                case QuestionStatus.unvisited:
                  bgColor = const Color(0xFFFFFFFF);
                  borderColor = const Color(0xFFF3F4F6);
                  break;
                case QuestionStatus.visited:
                  bgColor = const Color(0xFFF3F4F6);
                  borderColor = const Color(0xFFF3F4F6);
                  break;
                case QuestionStatus.answered:
                  bgColor = const Color(0xFFE2F0D9);
                  borderColor = const Color(0xFFE2F0D9);
                  icon = Icons.check;
                  iconColor = Colors.green[800];
                  break;
                case QuestionStatus.markedForReview:
                  bgColor = const Color(0xFFFDF0D5);
                  borderColor = const Color(0xFFFDF0D5);
                  icon = Icons.star;
                  iconColor = Colors.orange[800];
                  break;
              }

              if (isCurrent) {
                borderColor = const Color(0xFF0F0F11);
              }

              return InkWell(
                onTap: () {
                  if (controller != null) Navigator.pop(context); // Close bottom sheet on mobile
                  _goToQuestion(index);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(color: textColor, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500),
                      ),
                      if (icon != null)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Icon(icon, size: 10, color: iconColor),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaletteLegend() {
    return Column(
      children: [
        Row(
          children: [
            _buildLegendItem('Not Visited', const Color(0xFFFFFFFF), const Color(0xFFF3F4F6)),
            const SizedBox(width: 16),
            _buildLegendItem('Visited', const Color(0xFFF3F4F6), const Color(0xFFF3F4F6)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildLegendItem('Answered', const Color(0xFFE2F0D9), const Color(0xFFE2F0D9), icon: Icons.check, iconColor: Colors.green[800]),
            const SizedBox(width: 16),
            _buildLegendItem('Review', const Color(0xFFFDF0D5), const Color(0xFFFDF0D5), icon: Icons.star, iconColor: Colors.orange[800]),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, Color border, {IconData? icon, Color? iconColor}) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: border),
            ),
            child: icon != null ? Icon(icon, size: 12, color: iconColor) : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: const Color(0xFF0F0F11).withValues(alpha: 0.8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
