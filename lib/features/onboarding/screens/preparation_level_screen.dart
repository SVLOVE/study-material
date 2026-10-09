import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import 'exam_selection_screen.dart'; // To access TargetExam catalog if needed

class PreparationLevelScreen extends ConsumerStatefulWidget {
  const PreparationLevelScreen({super.key});

  @override
  ConsumerState<PreparationLevelScreen> createState() => _PreparationLevelScreenState();
}

class _PreparationLevelScreenState extends ConsumerState<PreparationLevelScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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

  void _onLevelTapped(String level) {
    ref.read(onboardingProvider.notifier).setPreparationLevel(level);
  }

  void _onContinue() {
    final state = ref.read(onboardingProvider);
    if (state.preparationLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your preparation level to continue.'),
          backgroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Navigate to Screen 10 (Create Account)
    context.push('/register');
  }

  String _getExamTitle(String examId) {
    // A quick mapping for display purposes since the catalog is local in ExamSelectionScreen
    final Map<String, String> examTitles = {
      'tnpsc_g1': 'TNPSC Group 1',
      'tnpsc_g2': 'TNPSC Group 2',
      'tnpsc_g2a': 'TNPSC Group 2A',
      'tnpsc_g4': 'TNPSC Group 4',
      'tnpsc_g5a': 'TNPSC Group 5A',
      'tnpsc_g7b': 'TNPSC Group 7B',
      'tnpsc_g8': 'TNPSC Group 8',
      'ssc_cgl': 'SSC CGL',
      'ssc_chsl': 'SSC CHSL',
      'ssc_mts': 'SSC MTS',
      'ssc_gd': 'SSC GD Constable',
      'ssc_cpo': 'SSC CPO',
      'ssc_steno': 'SSC Stenographer',
      'rrb_ntpc': 'RRB NTPC',
      'rrb_group_d': 'RRB Group D',
      'rrb_alp': 'RRB ALP',
      'rrb_tech': 'RRB Technician',
      'rrb_je': 'RRB JE',
      'bank_ibps_po': 'IBPS PO',
      'bank_ibps_clerk': 'IBPS Clerk',
      'bank_sbi_po': 'SBI PO',
      'bank_sbi_clerk': 'SBI Clerk',
      'bank_ibps_rrb': 'IBPS RRB',
      'bank_rbi_asst': 'RBI Assistant',
      'upsc_cse': 'UPSC Civil Services',
      'upsc_nda': 'UPSC NDA',
      'upsc_cds': 'UPSC CDS',
      'upsc_capf': 'UPSC CAPF',
      'def_nda': 'Defence NDA',
      'def_cds': 'Defence CDS',
      'def_afcat': 'Defence AFCAT',
      'def_agniveer': 'Defence Agniveer',
      'teach_tntet': 'TNTET',
      'teach_trb': 'TRB',
      'teach_ctet': 'CTET',
      'teach_pg': 'PG Assistant',
      'teach_tet': 'TET',
      'pol_tn_si': 'TNUSRB SI',
      'pol_tn_constable': 'TNUSRB Constable',
      'pol_ssc_gd': 'SSC GD',
      'pol_rect': 'Police Recruitment',
    };
    return examTitles[examId] ?? examId.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final hasSelection = onboardingState.preparationLevel != null;

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
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48.0 : 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (onboardingState.targetExam != null && onboardingState.targetYear != null)
                                      _buildTargetSummary(onboardingState.targetExam!, onboardingState.targetYear!),
                                    const SizedBox(height: 32),
                                    _buildPreparationCards(isDesktop, isTablet, onboardingState.preparationLevel),
                                    const SizedBox(height: 32),
                                    _buildPersonalizationInfo(),
                                    const SizedBox(height: 32),
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
        const SizedBox(width: 60),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "What's your current preparation level?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tell us where you are in your preparation so we can personalize your journey.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSummary(String examId, int year) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your target',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getExamTitle(examId),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0F11),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0D5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              year.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F0F11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationCards(bool isDesktop, bool isTablet, String? selectedLevel) {
    final cards = [
      _buildCard(
        id: 'beginner',
        title: 'Beginner',
        description: "I'm starting my preparation and building the basics.",
        icon: Icons.rocket_launch,
        isSelected: selectedLevel == 'beginner',
      ),
      _buildCard(
        id: 'intermediate',
        title: 'Intermediate',
        description: 'I know the basics and regularly practice questions.',
        icon: Icons.trending_up,
        isSelected: selectedLevel == 'intermediate',
      ),
      _buildCard(
        id: 'advanced',
        title: 'Advanced',
        description: "I'm confident with the syllabus and focus on performance.",
        icon: Icons.workspace_premium,
        isSelected: selectedLevel == 'advanced',
      ),
    ];

    if (isDesktop || isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards.map((card) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: card,
          ),
        )).toList(),
      );
    } else {
      return Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: card,
        )).toList(),
      );
    }
  }

  Widget _buildCard({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    return Semantics(
      label: 'Select $title preparation level',
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onLevelTapped(id),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.5) : const Color(0xFF0F0F11).withValues(alpha: 0.02),
                  blurRadius: isSelected ? 12 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFFFFF).withValues(alpha: 0.5) : const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 28, color: const Color(0xFF0F0F11)),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Color(0xFF0F0F11), size: 24)
                    else
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F0F11).withValues(alpha: 0.15), width: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2ECE9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: const Color(0xFF0F0F11).withValues(alpha: 0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your level helps us personalize question difficulty, practice recommendations and mock tests.',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
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
          'Step 4 of 5',
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
        _buildDot(true),
        _buildLine(),
        _buildDot(true), // Step 4 is active
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
