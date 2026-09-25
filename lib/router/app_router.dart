import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/update_password_screen.dart';
import '../features/auth/screens/create_profile_screen.dart';
import '../features/auth/screens/splash_wrapper.dart';
import '../features/onboarding/screens/language_selection_screen.dart';
import '../features/onboarding/screens/exam_category_screen.dart';
import '../features/onboarding/screens/exam_selection_screen.dart';
import '../features/home/screens/main_layout_screen.dart';
import '../features/admin/screens/admin_upload_screen.dart';
import '../features/admin/screens/admin_manage_materials_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/materials/screens/study_materials_screen.dart';
import '../features/materials/screens/pdf_viewer_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Only basic auth checks here, complex redirects are handled by SplashWrapper
    final session = Supabase.instance.client.auth.currentSession;
    final isAuth = session != null;
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation == '/register';
    final isGoingToForgotPass = state.matchedLocation == '/forgot-password';
    final isGoingToUpdatePass = state.matchedLocation == '/update-password';
    final isSplash = state.matchedLocation == '/';

    if (!isAuth && !isGoingToLogin && !isGoingToRegister && !isGoingToForgotPass && !isGoingToUpdatePass && !isSplash) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashWrapper(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/update-password',
      builder: (context, state) => const UpdatePasswordScreen(),
    ),
    GoRoute(
      path: '/create-profile',
      builder: (context, state) => const CreateProfileScreen(),
    ),
    GoRoute(
      path: '/onboarding/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding/categories',
      builder: (context, state) {
        final language = state.extra as String? ?? 'en';
        return ExamCategoryScreen(language: language);
      },
    ),
    GoRoute(
      path: '/onboarding/exams',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ExamSelectionScreen(
          language: extra['language'] ?? 'en',
          categoryId: extra['categoryId'] ?? '',
          categoryName: extra['categoryName'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/study-materials',
      builder: (context, state) => const StudyMaterialsScreen(),
    ),
    GoRoute(
      path: '/pdf-viewer',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PDFViewerScreen(
          pdfUrl: extra['url'] ?? '',
          title: extra['title'] ?? 'PDF Document',
        );
      },
    ),
    GoRoute(
      path: '/admin/manage-materials',
      builder: (context, state) => const AdminManageMaterialsScreen(),
    ),
    GoRoute(
      path: '/admin/upload',
      builder: (context, state) => const AdminUploadScreen(),
    ),
  ],
);




