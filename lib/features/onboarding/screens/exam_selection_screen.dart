import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class TargetExam {
  final String id;
  final String categoryId;
  final String title;
  final String description;

  const TargetExam({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
  });
}

class ExamSelectionScreen extends ConsumerStatefulWidget {
  final String? language;
  final String? categoryId;
  final String? categoryName;

  const ExamSelectionScreen({
    super.key,
    this.language,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<ExamSelectionScreen> createState() => _ExamSelectionScreenState();
}

class _ExamSelectionScreenState extends ConsumerState<ExamSelectionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final List<TargetExam> _examCatalog = const [
    // TNPSC
    TargetExam(id: 'tnpsc_g1', categoryId: 'tnpsc', title: 'Group 1', description: 'TNPSC Group 1'),
    TargetExam(id: 'tnpsc_g2', categoryId: 'tnpsc', title: 'Group 2', description: 'TNPSC Group 2'),
    TargetExam(id: 'tnpsc_g2a', categoryId: 'tnpsc', title: 'Group 2A', description: 'TNPSC Group 2A'),
    TargetExam(id: 'tnpsc_g4', categoryId: 'tnpsc', title: 'Group 4', description: 'TNPSC Group 4'),
    TargetExam(id: 'tnpsc_g5a', categoryId: 'tnpsc', title: 'Group 5A', description: 'TNPSC Group 5A'),
    TargetExam(id: 'tnpsc_g7b', categoryId: 'tnpsc', title: 'Group 7B', description: 'TNPSC Group 7B'),
    TargetExam(id: 'tnpsc_g8', categoryId: 'tnpsc', title: 'Group 8', description: 'TNPSC Group 8'),

    // SSC
    TargetExam(id: 'ssc_cgl', categoryId: 'ssc', title: 'CGL', description: 'Combined Graduate Level'),
    TargetExam(id: 'ssc_chsl', categoryId: 'ssc', title: 'CHSL', description: 'Combined Higher Secondary Level'),
    TargetExam(id: 'ssc_mts', categoryId: 'ssc', title: 'MTS', description: 'Multi Tasking Staff'),
    TargetExam(id: 'ssc_gd', categoryId: 'ssc', title: 'GD Constable', description: 'General Duty Constable'),
    TargetExam(id: 'ssc_cpo', categoryId: 'ssc', title: 'CPO', description: 'Central Police Organization'),
    TargetExam(id: 'ssc_steno', categoryId: 'ssc', title: 'Stenographer', description: 'Stenographer Grade C & D'),

    // RRB
    TargetExam(id: 'rrb_ntpc', categoryId: 'rrb', title: 'NTPC', description: 'Non-Technical Popular Categories'),
    TargetExam(id: 'rrb_group_d', categoryId: 'rrb', title: 'Group D', description: 'RRC Group D Level 1'),
    TargetExam(id: 'rrb_alp', categoryId: 'rrb', title: 'ALP', description: 'Assistant Loco Pilot'),
    TargetExam(id: 'rrb_tech', categoryId: 'rrb', title: 'Technician', description: 'Railway Technician'),
    TargetExam(id: 'rrb_je', categoryId: 'rrb', title: 'JE', description: 'Junior Engineer'),

    // Banking
    TargetExam(id: 'bank_ibps_po', categoryId: 'banking', title: 'IBPS PO', description: 'Probationary Officer'),
    TargetExam(id: 'bank_ibps_clerk', categoryId: 'banking', title: 'IBPS Clerk', description: 'Clerical Cadre'),
    TargetExam(id: 'bank_sbi_po', categoryId: 'banking', title: 'SBI PO', description: 'SBI Probationary Officer'),
    TargetExam(id: 'bank_sbi_clerk', categoryId: 'banking', title: 'SBI Clerk', description: 'SBI Junior Associate'),
    TargetExam(id: 'bank_ibps_rrb', categoryId: 'banking', title: 'IBPS RRB', description: 'Regional Rural Banks'),
    TargetExam(id: 'bank_rbi_asst', categoryId: 'banking', title: 'RBI Assistant', description: 'RBI Assistant'),

    // UPSC
    TargetExam(id: 'upsc_cse', categoryId: 'upsc', title: 'Civil Services Examination', description: 'IAS, IPS, IFS etc.'),
    TargetExam(id: 'upsc_nda', categoryId: 'upsc', title: 'NDA', description: 'National Defence Academy'),
    TargetExam(id: 'upsc_cds', categoryId: 'upsc', title: 'CDS', description: 'Combined Defence Services'),
    TargetExam(id: 'upsc_capf', categoryId: 'upsc', title: 'CAPF', description: 'Central Armed Police Forces'),

    // Defence
    TargetExam(id: 'def_nda', categoryId: 'defence', title: 'NDA', description: 'National Defence Academy'),
    TargetExam(id: 'def_cds', categoryId: 'defence', title: 'CDS', description: 'Combined Defence Services'),
    TargetExam(id: 'def_afcat', categoryId: 'defence', title: 'AFCAT', description: 'Air Force Common Admission Test'),
    TargetExam(id: 'def_agniveer', categoryId: 'defence', title: 'Agniveer', description: 'Armed Forces Agniveer'),

    // Teaching
    TargetExam(id: 'teach_tntet', categoryId: 'teaching', title: 'TNTET', description: 'Tamil Nadu Teacher Eligibility Test'),
    TargetExam(id: 'teach_trb', categoryId: 'teaching', title: 'TRB', description: 'Teachers Recruitment Board'),
    TargetExam(id: 'teach_ctet', categoryId: 'teaching', title: 'CTET', description: 'Central Teacher Eligibility Test'),
    TargetExam(id: 'teach_pg', categoryId: 'teaching', title: 'PG Assistant', description: 'Post Graduate Assistant'),
    TargetExam(id: 'teach_tet', categoryId: 'teaching', title: 'TET', description: 'Teacher Eligibility Test'),

    // Police
    TargetExam(id: 'pol_tn_si', categoryId: 'police', title: 'TNUSRB SI', description: 'Sub-Inspector of Police'),
    TargetExam(id: 'pol_tn_constable', categoryId: 'police', title: 'TNUSRB Constable', description: 'Police Constable'),
    TargetExam(id: 'pol_ssc_gd', categoryId: 'police', title: 'SSC GD', description: 'Constable (General Duty)'),
    TargetExam(id: 'pol_rect', categoryId: 'police', title: 'Police Recruitment', description: 'State Police Recruitment'),
  ];

  final List<int> _targetYears = [2026, 2027, 2028, 2029, 2030];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onExamTapped(String examId) {
    ref.read(onboardingProvider.notifier).setTargetExam(examId);
  }

  void _onYearSelected(int? year) {
    if (year != null) {
      ref.read(onboardingProvider.notifier).setTargetYear(year);
    }
  }

  void _onContinue() {
    final state = ref.read(onboardingProvider);
    if (state.targetExam == null || state.targetYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a target exam and year.'),
          backgroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Navigate to Screen 09
    context.push('/onboarding/preparation');
  }

  String _getCategoryDisplayName(String categoryId) {
    switch(categoryId) {
      case 'tnpsc': return 'TNPSC';
      case 'ssc': return 'SSC';
      case 'rrb': return 'RRB / Railway';
      case 'banking': return 'Banking';
      case 'upsc': return 'UPSC';
      case 'defence': return 'Defence';
      case 'teaching': return 'Teaching';
      case 'police': return 'Police';
      default: return categoryId.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final selectedCategories = onboardingState.selectedExamCategories;
    
    // Filter exams based on selected categories
    final filteredExams = _examCatalog.where((exam) => selectedCategories.contains(exam.categoryId)).toList();
    
    // Group them by category
    final groupedExams = <String, List<TargetExam>>{};
    for (var exam in filteredExams) {
      groupedExams.putIfAbsent(exam.categoryId, () => []).add(exam);
    }

    final hasSelection = onboardingState.targetExam != null && onboardingState.targetYear != null;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            final isTablet = constraints.maxWidth > 600 && !isDesktop;

            return Stack(
              children: [
                _buildBackgroundShapes(),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: isDesktop ? 900 : constraints.maxWidth * 0.95,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFFFFF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F0F11).withValues(alpha: 0.03),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(isDesktop ? 48.0 : 24.0, isDesktop ? 48.0 : 24.0, isDesktop ? 48.0 : 24.0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTopBar(context),
                                  const SizedBox(height: 24),
                                  _buildHeader(),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                            Expanded(
                              child: groupedExams.isEmpty
                                  ? _buildEmptyState()
                                  : SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48.0 : 24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          ...groupedExams.entries.map((entry) {
                                            return _buildCategorySection(
                                              _getCategoryDisplayName(entry.key),
                                              entry.value,
                                              isDesktop,
                                              isTablet,
                                              onboardingState.targetExam,
                                            );
                                          }),
                                          const SizedBox(height: 40),
                                          _buildYearSelector(onboardingState.targetYear),
                                          const SizedBox(height: 48),
                                        ],
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(isDesktop ? 48.0 : 24.0, 0, isDesktop ? 48.0 : 24.0, isDesktop ? 48.0 : 24.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  _buildContinueButton(isDesktop, hasSelection),
                                  const SizedBox(height: 32),
                                  _buildProgressIndicator(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFE4DBF6).withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0D9).withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 20, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Text(
          'GovPrep AI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 60), // For balance
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Choose your target exam',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select the specific exam and the year you plan to appear.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll use this to personalize your preparation journey.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: const Color(0xFF0F0F11).withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'No exam categories selected.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 8),
          Text(
            'Go back and select at least one exam category.',
            style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to exam categories'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<TargetExam> exams, bool isDesktop, bool isTablet, String? selectedExamId) {
    int crossAxisCount = 1;
    if (isDesktop) {
      crossAxisCount = 3;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0F11),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: const Color(0xFFF3F4F6),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isDesktop ? 2.5 : (isTablet ? 3.0 : 4.0),
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
          ),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            return _buildExamCard(exam, selectedExamId == exam.id);
          },
        ),
      ],
    );
  }

  Widget _buildExamCard(TargetExam exam, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onExamTapped(exam.id),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.4) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.5) : const Color(0xFF0F0F11).withValues(alpha: 0.02),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F0F11),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exam.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                const Icon(Icons.check_circle, color: Color(0xFF0F0F11), size: 20)
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F0F11).withValues(alpha: 0.2), width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector(int? selectedYear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Year',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedYear,
              hint: Text(
                'Select target examination year',
                style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0F0F11)),
              borderRadius: BorderRadius.circular(16),
              items: _targetYears.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F0F11),
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onYearSelected,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(bool isDesktop, bool hasSelection) {
    return SizedBox(
      width: isDesktop ? 240 : double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: hasSelection ? _onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasSelection ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6),
          foregroundColor: hasSelection ? const Color(0xFFFFFFFF) : const Color(0xFF0F0F11).withValues(alpha: 0.4),
          disabledBackgroundColor: const Color(0xFFF3F4F6),
          disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Step 3 of 5',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(width: 16),
        _buildDot(true),
        _buildLine(),
        _buildDot(true), 
        _buildLine(),
        _buildDot(true), // Step 3 is active
        _buildLine(),
        _buildDot(false),
        _buildLine(),
        _buildDot(false),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLine() {
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFF3F4F6),
    );
  }
}


