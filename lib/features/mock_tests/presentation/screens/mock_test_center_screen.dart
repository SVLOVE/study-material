import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/mock_test.dart';

class MockTestCenterScreen extends ConsumerStatefulWidget {
  const MockTestCenterScreen({super.key});

  @override
  ConsumerState<MockTestCenterScreen> createState() => _MockTestCenterScreenState();
}

class _MockTestCenterScreenState extends ConsumerState<MockTestCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedFilter = 'All';
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
      // Graceful fallback
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

  List<MockTest> get _filteredTests {
    return mockCatalog.where((test) {
      final matchesFilter = _selectedFilter == 'All' || test.type == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty || test.title.toLowerCase().contains(_searchQuery);
      final matchesTarget = _targetExamId == null || test.targetExamId == _targetExamId;
      
      // In a real app we'd fetch tests by target exam id from backend, here we filter mockCatalog.
      // If we don't match the target, we don't show it for personalization, unless we want to show all. 
      // The prompt says "Mock tests for your selected exam will appear here". So let's restrict to target exam if selected.
      if (_targetExamId != null && !matchesTarget) return false;

      return matchesFilter && matchesSearch;
    }).toList();
  }
  
  List<MockTest> get _recentTests {
    return mockCatalog.where((test) => test.status == 'Completed' && (_targetExamId == null || test.targetExamId == _targetExamId)).toList();
  }

  void _showStartConfirmation(MockTest test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Ready to start?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This mock test is timed. Once you begin, the timer will start.',
              style: TextStyle(color: Color(0xFF0F0F11)),
            ),
            const SizedBox(height: 24),
            _buildDialogRow('Questions', '${test.questionCount}'),
            const SizedBox(height: 8),
            _buildDialogRow('Duration', '${test.durationMinutes} min'),
            const SizedBox(height: 8),
            _buildDialogRow('Type', test.type),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF0F0F11))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/mock-tests/runner/${test.id}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
        Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTargetExamHeader(),
                const SizedBox(height: 32),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildTypeFilters(),
                const SizedBox(height: 32),
                _buildRecentTests(),
                const SizedBox(height: 32),
                _buildMockTestList(),
                const SizedBox(height: 48),
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
            'Mock Test Center',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Test yourself under exam-like conditions and understand your readiness.',
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

  Widget _buildTargetExamHeader() {
    if (_isLoadingTarget) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11))),
        ),
      );
    }

    final hasExam = _targetExamName != null;

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
            child: const Icon(Icons.school, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Target Exam',
                  style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 4),
                Text(
                  hasExam ? _targetExamName! : 'Select a target exam to personalize your mock tests.',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                ),
              ],
            ),
          ),
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
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11)),
        decoration: InputDecoration(
          hintText: 'Search mock tests...',
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

  Widget _buildTypeFilters() {
    final List<String> types = ['All', 'Full Length', 'Sectional', 'Topic', 'Daily'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _selectedFilter == type;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = type;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6),
                  ),
                ),
                child: Center(
                  child: Text(
                    type,
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

  Widget _buildRecentTests() {
    final recent = _recentTests;
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Recent Tests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: recent.map((test) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F0D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 20, color: Color(0xFF0F0F11)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F0F11)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completed',
                            style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
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

  Widget _buildMockTestList() {
    final tests = _filteredTests;

    if (_targetExamId == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('No mock tests available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('Select a target exam to see your mock tests.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    if (tests.isEmpty) {
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
              const Text('No tests found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text('Try a different search term or test type.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text('Clear Search', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.w600)),
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
            Icon(Icons.assignment_outlined, size: 48, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('No mock tests available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('Mock tests for your selected exam will appear here when available.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
            const SizedBox(height: 8),
            Text('Continue practicing while new tests are added.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    return LayoutBuilder(
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
            childAspectRatio: crossAxisCount == 1 ? 1.6 : 1.2,
          ),
          itemCount: tests.length,
          itemBuilder: (context, index) {
            return _buildMockTestCard(tests[index]);
          },
        );
      },
    );
  }

  Widget _buildMockTestCard(MockTest test) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: test.isDaily ? const Color(0xFFFDF0D5) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: test.isDaily ? const Color(0xFFFDF0D5) : const Color(0xFFF3F4F6)),
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
                test.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.5),
                ),
              ),
              if (test.status == 'Completed')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F0D9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F0F11),
                    ),
                  ),
                )
              else
                Text(
                  test.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            test.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.quiz_outlined, size: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text('${test.questionCount} Questions', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
              const SizedBox(width: 16),
              Icon(Icons.timer_outlined, size: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text('${test.durationMinutes} Minutes', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Difficulty: ${test.difficulty}',
            style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: test.status == 'Completed' ? null : () => _showStartConfirmation(test),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F11),
                disabledBackgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Start Test', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
