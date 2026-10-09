import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/admin/screens/admin_manage_syllabus_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/update_password_screen.dart';
import '../features/auth/screens/create_profile_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/two_factor_verification_screen.dart';
import '../features/auth/screens/splash_wrapper.dart';
import '../features/onboarding/screens/language_selection_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/onboarding_1_screen.dart';
import '../features/onboarding/screens/onboarding_2_screen.dart';
import '../features/onboarding/screens/onboarding_3_screen.dart';
import '../features/onboarding/screens/exam_category_screen.dart';
import '../features/onboarding/screens/exam_selection_screen.dart';
import '../features/onboarding/screens/preparation_level_screen.dart';
import '../features/home/screens/main_layout_screen.dart';
import '../features/admin/screens/admin_upload_screen.dart';
import '../features/admin/screens/admin_manage_materials_screen.dart';
import '../features/admin/screens/admin_manage_users_screen.dart';
import '../features/admin/screens/admin_operational_health_screen.dart';
import '../features/admin/screens/admin_recovery_verification_screen.dart';
import '../features/learning_state_reliability/domain/models/learning_state_incident.dart';
import '../features/profile/presentation/screens/exam_preferences_screen.dart';
import '../features/profile/presentation/screens/preparation_preferences_screen.dart';
import '../features/profile/presentation/screens/study_preferences_screen.dart';
import '../features/profile/presentation/screens/privacy_settings_screen.dart';
import '../features/profile/presentation/screens/language_settings_screen.dart';
import '../features/profile/presentation/screens/appearance_settings_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/settings/presentation/screens/active_sessions_screen.dart';
import '../features/settings/presentation/screens/login_activity_screen.dart';
import '../features/settings/presentation/screens/two_factor_auth_screen.dart';
import '../features/settings/presentation/screens/account_recovery_screen.dart';
import '../features/settings/presentation/screens/delete_account_screen.dart';
import '../features/help/presentation/screens/help_center_screen.dart';
import '../features/help/presentation/screens/faq_screen.dart';
import '../features/help/presentation/screens/getting_started_screen.dart';
import '../features/help/presentation/screens/exam_preparation_guide_screen.dart';
import '../features/help/presentation/screens/practice_guide_screen.dart';
import '../features/help/presentation/screens/mock_test_guide_screen.dart';
import '../features/help/presentation/screens/subscription_faq_screen.dart';
import '../features/help/presentation/screens/payment_help_screen.dart';
import '../features/help/presentation/screens/contact_support_screen.dart';
import '../features/profile/presentation/screens/academic_profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_overview_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/subscription/presentation/screens/plans_screen.dart';
import '../features/subscription/presentation/screens/checkout_screen.dart';
import '../features/subscription/presentation/screens/billing_screen.dart';
import '../features/help/presentation/screens/help_screen.dart';
import '../features/feedback/presentation/screens/feedback_screen.dart';
import '../features/planner/presentation/screens/study_planner_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/revision/presentation/screens/revision_center_screen.dart';
import '../features/current_affairs/presentation/screens/current_affairs_screen.dart';
import '../features/search/presentation/screens/global_search_screen.dart';
import '../features/practice/presentation/screens/daily_quiz_screen.dart';
import '../features/achievements/presentation/screens/achievements_screen.dart';
import '../features/calendar/presentation/screens/exam_calendar_screen.dart';
import '../features/progress/presentation/screens/roadmap_screen.dart';
import '../features/syllabus/presentation/screens/topic_workspace_screen.dart';
import '../features/syllabus/presentation/screens/subject_workspace_screen.dart';
import '../features/exam_preparation/presentation/screens/exam_preparation_dashboard.dart';
import '../features/exam_analytics/presentation/screens/exam_analytics_screen.dart';
import '../features/exam_analytics/presentation/screens/performance_comparison_screen.dart';
import '../features/exam_readiness/presentation/screens/exam_readiness_dashboard.dart';
import '../features/score_prediction/presentation/screens/score_prediction_dashboard.dart';
import '../features/ai_recommendations/presentation/screens/ai_recommendations_dashboard.dart';
import '../features/study_plan/presentation/screens/personalized_study_plan_screen.dart';
import '../features/learning_insights/presentation/screens/learning_insights_dashboard.dart';
import '../features/achievements/presentation/screens/achievements_dashboard.dart';
import '../features/badges/presentation/screens/badges_dashboard.dart';
import '../features/streaks/presentation/screens/streaks_dashboard.dart';
import '../features/gamification/presentation/screens/xp_levels_dashboard.dart';
import '../features/gamification/presentation/screens/daily_challenges_dashboard.dart';
import '../features/gamification/presentation/screens/weekly_challenges_dashboard.dart';
import '../features/gamification/presentation/screens/monthly_challenges_dashboard.dart';
import '../features/community/presentation/screens/study_community_screen.dart';
import '../features/gamification/presentation/screens/motivation_center_screen.dart';
import '../features/gamification/presentation/screens/milestones_dashboard.dart';
import '../features/gamification/presentation/screens/rewards_center_screen.dart';
import '../features/gamification/presentation/screens/gamification_history_screen.dart';
import '../features/subscription/presentation/screens/plan_comparison_screen.dart';
import '../features/subscription/presentation/screens/premium_benefits_screen.dart';
import '../features/subscription/presentation/screens/payment_method_screen.dart';
import '../features/subscription/presentation/screens/payment_processing_screen.dart';
import '../features/subscription/presentation/screens/payment_success_screen.dart';
import '../features/subscription/presentation/screens/payment_failed_screen.dart';
import '../features/subscription/presentation/screens/subscription_active_screen.dart';
import '../features/subscription/presentation/screens/subscription_management_screen.dart';
import '../features/subscription/presentation/screens/invoices_screen.dart';
import '../features/subscription/presentation/screens/cancel_renew_subscription_screen.dart';
import '../features/notifications/presentation/screens/notification_center_screen.dart';
import '../features/notifications/presentation/screens/notification_details_screen.dart';
import '../features/notifications/presentation/screens/exam_reminder_screen.dart';
import '../features/notifications/presentation/screens/study_reminder_screen.dart';
import '../features/notifications/presentation/screens/daily_goal_reminder_screen.dart';
import '../features/notifications/presentation/screens/mock_test_reminder_screen.dart';
import '../features/notifications/presentation/screens/current_affairs_alert_screen.dart';
import '../features/notifications/presentation/screens/achievement_notification_screen.dart';
import '../features/notifications/presentation/screens/subscription_notifications_screen.dart';
import '../features/notifications/presentation/screens/system_announcements_screen.dart';
import '../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../features/notifications/presentation/screens/email_preferences_screen.dart';
import '../features/notifications/presentation/screens/notification_history_screen.dart';
import '../features/gamification/presentation/screens/leaderboard_screen.dart';
import '../features/flashcards/presentation/screens/flashcards_screen.dart';
import '../features/flashcards/presentation/screens/flashcard_session_screen.dart';
import '../features/syllabus/presentation/screens/exam_syllabus_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/materials/screens/study_materials_screen.dart';
import '../features/materials/screens/pdf_viewer_screen.dart';
import '../features/exams/presentation/screens/exam_details_screen.dart';
import '../features/practice/presentation/screens/practice_arena_screen.dart';
import '../features/mock_tests/presentation/screens/mock_test_center_screen.dart';
import '../features/mock_tests/presentation/screens/mock_test_runner_screen.dart';
import '../features/mock_tests/presentation/screens/mock_test_results_screen.dart';
import '../features/mock_tests/presentation/screens/answer_review_screen.dart';
import '../features/mistake_notebook/presentation/screens/mistake_notebook_screen.dart';
import '../features/mistake_notebook/presentation/screens/mistake_detail_screen.dart';
import '../features/mistake_notebook/domain/models/mistake_record.dart';
import '../features/question_bank/presentation/screens/question_bank_screen.dart';
import '../features/question_bank/presentation/screens/question_detail_screen.dart';

import '../features/focus_session/presentation/screens/focus_session_setup_screen.dart';
import '../features/focus_session/presentation/screens/focus_session_screen.dart';
import '../features/focus_session/presentation/screens/focus_session_summary_screen.dart';
import '../features/focus_session/domain/models/focus_session_model.dart';
import '../features/smart_revision/presentation/screens/smart_revision_screen.dart';
import '../features/reassessment/presentation/screens/adaptive_reassessment_screen.dart';
import '../features/preparation_health/presentation/screens/preparation_health_screen.dart';
import '../features/next_step/presentation/screens/next_step_screen.dart';
import '../features/next_step/presentation/screens/action_outcome_screen.dart';
import '../features/personalization/presentation/screens/personalization_screen.dart';
import '../features/session_launcher/presentation/screens/session_launcher_screen.dart';
import '../features/skill_progression/presentation/screens/skill_progression_screen.dart';
import '../features/adaptive_practice_outcome/presentation/screens/adaptive_practice_outcome_screen.dart';
import '../features/composition_validation/presentation/screens/composition_validation_screen.dart';
import '../features/learning_state_diagnostics/presentation/screens/learning_state_diagnostics_screen.dart';

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
    final isGoingToWelcome = state.matchedLocation == '/welcome';
    final isGoingToOnboarding = state.matchedLocation.startsWith('/onboarding');
    final isGoingToOtp = state.matchedLocation == '/otp-verification';
    final isSplash = state.matchedLocation == '/';

    if (!isAuth && !isGoingToLogin && !isGoingToRegister && !isGoingToForgotPass && !isGoingToUpdatePass && !isSplash && !isGoingToWelcome && !isGoingToOnboarding && !isGoingToOtp) {
      return '/welcome';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashWrapper(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding/1',
      builder: (context, state) => const Onboarding1Screen(),
    ),
    GoRoute(
      path: '/onboarding/2',
      builder: (context, state) => const Onboarding2Screen(),
    ),
    GoRoute(
      path: '/onboarding/3',
      builder: (context, state) => const Onboarding3Screen(),
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
      path: '/otp-verification',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/2fa-verification',
      builder: (context, state) => const TwoFactorVerificationScreen(),
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
      path: '/onboarding/preparation',
      builder: (context, state) => const PreparationLevelScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/manage-syllabus',
      builder: (context, state) => const AdminManageSyllabusScreen(),
    ),
    GoRoute(
      path: '/admin/operational-health',
      builder: (context, state) => const AdminOperationalHealthScreen(),
    ),
    GoRoute(
      path: '/admin/recovery-verification',
      builder: (context, state) {
        final incident = state.extra as LearningStateIncident;
        return AdminRecoveryVerificationScreen(incident: incident);
      },
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
    GoRoute(
      path: '/admin/manage-users',
      builder: (context, state) => const AdminManageUsersScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileOverviewScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/settings/active-sessions',
      builder: (context, state) => const ActiveSessionsScreen(),
    ),
    GoRoute(
      path: '/settings/login-activity',
      builder: (context, state) => const LoginActivityScreen(),
    ),
    GoRoute(
      path: '/settings/two-factor-auth',
      builder: (context, state) => const TwoFactorAuthScreen(),
    ),
    GoRoute(
      path: '/settings/account-recovery',
      builder: (context, state) => const AccountRecoveryScreen(),
    ),
    GoRoute(
      path: '/settings/delete-account',
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/help/faq',
      builder: (context, state) => const FaqScreen(),
    ),
    GoRoute(
      path: '/help/getting-started',
      builder: (context, state) => const GettingStartedScreen(),
    ),
    GoRoute(
      path: '/help/exam-preparation-guide',
      builder: (context, state) => const ExamPreparationGuideScreen(),
    ),
    GoRoute(
      path: '/help/practice-guide',
      builder: (context, state) => const PracticeGuideScreen(),
    ),
    GoRoute(
      path: '/help/mock-test-guide',
      builder: (context, state) => const MockTestGuideScreen(),
    ),
    GoRoute(
      path: '/help/subscription-faq',
      builder: (context, state) => const SubscriptionFaqScreen(),
    ),
    GoRoute(
      path: '/help/payment-help',
      builder: (context, state) => const PaymentHelpScreen(),
    ),
    GoRoute(
      path: '/help/contact-support',
      builder: (context, state) => const ContactSupportScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/academic',
      builder: (context, state) => const AcademicProfileScreen(),
    ),
    GoRoute(
      path: '/profile/exam-preferences',
      builder: (context, state) => const ExamPreferencesScreen(),
    ),
    GoRoute(
      path: '/profile/preparation',
      builder: (context, state) => const PreparationPreferencesScreen(),
    ),
    GoRoute(
      path: '/profile/language',
      builder: (context, state) => const LanguageSettingsScreen(),
    ),
    GoRoute(
      path: '/profile/appearance',
      builder: (context, state) => const AppearanceSettingsScreen(),
    ),
    GoRoute(
      path: '/profile/study-preferences',
      builder: (context, state) => const StudyPreferencesScreen(),
    ),
    GoRoute(
      path: '/profile/privacy',
      builder: (context, state) => const PrivacySettingsScreen(),
    ),
    GoRoute(
      path: '/exams/:id',
      builder: (context, state) {
        final examId = state.pathParameters['id'] ?? '';
        return ExamDetailsScreen(examId: examId);
      },
    ),
    GoRoute(
      path: '/practice',
      builder: (context, state) => const PracticeArenaScreen(),
    ),
    GoRoute(
      path: '/mock-tests',
      builder: (context, state) => const MockTestCenterScreen(),
    ),
    GoRoute(
      path: '/mock-tests/runner/:id',
      builder: (context, state) {
        final testId = state.pathParameters['id'] ?? '';
        return MockTestRunnerScreen(testId: testId);
      },
    ),
    GoRoute(
      path: '/mock-tests/results/:id',
      builder: (context, state) {
        final testId = state.pathParameters['id'] ?? '';
        return MockTestResultsScreen(testId: testId);
      },
    ),
    GoRoute(
      path: '/mock-tests/review/:id',
      builder: (context, state) {
        final testId = state.pathParameters['id'] ?? '';
        return AnswerReviewScreen(testId: testId);
      },
    ),
    GoRoute(
      path: '/revision/smart',
      builder: (context, state) => const SmartRevisionScreen(),
    ),
    GoRoute(
      path: '/reassessment',
      builder: (context, state) => const AdaptiveReassessmentScreen(),
    ),
    GoRoute(
      path: '/preparation-health',
      builder: (context, state) => const PreparationHealthScreen(),
    ),
    GoRoute(
      path: '/next-step',
      builder: (context, state) => const NextStepScreen(),
    ),
    GoRoute(
      path: '/next-step/outcome/:actionId',
      builder: (context, state) {
        final actionId = state.pathParameters['actionId']!;
        return ActionOutcomeScreen(actionId: actionId);
      },
    ),
    GoRoute(
      path: '/session-launcher/:actionId',
      builder: (context, state) {
        final actionId = state.pathParameters['actionId']!;
        return SessionLauncherScreen(actionId: actionId);
      },
    ),
    GoRoute(
      path: '/personalization',
      builder: (context, state) => const PersonalizationScreen(),
    ),
    GoRoute(
      path: '/mistake-notebook',
      builder: (context, state) => const MistakeNotebookScreen(),
    ),
    GoRoute(
      path: '/mistakes/:id',
      builder: (context, state) {
        final mistake = state.extra as MistakeRecord;
        return MistakeDetailScreen(mistake: mistake);
      },
    ),
    GoRoute(
      path: '/focus/setup',
      builder: (context, state) => const FocusSessionSetupScreen(),
    ),
    GoRoute(
      path: '/focus/active',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return FocusSessionScreen(sessionData: data);
      },
    ),
    GoRoute(
      path: '/focus/summary',
      builder: (context, state) {
        final session = state.extra as FocusSessionModel;
        return FocusSessionSummaryScreen(session: session);
      },
    ),
    GoRoute(
      path: '/question-bank',
      builder: (context, state) => const QuestionBankScreen(),
    ),
    GoRoute(
      path: '/question-bank/:id',
      builder: (context, state) {
        final questionId = state.pathParameters['id'] ?? '';
        return QuestionDetailScreen(questionId: questionId);
      },
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/plans',
      builder: (context, state) => const PlansScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final planId = state.uri.queryParameters['planId'] ?? '';
        final billingPeriod = state.uri.queryParameters['billingPeriod'] ?? 'Monthly';
        final planName = state.uri.queryParameters['planName'] ?? 'Unknown';
        final price = state.uri.queryParameters['price'] ?? '₹0';
        return CheckoutScreen(
          planId: planId,
          billingPeriod: billingPeriod,
          planName: planName,
          price: price,
        );
      },
    ),
    GoRoute(
      path: '/payment-method',
      builder: (context, state) {
        final planId = state.uri.queryParameters['planId'] ?? '';
        final amount = state.uri.queryParameters['amount'] ?? '0.00';
        return PaymentMethodScreen(
          planId: planId,
          amount: amount,
        );
      },
    ),
    GoRoute(
      path: '/payment-processing',
      builder: (context, state) {
        final methodId = state.uri.queryParameters['methodId'] ?? '';
        final amount = state.uri.queryParameters['amount'] ?? '0.00';
        final planId = state.uri.queryParameters['planId'] ?? '';
        return PaymentProcessingScreen(
          methodId: methodId,
          amount: amount,
          planId: planId,
        );
      },
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) {
        final transactionId = state.uri.queryParameters['transactionId'] ?? '';
        final planId = state.uri.queryParameters['planId'] ?? '';
        final amount = state.uri.queryParameters['amount'] ?? '0.00';
        return PaymentSuccessScreen(
          transactionId: transactionId,
          planId: planId,
          amount: amount,
        );
      },
    ),
    GoRoute(
      path: '/payment-failed',
      builder: (context, state) {
        final transactionId = state.uri.queryParameters['transactionId'] ?? '';
        final planId = state.uri.queryParameters['planId'] ?? '';
        final amount = state.uri.queryParameters['amount'] ?? '0.00';
        final reasonCode = state.uri.queryParameters['reasonCode'] ?? 'unknown';
        return PaymentFailedScreen(
          transactionId: transactionId,
          planId: planId,
          amount: amount,
          reasonCode: reasonCode,
        );
      },
    ),
    GoRoute(
      path: '/subscription-active',
      builder: (context, state) => const SubscriptionActiveScreen(),
    ),
    GoRoute(
      path: '/subscription-management',
      builder: (context, state) => const SubscriptionManagementScreen(),
    ),
    GoRoute(
      path: '/billing',
      builder: (context, state) => const BillingScreen(),
    ),
    GoRoute(
      path: '/invoices',
      builder: (context, state) => const InvoicesScreen(),
    ),
    GoRoute(
      path: '/cancel-renew',
      builder: (context, state) => const CancelRenewSubscriptionScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    GoRoute(
      path: '/notifications/:id',
      builder: (context, state) => NotificationDetailsScreen(
        notificationId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/exam-reminder/:id',
      builder: (context, state) => ExamReminderScreen(
        examId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/study-reminder/:id',
      builder: (context, state) => StudyReminderScreen(
        reminderId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/daily-goal-reminder/:id',
      builder: (context, state) => DailyGoalReminderScreen(
        reminderId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/mock-test-reminder/:id',
      builder: (context, state) => MockTestReminderScreen(
        reminderId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/current-affairs-alert/:id',
      builder: (context, state) => CurrentAffairsAlertScreen(
        alertId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/achievement-notification/:id',
      builder: (context, state) => AchievementNotificationScreen(
        notificationId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/subscription-notifications',
      builder: (context, state) => const SubscriptionNotificationsScreen(),
    ),
    GoRoute(
      path: '/system-announcements',
      builder: (context, state) => const SystemAnnouncementsScreen(),
    ),
    GoRoute(
      path: '/notification-preferences',
      builder: (context, state) => const NotificationPreferencesScreen(),
    ),
    GoRoute(
      path: '/email-preferences',
      builder: (context, state) => const EmailPreferencesScreen(),
    ),
    GoRoute(
      path: '/notification-history',
      builder: (context, state) => const NotificationHistoryScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) {
        final questionId = state.uri.queryParameters['questionId'];
        final transactionId = state.uri.queryParameters['transactionId'];
        return FeedbackScreen(
          questionId: questionId,
          transactionId: transactionId,
        );
      },
    ),
    GoRoute(
      path: '/study-planner',
      builder: (context, state) => const StudyPlannerScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/revision',
      builder: (context, state) => const RevisionCenterScreen(),
    ),
    GoRoute(
      path: '/current-affairs',
      builder: (context, state) => const CurrentAffairsScreen(),
    ),
    GoRoute(
      path: '/syllabus',
      builder: (context, state) => const ExamSyllabusScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => GlobalSearchScreen(
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(
      path: '/daily-quiz',
      builder: (context, state) => const DailyQuizScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/exam-calendar',
      builder: (context, state) => const ExamCalendarScreen(),
    ),
    GoRoute(
      path: '/roadmap',
      builder: (context, state) => const RoadmapScreen(),
    ),
    GoRoute(
      path: '/exams/:examId/dashboard',
      builder: (context, state) => ExamPreparationDashboard(
        examId: state.pathParameters['examId'] ?? 'unknown',
      ),
    ),
    GoRoute(
      path: '/exams/:examId/analytics',
      builder: (context, state) => ExamAnalyticsScreen(
        examId: state.pathParameters['examId'] ?? 'unknown',
      ),
    ),
    GoRoute(
      path: '/performance-comparison',
      builder: (context, state) => const PerformanceComparisonScreen(),
    ),
    GoRoute(
      path: '/exam-readiness',
      builder: (context, state) => const ExamReadinessDashboard(),
    ),
    GoRoute(
      path: '/score-prediction',
      builder: (context, state) => const ScorePredictionDashboard(),
    ),
    GoRoute(
      path: '/ai-recommendations',
      builder: (context, state) => const AiRecommendationsDashboard(),
    ),
    GoRoute(
      path: '/study-plan',
      builder: (context, state) => const PersonalizedStudyPlanScreen(),
    ),
    GoRoute(
      path: '/learning-insights',
      builder: (context, state) => const LearningInsightsDashboard(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsDashboard(),
    ),
    GoRoute(
      path: '/badges',
      builder: (context, state) => const BadgesDashboard(),
    ),
    GoRoute(
      path: '/streaks',
      builder: (context, state) => const StreaksDashboard(),
    ),
    GoRoute(
      path: '/gamification',
      builder: (context, state) => const XpLevelsDashboard(),
    ),
    GoRoute(
      path: '/daily-challenges',
      builder: (context, state) => const DailyChallengesDashboard(),
    ),
    GoRoute(
      path: '/weekly-challenges',
      builder: (context, state) => const WeeklyChallengesDashboard(),
    ),
    GoRoute(
      path: '/monthly-challenges',
      builder: (context, state) => const MonthlyChallengesDashboard(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const StudyCommunityScreen(),
    ),
    GoRoute(
      path: '/motivation',
      builder: (context, state) => const MotivationCenterScreen(),
    ),
    GoRoute(
      path: '/milestones',
      builder: (context, state) => const MilestonesDashboard(),
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => const RewardsCenterScreen(),
    ),
    GoRoute(
      path: '/gamification-history',
      builder: (context, state) => const GamificationHistoryScreen(),
    ),
    GoRoute(
      path: '/plan-comparison',
      builder: (context, state) => const PlanComparisonScreen(),
    ),
    GoRoute(
      path: '/premium-benefits',
      builder: (context, state) => const PremiumBenefitsScreen(),
    ),
    GoRoute(
      path: '/subjects/:subjectId',
      builder: (context, state) => SubjectWorkspaceScreen(
        subjectId: state.pathParameters['subjectId'] ?? 'unknown',
      ),
    ),
    GoRoute(
      path: '/topics/:topicId',
      builder: (context, state) => TopicWorkspaceScreen(
        topicId: state.pathParameters['topicId'] ?? 'unknown',
      ),
    ),
    GoRoute(
      path: '/flashcards',
      builder: (context, state) => const FlashcardsScreen(),
    ),
    GoRoute(
      path: '/flashcards/session',
      builder: (context, state) {
        final source = state.uri.queryParameters['source'] ?? 'all';
        return FlashcardSessionScreen(source: source);
      },
    ),
    GoRoute(
      path: '/skill-progression',
      builder: (context, state) => const SkillProgressionScreen(),
    ),
    GoRoute(
      path: '/adaptive-outcome/:sessionId',
      builder: (context, state) => AdaptivePracticeOutcomeScreen(
        sessionId: state.pathParameters['sessionId'] ?? 'unknown',
      ),
    ),
    GoRoute(
      path: '/practice/validate',
      builder: (context, state) => const CompositionValidationScreen(
        actionId: 'practice',
      ),
    ),
    GoRoute(
      path: '/diagnostics',
      builder: (context, state) => const LearningStateDiagnosticsScreen(),
    ),
  ],
);


