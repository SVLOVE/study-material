import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/practice_question.dart';
import '../../../reports/presentation/widgets/report_content_sheet.dart' as import_report;
import '../../../practice_session_integrity/application/services/practice_session_integrity_service.dart';

enum PracticeState { setup, active, submitting, result }

class PracticeArenaScreen extends ConsumerStatefulWidget {
  const PracticeArenaScreen({super.key});

  @override
  ConsumerState<PracticeArenaScreen> createState() => _PracticeArenaScreenState();
}

class _PracticeArenaScreenState extends ConsumerState<PracticeArenaScreen> {
  PracticeState _currentState = PracticeState.setup;
  
  // Setup State
  String? _targetExamName;
  bool _isLoadingTarget = true;
  String _selectedSubject = 'General Studies';
  String _selectedTopic = 'All Topics';
  String _selectedDifficulty = 'Mixed';
  int _selectedCount = 10;
  
  // Session State
  List<PracticeQuestion> _sessionQuestions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  
  // Results
  int _correctCount = 0;
  int _answeredCount = 0;
  String? _integrityIssue;

  @override
  void initState() {
    super.initState();
    _fetchTargetExam();
  }

  Future<void> _fetchTargetExam() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('selected_exam_id')
            .eq('id', user.id)
            .maybeSingle();

        if (profileResponse != null) {
          final examId = profileResponse['selected_exam_id'];
          if (examId != null) {
            final examResponse = await Supabase.instance.client
                .from('exams')
                .select('name')
                .eq('id', examId)
                .maybeSingle();
            
            if (examResponse != null) {
              _targetExamName = examResponse['name'];
            }
          }
        }
      }
    } catch (e) {
      // Graceful fallback
    } finally {
      if (mounted) {
        setState(() => _isLoadingTarget = false);
      }
    }
  }

  void _startPractice() {
    // In a real app, this would fetch filtered questions from Supabase.
    // Here we use the static fallback mock data.
    setState(() {
      _sessionQuestions = List.from(mockPracticeQuestions);
      _sessionQuestions.shuffle();
      if (_sessionQuestions.length > _selectedCount) {
        _sessionQuestions = _sessionQuestions.sublist(0, _selectedCount);
      }
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _isAnswerChecked = false;
      _correctCount = 0;
      _answeredCount = 0;
      _integrityIssue = null;
      _currentState = PracticeState.active;
    });
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null) return;
    
    setState(() {
      _isAnswerChecked = true;
      _answeredCount++;
      if (_selectedOptionIndex == _sessionQuestions[_currentQuestionIndex].correctOptionIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _sessionQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerChecked = false;
      });
    } else {
      _submitSession();
    }
  }

  Future<void> _submitSession() async {
    setState(() {
      _currentState = PracticeState.submitting;
    });

    final integrity = await practiceSessionIntegrityService.validateSessionIntegrity(
      sessionId: 'practice-session-id',
      expectedQuestions: _selectedCount,
      deliveredQuestions: _sessionQuestions.length,
      answeredQuestions: _answeredCount,
    );

    if (integrity.isValid) {
      await practiceSessionIntegrityService.submitAuthoritativeSession(
        sessionId: 'practice-session-id',
        integrity: integrity,
      );
    }

    if (mounted) {
      setState(() {
        _integrityIssue = integrity.integrityIssue;
        _currentState = PracticeState.result;
      });
    }
  }
  
  Future<bool> _onWillPop() async {
    if (_currentState == PracticeState.active) {
      final exit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Exit practice?', style: TextStyle(color: Color(0xFF0F0F11))),
          content: const Text('Your current progress may be lost if you leave this session.', style: TextStyle(color: Color(0xFF0F0F11))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continue Practice', style: TextStyle(color: Color(0xFF0F0F11))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
              child: const Text('Exit'),
            ),
          ],
        ),
      );
      return exit ?? false;
    }
    
    if (_currentState == PracticeState.result) {
      setState(() => _currentState = PracticeState.setup);
      return false; // Don't pop the whole screen, just reset state
    }
    
    return true; // Setup state can pop normally
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentState == PracticeState.setup
            ? null // handled by shell if inside tabs, but if stand-alone, we provide back
            : IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF0F0F11)),
                onPressed: () async {
                  final pop = await _onWillPop();
                  if (pop && context.mounted) {
                    if (context.canPop()) context.pop();
                  }
                },
              ),
          title: Text(
            _currentState == PracticeState.setup ? 'Practice Arena' : 
            _currentState == PracticeState.active ? 'Question ${_currentQuestionIndex + 1} of ${_sessionQuestions.length}' :
            _currentState == PracticeState.submitting ? 'Submitting...' :
            'Practice Summary',
            style: const TextStyle(
              color: Color(0xFF0F0F11),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case PracticeState.setup:
        return _buildSetupState();
      case PracticeState.active:
        return _buildActiveState();
      case PracticeState.submitting:
        return _buildSubmittingState();
      case PracticeState.result:
        return _buildResultState();
    }
  }

  Widget _buildSubmittingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF0F0F11)),
          SizedBox(height: 24),
          Text(
            'Submitting your practice...',
            style: TextStyle(fontSize: 16, color: Color(0xFF0F0F11), fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Validating session integrity.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- SETUP STATE ---
  Widget _buildSetupState() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Practice at your pace, focus on your weak areas, and improve consistently.',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F0F11)),
              ),
              const SizedBox(height: 24),
              _buildTargetExamHeader(),
              const SizedBox(height: 24),
              _buildQuickOptions(),
              const SizedBox(height: 24),
              _buildFiltersCard(),
              const SizedBox(height: 48),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetExamHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE4DBF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.track_changes, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Exam',
                  style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoadingTarget ? 'Loading...' : (_targetExamName ?? 'Select a target exam to personalize your practice.'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOptions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildQuickCard(
              title: '10 Mixed Questions',
              subtitle: 'Quick 10-question session',
              icon: Icons.shuffle,
              color: const Color(0xFFE4DBF6),
              width: isMobile ? double.infinity : (constraints.maxWidth - 16) / 2,
              onTap: () {
                setState(() {
                  _selectedCount = 10;
                  _selectedDifficulty = 'Mixed';
                  _startPractice();
                });
              }
            ),
            _buildQuickCard(
              title: 'Weak Topics',
              subtitle: 'Practice areas where you need improvement',
              icon: Icons.trending_up,
              color: const Color(0xFFFDF0D5),
              width: isMobile ? double.infinity : (constraints.maxWidth - 16) / 2,
              onTap: null, // AI personalization not yet connected
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickCard({required String title, required String subtitle, required IconData icon, required Color color, required double width, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFF3F4F6) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF0F0F11), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: onTap == null ? const Color(0xFF0F0F11).withValues(alpha: 0.5) : const Color(0xFF0F0F11),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    onTap == null ? 'Coming soon' : subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose what you want to practice',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 24),
          _buildDropdown('Subject', _selectedSubject, ['General Studies', 'Aptitude', 'English'], (v) => setState(() => _selectedSubject = v!)),
          const SizedBox(height: 16),
          _buildDropdown('Topic', _selectedTopic, ['All Topics', 'Indian Polity', 'History', 'Time and Work'], (v) => setState(() => _selectedTopic = v!)),
          const SizedBox(height: 24),
          const Text('Difficulty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Easy', 'Medium', 'Hard', 'Mixed', 'Adaptive'].map((level) {
              final isSelected = _selectedDifficulty == level;
              return ChoiceChip(
                label: Text(level),
                selected: isSelected,
                selectedColor: const Color(0xFFE4DBF6),
                backgroundColor: const Color(0xFFF3F4F6),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedDifficulty = level);
                },
              );
            }).toList(),
          ),
          if (_selectedDifficulty == 'Adaptive') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Color(0xFF0F0F11)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Adaptive practice will be available once enough performance data is collected.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0F0F11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Question Count', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5, 10, 20, 30].map((count) {
              final isSelected = _selectedCount == count;
              return ChoiceChip(
                label: Text('$count'),
                selected: isSelected,
                selectedColor: const Color(0xFFE4DBF6),
                backgroundColor: const Color(0xFFF3F4F6),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCount = count);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _selectedDifficulty == 'Adaptive' ? null : _startPractice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F11),
                disabledBackgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Start Practice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0F0F11)),
            ),
          ),
        ),
      ],
    );
  }

  // --- ACTIVE STATE ---
  Widget _buildActiveState() {
    final question = _sessionQuestions[_currentQuestionIndex];
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _sessionQuestions.length,
          backgroundColor: const Color(0xFFF3F4F6),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${question.subject} • ${question.topic}',
                          style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6), fontWeight: FontWeight.w500),
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
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz, color: Color(0xFF0F0F11)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (value) {
                                if (value == 'bookmark') {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmarking not connected yet.')));
                                } else if (value == 'report') {
                                  import_report.ReportContentSheet.show(
                                    context,
                                    contentId: question.id,
                                    contentType: 'Question',
                                    contentTitle: question.questionText,
                                    contentMetadata: '${question.subject} • ${question.topic}',
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'bookmark',
                                  child: Row(
                                    children: [
                                      Icon(Icons.bookmark_border, size: 20),
                                      SizedBox(width: 12),
                                      Text('Bookmark'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Icon(Icons.flag_outlined, size: 20),
                                      SizedBox(width: 12),
                                      Text('Report Issue'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      question.questionText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0F0F11), height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(question.options.length, (index) {
                      final isSelected = _selectedOptionIndex == index;
                      final isCorrectOption = question.correctOptionIndex == index;
                      
                      Color bgColor = const Color(0xFFFFFFFF);
                      Color borderColor = const Color(0xFFF3F4F6);
                      IconData? trailingIcon;
                      Color? iconColor;

                      if (_isAnswerChecked) {
                        if (isCorrectOption) {
                          bgColor = const Color(0xFFE2F0D9);
                          borderColor = const Color(0xFFE2F0D9);
                          trailingIcon = Icons.check_circle;
                          iconColor = Colors.green[700];
                        } else if (isSelected) {
                          bgColor = const Color(0xFFFDE8E8);
                          borderColor = const Color(0xFFFDE8E8);
                          trailingIcon = Icons.cancel;
                          iconColor = Colors.red[700];
                        }
                      } else if (isSelected) {
                        bgColor = const Color(0xFFE4DBF6);
                        borderColor = const Color(0xFFE4DBF6);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: _isAnswerChecked ? null : () {
                            setState(() {
                              _selectedOptionIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAnswerChecked 
                                    ? (isCorrectOption ? Icons.radio_button_checked : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked))
                                    : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                                  color: isSelected || (_isAnswerChecked && isCorrectOption) ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.3),
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
                                if (trailingIcon != null) Icon(trailingIcon, color: iconColor),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    if (_isAnswerChecked) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Explanation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                            const SizedBox(height: 8),
                            Text(
                              question.explanation,
                              style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.8), height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _selectedOptionIndex == null ? null : (_isAnswerChecked ? _nextQuestion : _checkAnswer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F0F11),
                          disabledBackgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          !_isAnswerChecked ? 'Check Answer' : (_currentQuestionIndex == _sessionQuestions.length - 1 ? 'Finish Practice' : 'Next Question'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- RESULT STATE ---
  Widget _buildResultState() {
    final accuracy = _sessionQuestions.isEmpty ? 0 : ((_correctCount / _sessionQuestions.length) * 100).round();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Color(0xFFFDF0D5)),
              const SizedBox(height: 16),
              const Text(
                'Practice Complete 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              ),
              const SizedBox(height: 8),
              Text(
                'Great job! Keep practicing to improve your score.',
                style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
              ),
              if (_integrityIssue != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0D5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Integrity Note: $_integrityIssue',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildResultCard('Score', '$_correctCount/${_sessionQuestions.length}', Icons.check_circle_outline, const Color(0xFFE2F0D9)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildResultCard('Accuracy', '$accuracy%', Icons.pie_chart_outline, const Color(0xFFE4DBF6)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Performance Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.thumb_up_outlined, size: 20, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('What you did well', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                              const SizedBox(height: 4),
                              Text('Complete more practice sessions to receive personalized insights.', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF3F4F6)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.ads_click, size: 20, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Focus next', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                              const SizedBox(height: 4),
                              Text('Complete more practice sessions to receive personalized insights.', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentState = PracticeState.setup;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Practice Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F0F11),
                    side: const BorderSide(color: Color(0xFF0F0F11)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: const Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        ],
      ),
    );
  }
}
