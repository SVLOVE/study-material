import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../practice/domain/practice_question.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  PracticeQuestion? _question;
  bool _isLoading = true;
  bool _isBookmarked = false; // Simulated local state

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // Extract original base id from generated mock ids like "id_index"
      final baseId = widget.questionId.split('_').first;
      final matches = mockPracticeQuestions.where((q) => q.id == baseId).toList();
      
      if (matches.isNotEmpty) {
        // Clone with requested ID to match what was clicked
        final base = matches.first;
        _question = PracticeQuestion(
          id: widget.questionId,
          subject: base.subject,
          topic: base.topic,
          difficulty: base.difficulty,
          questionText: base.questionText,
          options: base.options,
          correctOptionIndex: base.correctOptionIndex,
          explanation: base.explanation,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAE4F7),
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF0F0F11)))),
      );
    }

    if (_question == null) {
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
              const Text('Couldn\'t load this question', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
                child: const Text('Back'),
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
        title: const Text('Question Details', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFF0F0F11)),
            onPressed: _toggleBookmark,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetadataBar(),
                  const SizedBox(height: 32),
                  Text(
                    _question!.questionText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0F0F11), height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _buildOptions(),
                  const SizedBox(height: 32),
                  _buildExplanation(),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/practice'), // Simulate jump to practice
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: const Color(0xFF0F0F11),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Practice This', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataBar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildMetaChip('TNPSC', const Color(0xFFFFFFFF)),
        _buildMetaChip('2024', const Color(0xFFFFFFFF)),
        _buildMetaChip(_question!.subject, const Color(0xFFFFFFFF)),
        _buildMetaChip(_question!.topic, const Color(0xFFFFFFFF)),
        _buildMetaChip(_question!.difficulty, const Color(0xFFF3F4F6)),
        _buildMetaChip('English', const Color(0xFFE4DBF6).withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _buildMetaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: List.generate(_question!.options.length, (index) {
        final isCorrect = index == _question!.correctOptionIndex;
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isCorrect ? const Color(0xFFE2F0D9) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isCorrect ? const Color(0xFFE2F0D9) : const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.radio_button_unchecked, color: isCorrect ? Colors.green[800] : const Color(0xFF0F0F11).withValues(alpha: 0.3)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCorrect) ...[
                      Text('Correct Answer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[800])),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      _question!.options[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF0F0F11),
                        fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildExplanation() {
    return Container(
      width: double.infinity,
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
            _question!.explanation,
            style: TextStyle(fontSize: 15, color: const Color(0xFF0F0F11).withValues(alpha: 0.8), height: 1.5),
          ),
        ],
      ),
    );
  }
}
