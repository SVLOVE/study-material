import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class ExamGoalItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const ExamGoalItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class ExamCategoryScreen extends ConsumerStatefulWidget {
  final String? language; // Keeping this parameter to not break existing routing structure entirely, but it may be unused in new design
  const ExamCategoryScreen({super.key, this.language});

  @override
  ConsumerState<ExamCategoryScreen> createState() => _ExamCategoryScreenState();
}

class _ExamCategoryScreenState extends ConsumerState<ExamCategoryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final List<ExamGoalItem> _examGoals = const [
    ExamGoalItem(id: 'tnpsc', title: 'TNPSC', description: 'Tamil Nadu Public Service Commission', icon: Icons.account_balance),
    ExamGoalItem(id: 'ssc', title: 'SSC', description: 'Staff Selection Commission', icon: Icons.description),
    ExamGoalItem(id: 'rrb', title: 'RRB / Railway', description: 'Railway Recruitment', icon: Icons.train),
    ExamGoalItem(id: 'banking', title: 'Banking', description: 'IBPS • SBI • Banking Exams', icon: Icons.account_balance_wallet),
    ExamGoalItem(id: 'upsc', title: 'UPSC', description: 'Civil Services & Central Exams', icon: Icons.workspace_premium),
    ExamGoalItem(id: 'defence', title: 'Defence', description: 'NDA • CDS • Defence Exams', icon: Icons.shield),
    ExamGoalItem(id: 'teaching', title: 'Teaching', description: 'TET • TRB • Teaching Exams', icon: Icons.school),
    ExamGoalItem(id: 'police', title: 'Police', description: 'State Police & Recruitment Exams', icon: Icons.local_police),
  ];

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
    
    // Sync language from extra if provided (bridge between old and new state)
    if (widget.language != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(onboardingProvider.notifier).setLanguage(widget.language!);
      });
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCategoryTapped(String id) {
    ref.read(onboardingProvider.notifier).toggleExamCategory(id);
  }

  void _onContinue() {
    final selectedCategories = ref.read(onboardingProvider).selectedExamCategories;
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one exam to continue.'),
          backgroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Pass the selected categories downstream. Assuming target exam screen handles empty language string gracefully if it was missing.
    // Preserving the 'language' extra param so we don't break GoRouter's expectations.
    final lang = ref.read(onboardingProvider).language;
    context.push('/onboarding/exams', extra: {
      'language': lang,
      // For compatibility with the old target exam screen, we just pass the first selected ID
      // You may need to adapt this when Screen 08 is built.
      'categoryId': selectedCategories.first,
      'categoryName': _examGoals.firstWhere((e) => e.id == selectedCategories.first).title,
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategories = ref.watch(onboardingProvider).selectedExamCategories;
    final hasSelection = selectedCategories.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            return Stack(
              children: [
                _buildBackgroundShapes(),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: isDesktop ? 800 : constraints.maxWidth * 0.95,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTopBar(context),
                            const SizedBox(height: 24),
                            _buildHeader(),
                            const SizedBox(height: 40),
                            Flexible(
                              child: _buildGrid(isDesktop, selectedCategories),
                            ),
                            const SizedBox(height: 24),
                            _buildSelectionCounter(selectedCategories.length),
                            const SizedBox(height: 16),
                            _buildContinueButton(isDesktop, hasSelection),
                            const SizedBox(height: 32),
                            _buildProgressIndicator(),
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
          top: -100,
          right: -50,
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
          bottom: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFFE2ECE9).withValues(alpha: 0.4),
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
        // Placeholder for balancing the back button
        const SizedBox(width: 60),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Which exams are you preparing for?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select one or more categories to personalize your preparation.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(bool isDesktop, Set<String> selectedCategories) {
    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _examGoals.length,
        itemBuilder: (context, index) {
          final item = _examGoals[index];
          return _buildExamCard(item, selectedCategories.contains(item.id));
        },
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: _examGoals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _examGoals[index];
          return _buildExamCard(item, selectedCategories.contains(item.id));
        },
      );
    }
  }

  Widget _buildExamCard(ExamGoalItem item, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCategoryTapped(item.id),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.4) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.5) : const Color(0xFF0F0F11).withValues(alpha: 0.02),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: const Color(0xFF0F0F11), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F0F11),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
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
              const SizedBox(width: 12),
              if (isSelected)
                const Icon(Icons.check_circle, color: Color(0xFF0F0F11), size: 24)
              else
                Container(
                  width: 24,
                  height: 24,
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

  Widget _buildSelectionCounter(int count) {
    String text;
    if (count == 0) {
      text = 'Select at least one exam';
    } else if (count == 1) {
      text = '1 exam selected';
    } else {
      text = '$count exams selected';
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF0F0F11).withValues(alpha: count == 0 ? 0.5 : 0.8),
      ),
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
          'Step 2 of 5',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(width: 16),
        _buildDot(true),
        _buildLine(),
        _buildDot(true), // Step 2 is active
        _buildLine(),
        _buildDot(false),
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

