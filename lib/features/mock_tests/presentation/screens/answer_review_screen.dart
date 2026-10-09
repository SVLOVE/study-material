import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../practice/domain/practice_question.dart';
import '../../domain/mock_test.dart';

enum ReviewFilter { all, incorrect, correct, unanswered, marked }
enum QuestionAttemptStatus { correct, incorrect, unanswered }

class AnswerReviewScreen extends ConsumerStatefulWidget {
  final String testId;
  const AnswerReviewScreen({super.key, required this.testId});

  @override
  ConsumerState<AnswerReviewScreen> createState() => _AnswerReviewScreenState();
}

class _AnswerReviewScreenState extends ConsumerState<AnswerReviewScreen> {
  bool _isLoading = true;
  MockTest? _test;
  List<PracticeQuestion> _questions = [];
  
  // Simulated attempt data mapping index to user's selected option and review flag
  final Map<int, int?> _userAnswers = {};
  final Set<int> _markedForReview = {};
  
  ReviewFilter _selectedFilter = ReviewFilter.all;
  int _currentIndex = 0; // Index relative to the _filteredIndices list

  @override
  void initState() {
    super.initState();
    _loadAttempt();
  }

  Future<void> _loadAttempt() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Simulate fetch
      final matches = mockCatalog.where((t) => t.id == widget.testId).toList();
      if (matches.isNotEmpty) {
        _test = matches.first;
      } else {
        throw Exception('Test not found');
      }

      // Simulate a loaded attempt
      _questions = List.generate(20, (index) {
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

      // Populate fake answers to demonstrate all states
      for (int i = 0; i < _questions.length; i++) {
        if (i % 5 == 0) {
          _userAnswers[i] = null; // Unanswered
        } else if (i % 3 == 0) {
          _userAnswers[i] = (_questions[i].correctOptionIndex + 1) % _questions[i].options.length; // Incorrect
        } else {
          _userAnswers[i] = _questions[i].correctOptionIndex; // Correct
        }
        
        if (i % 7 == 0) {
          _markedForReview.add(i);
        }
      }

    } catch (e) {
      _test = null;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<int> get _filteredIndices {
    List<int> indices = [];
    for (int i = 0; i < _questions.length; i++) {
      bool matches = false;
      final q = _questions[i];
      final userAns = _userAnswers[i];
      final isCorrect = userAns == q.correctOptionIndex;
      final isUnanswered = userAns == null;
      final isMarked = _markedForReview.contains(i);

      switch (_selectedFilter) {
        case ReviewFilter.all:
          matches = true;
          break;
        case ReviewFilter.correct:
          matches = !isUnanswered && isCorrect;
          break;
        case ReviewFilter.incorrect:
          matches = !isUnanswered && !isCorrect;
          break;
        case ReviewFilter.unanswered:
          matches = isUnanswered;
          break;
        case ReviewFilter.marked:
          matches = isMarked;
          break;
      }

      if (matches) indices.add(i);
    }
    return indices;
  }

  void _onFilterChanged(ReviewFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _currentIndex = 0; // Reset to first item of new filter
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _goToNext() {
    if (_currentIndex < _filteredIndices.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAE4F7),
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF0F0F11)))),
      );
    }

    if (_test == null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAE4F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(0xFF0F0F11)),
              const SizedBox(height: 16),
              const Text('Couldn\'t load this attempt', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
                child: const Text('Back to Results'),
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text('Review Answers', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_test!.title, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6), fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;
            return Column(
              children: [
                _buildFilterBar(isMobile),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMobile)
                        Container(
                          width: 320,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            border: Border(right: BorderSide(color: Color(0xFFF3F4F6))),
                          ),
                          child: _buildQuestionPalette(),
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 800),
                                    child: _buildMainContent(),
                                  ),
                                ),
                              ),
                            ),
                            _buildBottomControls(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool isMobile) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', ReviewFilter.all),
                  _buildFilterChip('Incorrect', ReviewFilter.incorrect),
                  _buildFilterChip('Correct', ReviewFilter.correct),
                  _buildFilterChip('Unanswered', ReviewFilter.unanswered),
                  _buildFilterChip('Marked', ReviewFilter.marked),
                ],
              ),
            ),
          ),
          if (isMobile) ...[
            const SizedBox(width: 12),
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
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ReviewFilter filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFFE4DBF6),
        backgroundColor: const Color(0xFFF3F4F6),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.6),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        onSelected: (selected) {
          if (selected) _onFilterChanged(filter);
        },
      ),
    );
  }

  Widget _buildQuestionPalette({ScrollController? controller}) {
    final filtered = _filteredIndices;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showing ${filtered.length} ${filtered.length == 1 ? 'question' : 'questions'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              ),
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
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final absoluteIndex = filtered[index];
              final isCurrent = index == _currentIndex;
              
              final q = _questions[absoluteIndex];
              final userAns = _userAnswers[absoluteIndex];
              final isCorrect = userAns == q.correctOptionIndex;
              final isUnanswered = userAns == null;
              final isMarked = _markedForReview.contains(absoluteIndex);
              
              Color bgColor = const Color(0xFFFFFFFF);
              Color textColor = const Color(0xFF0F0F11);
              Color borderColor = const Color(0xFFF3F4F6);
              IconData? icon;
              Color? iconColor;

              if (isUnanswered) {
                bgColor = const Color(0xFFF3F4F6);
                borderColor = const Color(0xFFF3F4F6);
              } else if (isCorrect) {
                bgColor = const Color(0xFFE2F0D9);
                borderColor = const Color(0xFFE2F0D9);
                icon = Icons.check;
                iconColor = Colors.green[800];
              } else {
                bgColor = const Color(0xFFFDE8E8);
                borderColor = const Color(0xFFFDE8E8);
                icon = Icons.close;
                iconColor = Colors.red[800];
              }

              if (isCurrent) {
                borderColor = const Color(0xFF0F0F11);
              }

              return InkWell(
                onTap: () {
                  if (controller != null) Navigator.pop(context); // Close bottom sheet on mobile
                  setState(() {
                    _currentIndex = index;
                  });
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
                        '${absoluteIndex + 1}',
                        style: TextStyle(color: textColor, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500),
                      ),
                      if (isMarked)
                        Positioned(
                          left: 2,
                          top: 2,
                          child: Icon(Icons.star, size: 8, color: Colors.orange[800]),
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
            _buildLegendItem('Correct', const Color(0xFFE2F0D9), const Color(0xFFE2F0D9), icon: Icons.check, iconColor: Colors.green[800]),
            const SizedBox(width: 16),
            _buildLegendItem('Incorrect', const Color(0xFFFDE8E8), const Color(0xFFFDE8E8), icon: Icons.close, iconColor: Colors.red[800]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildLegendItem('Unanswered', const Color(0xFFF3F4F6), const Color(0xFFF3F4F6)),
            const SizedBox(width: 16),
            _buildLegendItem('Marked', const Color(0xFFFFFFFF), const Color(0xFFF3F4F6), icon: Icons.star, iconColor: Colors.orange[800]),
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

  Widget _buildMainContent() {
    final filtered = _filteredIndices;
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    final absoluteIndex = filtered[_currentIndex];
    final question = _questions[absoluteIndex];
    final userAns = _userAnswers[absoluteIndex];
    final isCorrect = userAns == question.correctOptionIndex;
    final isUnanswered = userAns == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(absoluteIndex, question),
        const SizedBox(height: 24),
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0F0F11), height: 1.5),
        ),
        const SizedBox(height: 32),
        ...List.generate(question.options.length, (index) {
          final isUserChoice = userAns == index;
          final isCorrectChoice = question.correctOptionIndex == index;
          
          Color bgColor = const Color(0xFFFFFFFF);
          Color borderColor = const Color(0xFFF3F4F6);
          IconData icon = Icons.radio_button_unchecked;
          Color iconColor = const Color(0xFF0F0F11).withValues(alpha: 0.3);
          String? labelText;
          Color? labelColor;

          if (isCorrectChoice) {
            bgColor = const Color(0xFFE2F0D9);
            borderColor = const Color(0xFFE2F0D9);
            icon = Icons.check_circle;
            iconColor = Colors.green[800]!;
            labelText = 'Correct Answer';
            labelColor = Colors.green[800];
          } else if (isUserChoice) {
            bgColor = const Color(0xFFFDE8E8);
            borderColor = const Color(0xFFFDE8E8);
            icon = Icons.cancel;
            iconColor = Colors.red[800]!;
            labelText = 'Your Answer';
            labelColor = Colors.red[800];
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (labelText != null) ...[
                          Text(
                            labelText,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: labelColor),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          question.options[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF0F0F11),
                            fontWeight: isUserChoice || isCorrectChoice ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
        _buildComparisonCard(isUnanswered, isCorrect),
        const SizedBox(height: 32),
        _buildExplanation(question),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message = '';
    switch (_selectedFilter) {
      case ReviewFilter.incorrect:
        message = 'Great work — there are no incorrect answers in this attempt.';
        break;
      case ReviewFilter.unanswered:
        message = 'You answered every question.';
        break;
      case ReviewFilter.marked:
        message = 'You didn\'t mark any questions for review.';
        break;
      case ReviewFilter.correct:
        message = 'There are no correct answers in this attempt.';
        break;
      default:
        message = 'No questions found for this filter.';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 64, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(fontSize: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.8)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildQuestionHeader(int absoluteIndex, PracticeQuestion question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${absoluteIndex + 1}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 4),
            Text(
              '${question.subject} • ${question.topic}',
              style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.difficulty,
                style: TextStyle(fontSize: 11, color: const Color(0xFF0F0F11).withValues(alpha: 0.8), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _markedForReview.contains(absoluteIndex) ? Icons.bookmark : Icons.bookmark_border,
                color: const Color(0xFF0F0F11),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmarks persistence coming next.')));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(bool isUnanswered, bool isCorrect) {
    Color bgColor;
    IconData icon;
    Color iconColor;
    String title;
    
    if (isUnanswered) {
      bgColor = const Color(0xFFF3F4F6);
      icon = Icons.remove_circle_outline;
      iconColor = const Color(0xFF0F0F11).withValues(alpha: 0.6);
      title = 'Not answered';
    } else if (isCorrect) {
      bgColor = const Color(0xFFE2F0D9);
      icon = Icons.check_circle;
      iconColor = Colors.green[800]!;
      title = '✓ Correct';
    } else {
      bgColor = const Color(0xFFFDE8E8);
      icon = Icons.cancel;
      iconColor = Colors.red[800]!;
      title = '✕ Incorrect';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Text(
            isUnanswered ? title : 'Your answer was $title',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation(PracticeQuestion question) {
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
          const Text('Explanation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          Text(
            question.explanation,
            style: TextStyle(fontSize: 15, color: const Color(0xFF0F0F11).withValues(alpha: 0.8), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final filtered = _filteredIndices;
    if (filtered.isEmpty) return const SizedBox.shrink();

    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == filtered.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: const Color(0xFF0F0F11).withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: isFirst ? null : _goToPrevious,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              side: BorderSide(color: isFirst ? const Color(0xFFF3F4F6) : const Color(0xFF0F0F11)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('Previous'),
          ),
          Text(
            '${_currentIndex + 1} of ${filtered.length}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
          ),
          ElevatedButton(
            onPressed: isLast ? null : _goToNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              disabledBackgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
