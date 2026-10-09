import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../practice/domain/practice_question.dart';
import '../../../home/screens/main_layout_screen.dart'; // Just to show it might be integrated

class QuestionBankScreen extends ConsumerStatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  ConsumerState<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends ConsumerState<QuestionBankScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  
  bool _isLoading = true;
  List<PracticeQuestion> _questions = [];
  
  // Filter States
  String? _selectedSubject;
  String? _selectedDifficulty;
  final Set<String> _bookmarkedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  Future<void> _fetchQuestions() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
      // Use existing mockPracticeQuestions, duplicate them a bit to simulate a larger bank
      _questions = List.generate(50, (index) {
        final base = mockPracticeQuestions[index % mockPracticeQuestions.length];
        return PracticeQuestion(
          id: '${base.id}_$index',
          subject: base.subject,
          topic: base.topic,
          difficulty: base.difficulty,
          questionText: base.questionText,
          options: base.options,
          correctOptionIndex: base.correctOptionIndex,
          explanation: base.explanation,
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark updated', style: TextStyle(color: Color(0xFF0F0F11))), backgroundColor: Color(0xFFFFFFFF)),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 24),
                const Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Indian Polity', 'Geography', 'Economy', 'History'].map((subject) {
                    final isSelected = _selectedSubject == subject;
                    return ChoiceChip(
                      label: Text(subject),
                      selected: isSelected,
                      selectedColor: const Color(0xFFE4DBF6),
                      backgroundColor: const Color(0xFFF3F4F6),
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedSubject = selected ? subject : null;
                        });
                        setState(() {
                          _selectedSubject = selected ? subject : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Easy', 'Medium', 'Hard'].map((diff) {
                    final isSelected = _selectedDifficulty == diff;
                    return ChoiceChip(
                      label: Text(diff),
                      selected: isSelected,
                      selectedColor: const Color(0xFFE4DBF6),
                      backgroundColor: const Color(0xFFF3F4F6),
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedDifficulty = selected ? diff : null;
                        });
                        setState(() {
                          _selectedDifficulty = selected ? diff : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedSubject = null;
                            _selectedDifficulty = null;
                          });
                          setState(() {
                            _selectedSubject = null;
                            _selectedDifficulty = null;
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF0F0F11)),
                          foregroundColor: const Color(0xFF0F0F11),
                        ),
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF0F0F11),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PracticeQuestion> get _filteredQuestions {
    return _questions.where((q) {
      final matchesSearch = _searchQuery.isEmpty || q.questionText.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSubject = _selectedSubject == null || q.subject == _selectedSubject;
      final matchesDifficulty = _selectedDifficulty == null || q.difficulty == _selectedDifficulty;
      return matchesSearch && matchesSubject && matchesDifficulty;
    }).toList();
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
          onPressed: () => context.pop(), // Pop assuming we reached here from Dashboard or somewhere
        ),
        title: const Text('Question Bank', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            if (_selectedSubject != null || _selectedDifficulty != null) _buildActiveFilters(),
            Expanded(
              child: _isLoading ? _buildLoading() : _buildQuestionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search questions...',
                hintStyle: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0F0F11)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _showFilters,
            icon: const Icon(Icons.tune, color: Color(0xFF0F0F11)),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedSubject != null) _buildFilterChip(_selectedSubject!, () => setState(() => _selectedSubject = null)),
            if (_selectedDifficulty != null) _buildFilterChip(_selectedDifficulty!, () => setState(() => _selectedDifficulty = null)),
            TextButton(
              onPressed: () => setState(() {
                _selectedSubject = null;
                _selectedDifficulty = null;
              }),
              child: const Text('Clear All', style: TextStyle(color: Color(0xFF0F0F11))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        backgroundColor: const Color(0xFFE4DBF6),
        deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF0F0F11)),
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    final filtered = _filteredQuestions;
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('No questions found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('Try changing your filters or search term.', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedSubject = null;
                  _selectedDifficulty = null;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Text(
            '${filtered.length} ${filtered.length == 1 ? 'question' : 'questions'} found',
            style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final q = filtered[index];
              final isBookmarked = _bookmarkedIds.contains(q.id);
              return _buildQuestionCard(q, isBookmarked);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(PracticeQuestion question, bool isBookmarked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/question-bank/${question.id}'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${question.subject} • ${question.topic}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
                    ),
                    IconButton(
                      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFF0F0F11), size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _toggleBookmark(question.id),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F0F11), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                      child: Text(question.difficulty, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE4DBF6).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(6)),
                      child: const Text('English', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    ),
                    const Spacer(),
                    const Text('View', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF0F0F11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
