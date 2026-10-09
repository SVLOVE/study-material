import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/glow_button.dart';
import '../../domain/models/mistake_record.dart';

class MistakeDetailScreen extends StatefulWidget {
  final MistakeRecord mistake;

  const MistakeDetailScreen({super.key, required this.mistake});

  @override
  State<MistakeDetailScreen> createState() => _MistakeDetailScreenState();
}

class _MistakeDetailScreenState extends State<MistakeDetailScreen> {
  late MistakeRecord _mistake;
  final TextEditingController _noteController = TextEditingController();
  bool _isEditingNote = false;
  String? _selectedCategory;

  final List<String> _categories = [
    'Conceptual Error',
    'Calculation Error',
    'Misread Question',
    'Silly Mistake',
    'Memory Gap',
    'Time Pressure',
    'Guessing Error',
    'Topic Gap',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _mistake = widget.mistake;
    _noteController.text = _mistake.personalNote ?? '';
    _selectedCategory = _mistake.mistakeCategory;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveNote() {
    setState(() {
      _mistake = MistakeRecord(
        id: _mistake.id,
        questionId: _mistake.questionId,
        questionText: _mistake.questionText,
        options: _mistake.options,
        correctAnswerIndex: _mistake.correctAnswerIndex,
        userSelectedAnswerIndex: _mistake.userSelectedAnswerIndex,
        explanation: _mistake.explanation,
        examName: _mistake.examName,
        subjectName: _mistake.subjectName,
        topicName: _mistake.topicName,
        difficulty: _mistake.difficulty,
        sourceType: _mistake.sourceType,
        firstRecordedAt: _mistake.firstRecordedAt,
        lastRecordedAt: _mistake.lastRecordedAt,
        incorrectAttemptCount: _mistake.incorrectAttemptCount,
        isResolved: _mistake.isResolved,
        mistakeCategory: _selectedCategory,
        personalNote: _noteController.text,
      );
      _isEditingNote = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved successfully.')),
    );
  }

  void _toggleResolution() {
    setState(() {
      _mistake = MistakeRecord(
        id: _mistake.id,
        questionId: _mistake.questionId,
        questionText: _mistake.questionText,
        options: _mistake.options,
        correctAnswerIndex: _mistake.correctAnswerIndex,
        userSelectedAnswerIndex: _mistake.userSelectedAnswerIndex,
        explanation: _mistake.explanation,
        examName: _mistake.examName,
        subjectName: _mistake.subjectName,
        topicName: _mistake.topicName,
        difficulty: _mistake.difficulty,
        sourceType: _mistake.sourceType,
        firstRecordedAt: _mistake.firstRecordedAt,
        lastRecordedAt: _mistake.lastRecordedAt,
        incorrectAttemptCount: _mistake.incorrectAttemptCount,
        isResolved: !_mistake.isResolved,
        mistakeCategory: _mistake.mistakeCategory,
        personalNote: _mistake.personalNote,
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_mistake.isResolved ? 'Marked as Resolved' : 'Reopened for review')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mistake Detail',
          style: TextStyle(
            color: Color(0xFF0F0F11),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_mistake.isResolved ? Icons.check_circle : Icons.check_circle_outline, 
                       color: _mistake.isResolved ? Colors.green : const Color(0xFF0F0F11)),
            onPressed: _toggleResolution,
            tooltip: _mistake.isResolved ? 'Reopen' : 'Mark as Resolved',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExamContext(),
                  const SizedBox(height: 24),
                  _buildQuestionSection(),
                  const SizedBox(height: 24),
                  _buildMistakeAnalysis(),
                  const SizedBox(height: 24),
                  _buildPersonalNote(),
                  const SizedBox(height: 24),
                  _buildHistoryTimeline(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/topic-workspace', extra: _mistake.topicName);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0F0F11)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Open Topic', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlowButton(
                  text: 'Practice Again',
                  onPressed: () {
                    context.push('/practice-arena');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamContext() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTag(_mistake.examName, Icons.assignment),
        _buildTag(_mistake.subjectName, Icons.book),
        _buildTag(_mistake.topicName, Icons.segment),
        _buildTag(_mistake.difficulty, Icons.bar_chart),
      ],
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF555555)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection() {
    return GlassContainer(
      blur: 15,
      opacity: 0.9,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Question', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              _mistake.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            ),
            const SizedBox(height: 24),
            ...List.generate(_mistake.options.length, (index) {
              final isCorrect = index == _mistake.correctAnswerIndex;
              final isSelected = index == _mistake.userSelectedAnswerIndex;
              
              Color bgColor = Colors.transparent;
              Color borderColor = Colors.grey.shade300;
              Color textColor = const Color(0xFF0F0F11);
              IconData? icon;

              if (isCorrect) {
                bgColor = const Color(0xFFE2F0D9);
                borderColor = Colors.green;
                icon = Icons.check_circle;
              } else if (isSelected) {
                bgColor = const Color(0xFFFFEBEB);
                borderColor = Colors.red;
                icon = Icons.cancel;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _mistake.options[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: (isCorrect || isSelected) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (icon != null) Icon(icon, color: borderColor),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEAE4F7)),
            const SizedBox(height: 16),
            const Text('Explanation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 12),
            Text(
              _mistake.explanation,
              style: const TextStyle(fontSize: 15, color: Color(0xFF555555), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakeAnalysis() {
    return GlassContainer(
      blur: 15,
      opacity: 0.9,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why did I get this wrong?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                      _saveNote(); // Auto save category
                    });
                  },
                  selectedColor: const Color(0xFF0F0F11),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalNote() {
    return GlassContainer(
      blur: 15,
      opacity: 0.9,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('What should I remember next time?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                if (!_isEditingNote)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Color(0xFF0F0F11)),
                    onPressed: () {
                      setState(() {
                        _isEditingNote = true;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditingNote) ...[
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add a personal note to help you remember...',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditingNote = false;
                        _noteController.text = _mistake.personalNote ?? '';
                      });
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F0F11),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Note'),
                  ),
                ],
              ),
            ] else ...[
              if (_mistake.personalNote == null || _mistake.personalNote!.isEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditingNote = true;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: const Text(
                      'Tap to add a personal note...',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0D5).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDF0D5)),
                  ),
                  child: Text(
                    '"${_mistake.personalNote}"',
                    style: const TextStyle(fontSize: 15, color: Color(0xFF0F0F11), fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTimeline() {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    return GlassContainer(
      blur: 15,
      opacity: 0.9,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mistake History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 16),
            _buildTimelineItem(
              Icons.close,
              Colors.red,
              'Incorrect Attempt',
              dateFormat.format(_mistake.lastRecordedAt),
              'Source: ${_mistake.sourceType}',
            ),
            if (_mistake.incorrectAttemptCount > 1) ...[
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: SizedBox(height: 16, child: VerticalDivider(color: Colors.grey, thickness: 1)),
              ),
              _buildTimelineItem(
                Icons.repeat,
                Colors.orange,
                '${_mistake.incorrectAttemptCount - 1} Previous Incorrect Attempts',
                'Since ${DateFormat('MMM d, yyyy').format(_mistake.firstRecordedAt)}',
                null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(IconData icon, Color color, String title, String time, String? subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
