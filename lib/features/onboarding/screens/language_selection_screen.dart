import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // State
  String _selectedLanguage = 'en';

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

  void _onLanguageSelected(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _onContinue() {
    // Navigate to next onboarding step passing the language choice
    context.push('/onboarding/categories', extra: _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            return Stack(
              children: [
                // Subtle decorative shapes
                Positioned(
                  top: -100,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4DBF6).withValues(alpha: 0.5),
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
                      color: const Color(0xFFE2ECE9).withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: isDesktop ? 600 : constraints.maxWidth * 0.9,
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
                            _buildBrandHeader(),
                            const SizedBox(height: 32),
                            _buildHeader(),
                            const SizedBox(height: 48),
                            isDesktop
                                ? Row(
                                    children: [
                                      Expanded(child: _buildLanguageCard('ta', 'தமிழ்', 'Tamil')),
                                      const SizedBox(width: 24),
                                      Expanded(child: _buildLanguageCard('en', 'English', 'English')),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildLanguageCard('ta', 'தமிழ்', 'Tamil'),
                                      const SizedBox(height: 16),
                                      _buildLanguageCard('en', 'English', 'English'),
                                    ],
                                  ),
                            const SizedBox(height: 48),
                            _buildContinueButton(isDesktop),
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

  Widget _buildBrandHeader() {
    return const Text(
      'GovPrep AI',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F0F11),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Choose your language',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select your preferred language for GovPrep AI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(String id, String mainLabel, String subLabel) {
    final isSelected = _selectedLanguage == id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onLanguageSelected(id),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.3) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFF0F0F11).withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFFE4DBF6).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
            ],
          ),
          child: Stack(
            children: [
              if (isSelected)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF0F0F11),
                    size: 20,
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mainLabel,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 240 : double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F0F11),
          foregroundColor: const Color(0xFFFFFFFF),
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
          'Step 1 of 5',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(width: 16),
        _buildDot(true),
        _buildLine(),
        _buildDot(false),
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

