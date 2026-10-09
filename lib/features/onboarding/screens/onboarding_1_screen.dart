import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class Onboarding1Screen extends StatefulWidget {
  const Onboarding1Screen({super.key});

  @override
  State<Onboarding1Screen> createState() => _Onboarding1ScreenState();
}

class _Onboarding1ScreenState extends State<Onboarding1Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
                      child: _buildHeroVisual(),
                    ),
                  ),
                  Expanded(
                    child: _buildContent(context, isDesktop: true),
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
        _buildDot(true),
        const SizedBox(width: 8),
        _buildDot(false),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStageVisual(Icons.menu_book_rounded, const Color(0xFFE4DBF6)),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0F0F11), size: 24),
              _buildStageVisual(Icons.check_circle_outline_rounded, const Color(0xFFE2ECE9)),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0F0F11), size: 24),
              _buildStageVisual(Icons.timer_rounded, const Color(0xFFFDF0D5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageVisual(IconData icon, Color bgColor) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: const Color(0xFF0F0F11), size: 32),
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
              'Learn. Practice. Test.',
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
              'Build your knowledge, strengthen your skills, and test your preparation with a structured exam journey.',
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildFeatureBlock('01', 'Learn', 'Understand the concepts', const Color(0xFFE4DBF6)),
            const SizedBox(height: 16),
            _buildFeatureBlock('02', 'Practice', 'Strengthen your preparation', const Color(0xFFE2ECE9)),
            const SizedBox(height: 16),
            _buildFeatureBlock('03', 'Test', 'Measure your readiness', const Color(0xFFFDF0D5)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBlock(String number, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F0F11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0F0F11),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
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
              // Continue to Onboarding 2
              context.push('/onboarding/2');
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
