import 'dart:io';

void main() {
  // 1. admin_manage_syllabus_screen.dart - value to initialValue for DropdownButtonFormField
  final adminManageSyllabus = File('d:/GOVT/govprep/lib/features/admin/screens/admin_manage_syllabus_screen.dart');
  if (adminManageSyllabus.existsSync()) {
    String c = adminManageSyllabus.readAsStringSync();
    c = c.replaceAll('value: _selectedExam,', 'initialValue: _selectedExam,');
    c = c.replaceAll('value: _selectedSubject,', 'initialValue: _selectedSubject,');
    adminManageSyllabus.writeAsStringSync(c);
  }

  // 2. report_content_sheet.dart - value to initialValue
  final reportContent = File('d:/GOVT/govprep/lib/features/reports/presentation/widgets/report_content_sheet.dart');
  if (reportContent.existsSync()) {
    String c = reportContent.readAsStringSync();
    c = c.replaceAll('value: _selectedReason,', 'initialValue: _selectedReason,');
    reportContent.writeAsStringSync(c);
  }

  // 3. settings_screen.dart
  final settingsScreen = File('d:/GOVT/govprep/lib/features/settings/presentation/screens/settings_screen.dart');
  if (settingsScreen.existsSync()) {
    String c = settingsScreen.readAsStringSync();
    c = c.replaceAll('activeColor: ', 'activeThumbColor: ');
    settingsScreen.writeAsStringSync(c);
  }

  // 4. study_planner_screen.dart - make _targetExam final
  final studyPlanner = File('d:/GOVT/govprep/lib/features/planner/presentation/screens/study_planner_screen.dart');
  if (studyPlanner.existsSync()) {
    String c = studyPlanner.readAsStringSync();
    c = c.replaceAll('String _targetExam =', 'final String _targetExam =');
    studyPlanner.writeAsStringSync(c);
  }

  // 5. plans_screen.dart - final fields
  final plansScreen = File('d:/GOVT/govprep/lib/features/subscription/presentation/screens/plans_screen.dart');
  if (plansScreen.existsSync()) {
    String c = plansScreen.readAsStringSync();
    c = c.replaceAll('String? _currentPlanId;', 'final String? _currentPlanId = null;');
    c = c.replaceAll('String _subscriptionStatus =', 'final String _subscriptionStatus =');
    c = c.replaceAll('bool _isCheckoutPending =', 'final bool _isCheckoutPending =');
    plansScreen.writeAsStringSync(c);
  }

  // 6. Remove dead code in profile_screen.dart (We will manually check what lines 277-281 are before regex replace. Let's skip for now)
  // 7. _buildPlaceholder in main_layout_screen.dart
  final mainLayout = File('d:/GOVT/govprep/lib/features/home/screens/main_layout_screen.dart');
  if (mainLayout.existsSync()) {
    String c = mainLayout.readAsStringSync();
    c = c.replaceAll(RegExp(r'Widget _buildPlaceholder.*?}', dotAll: true), '');
    mainLayout.writeAsStringSync(c);
  }

  // 8. _goToIndexInFilter in answer_review_screen.dart
  final answerReview = File('d:/GOVT/govprep/lib/features/mock_tests/presentation/screens/answer_review_screen.dart');
  if (answerReview.existsSync()) {
    String c = answerReview.readAsStringSync();
    c = c.replaceAll(RegExp(r'void _goToIndexInFilter.*?}', dotAll: true), '');
    answerReview.writeAsStringSync(c);
  }
}
