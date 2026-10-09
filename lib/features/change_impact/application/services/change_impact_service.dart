import 'dart:async';

import '../../domain/models/change_impact_state.dart';

class ChangeImpactService {
  final Map<String, ChangeImpactAssessment> _assessments = {};

  void initialize() {}

  void dispose() {}

  ChangeImpactAssessment? getAssessment(String changeId) => _assessments[changeId];

  /// Phase 94: Identifies change impact to determine required validation scope before release
  Future<ChangeImpactAssessment> assessImpact({
    required String changeId,
    required String baselineReleaseId,
    required bool isBaselineValid,
    required List<String> changedComponents,
  }) async {
    
    if (!isBaselineValid) {
      final blockedAssessment = ChangeImpactAssessment(
        changeId: changeId,
        baselineReleaseId: baselineReleaseId,
        status: ChangeImpactStatus.blocked,
        scope: ReleaseScopeDecision.blocked,
        blockingReason: 'Baseline is invalid (Phase 93). Cannot assess impact on a corrupt baseline.',
      );
      _assessments[changeId] = blockedAssessment;
      return blockedAssessment;
    }

    final List<String> potentialAreas = [];
    final List<String> validations = [];
    ReleaseScopeDecision scopeDecision = ReleaseScopeDecision.noImpact;

    bool hasCritical = false;
    bool hasDatabase = false;
    bool hasUI = false;
    bool hasLearningState = false;

    for (final component in changedComponents) {
      if (component == 'RLS' || component == 'Auth' || component == 'Payment') {
        hasCritical = true;
        validations.addAll(['Security Validation', 'Auth Tests', 'Payment Verification']);
      } else if (component.contains('Migration') || component.contains('Schema')) {
        hasDatabase = true;
        potentialAreas.add('All Database Queries');
        validations.add('Database/Schema Validation');
      } else if (component.contains('Question') || component.contains('Attempt') || component.contains('Performance')) {
        hasLearningState = true;
        potentialAreas.addAll(['Practice', 'Mock', 'Dashboard', 'Adaptive Difficulty']);
        validations.addAll(['Learning Pipeline Validation', 'Mock Regression', 'Attempt Integrity']);
      } else if (component.contains('UI') || component.contains('Widget')) {
        hasUI = true;
        validations.addAll(['UI Tests', 'Accessibility Tests', 'Localization Tests']);
      } else {
        potentialAreas.add('Downstream consumers of $component');
      }
    }

    // Determine Scope
    if (hasCritical) {
      scopeDecision = ReleaseScopeDecision.criticalScope;
    } else if (hasLearningState || hasDatabase) {
      scopeDecision = ReleaseScopeDecision.broadScope;
    } else if (hasUI) {
      scopeDecision = ReleaseScopeDecision.targetedScope;
    } else if (changedComponents.isNotEmpty) {
      scopeDecision = ReleaseScopeDecision.lowScope;
    }

    final assessment = ChangeImpactAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      changeId: changeId,
      baselineReleaseId: baselineReleaseId,
      status: ChangeImpactStatus.analyzed,
      scope: scopeDecision,
      directlyAffectedAreas: changedComponents,
      potentiallyAffectedAreas: potentialAreas.toSet().toList(), // deduplicate
      requiredValidations: validations.toSet().toList(),
      analyzedAt: DateTime.now(),
    );

    _assessments[changeId] = assessment;
    return assessment;
  }
}

final changeImpactService = ChangeImpactService();
