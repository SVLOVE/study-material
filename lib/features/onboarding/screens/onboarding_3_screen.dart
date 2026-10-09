import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class Onboarding3Screen extends StatefulWidget {
  const Onboarding3Screen({super.key});

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
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
        _buildDot(false),
        const SizedBox(width: 8),
        _buildDot(false),
        const SizedBox(width: 8),
        _buildDot(true),
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
          padding: const EdgeInsets.all(32),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_rounded, color: Color(0xFF0F0F11)),
                  const SizedBox(width: 12),
                  Text(
                    'SMART INSIGHTS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                      color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInsightRow('Accuracy', '82%', const Color(0xFFE2F0D9)),
              const SizedBox(height: 16),
              _buildInsightRow('Weak Area', 'Polity', const Color(0xFFE4DBF6)),
              const SizedBox(height: 16),
              _buildInsightRow('Recommended', '20 Questions', const Color(0xFFE2ECE9)),
              const SizedBox(height: 16),
              _buildInsightRow('Readiness', '78%', const Color(0xFFFDF0D5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
      ],
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
              'Your Preparation,\nPersonalized.',
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
              'GovPrep AI analyzes your preparation and helps you focus on the right questions, topics, and practice at the right time.',
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildFeatureBlock(Icons.psychology_rounded, 'Smart Recommendations', 'Practice what matters most.', const Color(0xFFE4DBF6)),
            const SizedBox(height: 16),
            _buildFeatureBlock(Icons.manage_search_rounded, 'Weak Area Detection', 'Find where you need more practice.', const Color(0xFFE2ECE9)),
            const SizedBox(height: 16),
            _buildFeatureBlock(Icons.auto_graph_rounded, 'Progress Insights', 'Know how ready you are.', const Color(0xFFE2F0D9)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBlock(IconData icon, String title, String subtitle, Color color) {
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
            child: Icon(icon, color: const Color(0xFF0F0F11)),
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
                  fontSize: 16,
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
              // Back to Onboarding 2
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              // Get Started - go to Language Selection
              context.push('/onboarding/language');
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
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
