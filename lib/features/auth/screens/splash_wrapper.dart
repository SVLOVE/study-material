import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/device_registration_service.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Small delay for smooth transition
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      context.go('/login');
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}







