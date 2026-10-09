import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/device_registration_service.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.6, curve: Curves.easeIn)),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 0.9, curve: Curves.easeIn)),
    );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.9, 1.0, curve: Curves.easeIn)),
    );

    _animationController.forward();
    
    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    // Wait for animation and minimal delay
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      context.go('/welcome');
      return;
    }

    // Device Check on App Start
    final isAllowed = await DeviceRegistrationService.checkAndRegisterDevice(session.user.id);
    if (!isAllowed) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
      return;
    }

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, selected_exam_id, role')
          .eq('id', session.user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile?['role'] == 'admin' || session.user.email == 'sakthisakthi0991@gmail.com') {
        context.go('/admin/dashboard');
      } else if (profile == null || profile['full_name'] == null || profile['full_name'].toString().isEmpty) {
        context.go('/create-profile');
      } else if (profile['selected_exam_id'] == null) {
        context.go('/onboarding/language');
      } else {
        context.go('/home');
      }
    } catch (e) {
      // If error occurs, fallback to home and let it handle errors
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7), // Background
      body: Stack(
        children: [
          // Subtle background blobs (optional, simple circles for depth)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFFE4DBF6), // Lavender Purple
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
              decoration: const BoxDecoration(
                color: Color(0xFFE2ECE9), // Muted Teal
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoOpacity,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F0F11).withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Icon(Icons.school_rounded, size: 64, color: Color(0xFF0F0F11)),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _titleOpacity,
                  child: const Text(
                    'GovPrep AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F0F11),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Text(
                    'Prepare Smart. Practice Better. Achieve More.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _loaderOpacity,
                  child: const SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      backgroundColor: Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
                      minHeight: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
