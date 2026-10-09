import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/exam_definition.dart';

class ExamHubScreen extends ConsumerStatefulWidget {
  const ExamHubScreen({super.key});

  @override
  ConsumerState<ExamHubScreen> createState() => _ExamHubScreenState();
}

class _ExamHubScreenState extends ConsumerState<ExamHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  String? _targetExamId;
  String? _targetExamName;
  bool _isLoadingTarget = true;

  @override
  void initState() {
    super.initState();
    _fetchTargetExam();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
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
            _targetExamId = examId;
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
      // Handle gracefully
    } finally {
      if (mounted) {
        setState(() => _isLoadingTarget = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExamDefinition> get _filteredExams {
    return staticExams.where((exam) {
      final matchesCategory = _selectedCategory == 'All' || exam.categoryId == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || 
                            exam.name.toLowerCase().contains(_searchQuery) ||
                            exam.description.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTargetExamCard(),
                const SizedBox(height: 32),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildCategoryFilters(),
                const SizedBox(height: 24),
                _buildExamCountAndList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Government Exams',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your exam, understand the syllabus, and start preparing with confidence.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      toolbarHeight: 100,
    );
  }

  Widget _buildTargetExamCard() {
    if (_isLoadingTarget) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
          ),
        ),
      );
    }

    final hasExam = _targetExamName != null && _targetExamName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            ],
          ),
          const SizedBox(height: 16),
          if (hasExam) ...[
            Text(
              _targetExamName!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F0F11),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your selected preparation goal',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: null, // Routing to exam details or dashboard
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
          ] else ...[
            const Text(
              'Choose an exam to personalize your preparation.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0F0F11),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => context.push('/onboarding/language'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F11),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Choose Target Exam',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11)),
        decoration: InputDecoration(
          hintText: 'Search exams...',
          hintStyle: TextStyle(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(Icons.search, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF0F0F11)),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final List<String> categories = ['All', ...staticCategories.map((e) => e.name)];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6),
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamCountAndList() {
    final exams = _filteredExams;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _searchQuery.isNotEmpty
              ? '${exams.length} exams found'
              : '${exams.length} exams available',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        if (exams.isEmpty)
          _buildEmptyState()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              if (constraints.maxWidth >= 1024) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth >= 600) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.3,
                ),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  return _buildExamCard(exams[index]);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'No exams found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F0F11),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find an exam matching your search.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: const Text(
                'Clear Search',
                style: TextStyle(
                  color: Color(0xFF0F0F11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 48, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'No exams available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Exams for this category will appear here when available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ExamDefinition exam) {
    final isTarget = _targetExamName == exam.name || _targetExamId == exam.id;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isTarget ? const Color(0xFFE4DBF6).withValues(alpha: 0.3) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTarget ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exam.categoryId.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.5),
                ),
              ),
              if (isTarget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4DBF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Target Exam',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F0F11),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exam.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              exam.description,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exam.subjects.join(' • '),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                context.push('/exams/${exam.id}');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F0F11),
                side: const BorderSide(color: Color(0xFF0F0F11)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.4),
              ),
              child: const Text(
                'View Exam',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
