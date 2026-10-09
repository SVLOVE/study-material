import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/exam_definition.dart';

class ExamDetailsScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamDetailsScreen({super.key, required this.examId});

  @override
  ConsumerState<ExamDetailsScreen> createState() => _ExamDetailsScreenState();
}

class _ExamDetailsScreenState extends ConsumerState<ExamDetailsScreen> {
  bool _isLoading = true;
  String? _targetExamId;
  ExamDefinition? _exam;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final matches = staticExams.where((e) => e.id == widget.examId).toList();
      if (matches.isNotEmpty) {
        _exam = matches.first;
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('selected_exam_id')
            .eq('id', user.id)
            .maybeSingle();

        if (profileResponse != null) {
          _targetExamId = profileResponse['selected_exam_id'];
        }
      }
    } catch (e) {
      _exam = null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setAsTargetExam() async {
    if (_exam == null) return;
    
    try {
      setState(() => _isLoading = true);
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'selected_exam_id': _exam!.id})
            .eq('id', user.id);
            
        setState(() {
          _targetExamId = _exam!.id;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target exam updated successfully'),
              backgroundColor: Color(0xFF0F0F11),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update target exam'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAE4F7),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
          ),
        ),
      );
    }

    if (_exam == null) {
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
              Icon(Icons.error_outline, size: 48, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text(
                'Exam not found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0F11),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The exam you\'re looking for is unavailable.',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F11),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to Exams'),
              ),
            ],
          ),
        ),
      );
    }

    final isTarget = _targetExamId == _exam!.id;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
              tooltip: 'Back to Exams',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home'); // Fallback
                }
              },
            ),
            title: const Text(
              'Back to Exams',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF0F0F11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildHeroSection(isTarget),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildOverview(),
                const SizedBox(height: 32),
                _buildQuickSummary(),
                const SizedBox(height: 32),
                _buildExamPattern(),
                const SizedBox(height: 32),
                _buildSubjects(),
                const SizedBox(height: 32),
                _buildSyllabus(),
                const SizedBox(height: 32),
                _buildPreparationOverview(isTarget),
                const SizedBox(height: 32),
                _buildRecommendedFocus(),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isTarget) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _exam!.categoryId.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _exam!.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (isTarget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4DBF6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Your Target Exam',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F0F11),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isTarget ? '2026' : 'Upcoming',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isTarget ? () => context.push('/practice') : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F0F11),
                      disabledBackgroundColor: const Color(0xFFF3F4F6),
                      disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue Preparation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (!isTarget) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _setAsTargetExam,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F0F11),
                        side: const BorderSide(color: Color(0xFF0F0F11)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Set as Target Exam',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this exam',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _exam!.description,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              title: 'Subjects',
              value: '${_exam!.subjects.length}',
              width: isMobile ? (constraints.maxWidth - 16) / 2 : 160,
            ),
            _buildSummaryCard(
              title: 'Questions',
              value: '—',
              width: isMobile ? (constraints.maxWidth - 16) / 2 : 160,
            ),
            _buildSummaryCard(
              title: 'Duration',
              value: '—',
              width: isMobile ? (constraints.maxWidth - 16) / 2 : 160,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamPattern() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exam Pattern',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Text(
            'Exam pattern details will be available here once verified exam data is connected.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subjects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _exam!.subjects.length,
              itemBuilder: (context, index) {
                final subject = _exam!.subjects[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F0F11),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Build your core concepts',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF0F0F11).withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: null, // Routing to subject details not available
                        child: const Text('Explore'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSyllabus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Syllabus Preview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F0F11),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/syllabus'),
              child: const Text('View Full Syllabus'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: _exam!.subjects.map((subject) {
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F0F11),
                    ),
                  ),
                  iconColor: const Color(0xFF0F0F11),
                  collapsedIconColor: const Color(0xFF0F0F11).withValues(alpha: 0.5),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Detailed syllabus will appear here once the verified syllabus data is connected.',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationOverview(bool isTarget) {
    if (!isTarget) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Preparation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start practicing to build your preparation progress.',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.push('/practice'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F0F11),
                    side: const BorderSide(color: Color(0xFF0F0F11)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Start Practice'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedFocus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Focus',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF0D5).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDF0D5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_outlined, size: 24, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Personalized focus recommendations will appear after you complete some practice sessions.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
