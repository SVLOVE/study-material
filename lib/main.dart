import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!.trim(),
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!.trim(),
  );

  runApp(
    const ProviderScope(
      child: GovPrepApp(),
    ),
  );
}

class GovPrepApp extends ConsumerStatefulWidget {
  const GovPrepApp({super.key});

  @override
  ConsumerState<GovPrepApp> createState() => _GovPrepAppState();
}

class _GovPrepAppState extends ConsumerState<GovPrepApp> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        appRouter.go('/update-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GovPrep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Forced to light theme as per user request
      routerConfig: appRouter,
    );
  }
}
