import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen Width for responsive checks
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrandHeader(),
          const Expanded(child: SizedBox()),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 48.0),
                  child: _buildContent(context, isDesktop: true),
                ),
              ),
              Expanded(
                child: _buildVisual(),
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBrandHeader(center: true),
          const SizedBox(height: 48),
          _buildVisual(),
          const SizedBox(height: 48),
          _buildContent(context, isDesktop: false),
        ],
      ),
    );
  }

  Widget _buildBrandHeader({bool center = false}) {
    return Align(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: const Text(
        'GovPrep AI',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F0F11),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Prepare Smarter.\nAchieve Your Government Exam Goals.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F0F11),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Practice previous-year questions, take mock tests, track your progress, and prepare with a personalized learning experience.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: isDesktop ? null : double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to onboarding
              context.push('/onboarding/language');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 48),
              elevation: 0,
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push('/login');
              },
              child: const Text(
                'Log in',
                style: TextStyle(
                  color: Color(0xFF0F0F11),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisual() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureIcon(Icons.menu_book_rounded, const Color(0xFFE4DBF6), 'Practice'),
                _buildFeatureIcon(Icons.timer_rounded, const Color(0xFFE2ECE9), 'Mock Tests'),
                _buildFeatureIcon(Icons.insights_rounded, const Color(0xFFE2F0D9), 'Smart Insights'),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0D5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.school_rounded, size: 80, color: Color(0xFF0F0F11)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, Color bgColor, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0F0F11), size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
          ),
        )
      ],
    );
  }
}
