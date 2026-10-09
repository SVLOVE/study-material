import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class Onboarding2Screen extends StatefulWidget {
  const Onboarding2Screen({super.key});

  @override
  State<Onboarding2Screen> createState() => _Onboarding2ScreenState();
}

class _Onboarding2ScreenState extends State<Onboarding2Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  
  // Staggered animations for category chips
  late final List<Animation<double>> _chipFadeAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    // 4 chips staggering
    _chipFadeAnimations = List.generate(4, (index) {
      final start = 0.4 + (index * 0.15);
      final end = start + 0.15;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48.0),
          child: Column(
            children: [
              _buildProgressIndicator(),
              const Expanded(flex: 1, child: SizedBox()),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: _buildContent(context, isDesktop: true),
                    ),
                  ),
                  Expanded(
                    child: _buildHeroVisual(),
                  ),
                ],
              ),
              const Expanded(flex: 2, child: SizedBox()),
              _buildNavigation(context, isDesktop: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      _buildBrandHeader(),
                      const SizedBox(height: 24),
                      _buildProgressIndicator(),
                      const SizedBox(height: 48),
                      _buildHeroVisual(),
                      const SizedBox(height: 48),
                      _buildContent(context, isDesktop: false),
                    ],
                  ),
                  const SizedBox(height: 48),
                  _buildNavigation(context, isDesktop: false),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildBrandHeader() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'GovPrep AI',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F0F11),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(false),
        const SizedBox(width: 8),
        _buildDot(true),
        const SizedBox(width: 8),
        _buildDot(false),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeroVisual() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F0F11).withValues(alpha: 0.05),
                blurRadius: 40,
                offset: const Offset(0, 20),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F11),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'GOVPREP AI',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildAnimatedChip('TNPSC', const Color(0xFFE4DBF6), 0),
                  _buildAnimatedChip('SSC', const Color(0xFFE2ECE9), 1),
                  _buildAnimatedChip('RRB', const Color(0xFFE2F0D9), 2),
                  _buildAnimatedChip('Banking', const Color(0xFFFDF0D5), 3),
                ],
              ),
              const SizedBox(height: 16),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InactiveChip('UPSC'),
                  _InactiveChip('Defence'),
                  _InactiveChip('Teaching'),
                  _InactiveChip('Police'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedChip(String label, Color color, int index) {
    return FadeTransition(
      opacity: _chipFadeAnimations[index],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isDesktop}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              'One Platform.\nMultiple Exam Goals.',
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 48 : 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F0F11),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Prepare for TNPSC, SSC, RRB, Banking, UPSC and more — all in one focused preparation experience.',
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Color(0xFF0F0F11)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose your exam, follow the syllabus, practice targeted questions, and track your preparation.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0F0F11),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(BuildContext context, {required bool isDesktop}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              // Skip to Language Selection (existing next onboarding destination)
              context.push('/onboarding/language');
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              // Continue to Onboarding 3
              context.push('/onboarding/3');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InactiveChip extends StatelessWidget {
  final String label;

  const _InactiveChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F0F11).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
