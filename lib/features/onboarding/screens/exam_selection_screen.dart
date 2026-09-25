import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glow_button.dart';

class ExamSelectionScreen extends StatefulWidget {
  final String language;
  final String categoryId;
  final String categoryName;

  const ExamSelectionScreen({
    super.key,
    required this.language,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ExamSelectionScreen> createState() => _ExamSelectionScreenState();
}

class _ExamSelectionScreenState extends State<ExamSelectionScreen> {
  List<dynamic> _exams = [];
  bool _isLoading = true;
  String? _selectedExamId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    try {
      final response = await Supabase.instance.client
          .from('exams')
          .select()
          .eq('category_id', widget.categoryId);
      setState(() {
        _exams = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading exams. Please try again.')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSelection() async {
    if (_selectedExamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exam to continue.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'preferred_language': widget.language,
          'selected_exam_id': _selectedExamId,
        }).eq('id', user.id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding complete!')),
        );
        // This takes them to SplashWrapper which then redirects to Home
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving selection. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.categoryName + ' Exams', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
              : _exams.isEmpty
                  ? const Center(child: Text('No exams found.', style: TextStyle(color: Colors.white)))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _exams.length,
                            itemBuilder: (context, index) {
                              final exam = _exams[index];
                              final isSelected = _selectedExamId == exam['id'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedExamId = exam['id'];
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(24),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.all(20),
                                    opacity: isSelected ? 0.25 : 0.1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                exam['name'],
                                                style: TextStyle(
                                                  color: isSelected ? Colors.cyanAccent : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                exam['description'] ?? '',
                                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check_circle, color: Colors.cyanAccent),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: GlowButton(
                            text: 'Continue',
                            onPressed: _saveSelection,
                            isLoading: _isSaving,
                            glowColor: Colors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

