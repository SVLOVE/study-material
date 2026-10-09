enum ValidationPlanStatus {
  notRequired,
  draft,
  ready,
  inProgress,
  partiallyComplete,
  complete,
  blocked,
  failed,
  stale,
  insufficientEvidence,
  unknown,
}

enum ValidationItemStatus {
  notRequired,
  pending,
  ready,
  running,
  passed,
  failed,
  blocked,
  skipped,
  stale,
  insufficientEvidence,
  unknown,
}

class ValidationItem {
  final String id;
  final String category;
  final String name;

  final ValidationItemStatus status;
  final bool required;
  final List<String> dependencies;

  final String? resultReference;

  const ValidationItem({
    required this.id,
    required this.category,
    required this.name,
    this.status = ValidationItemStatus.pending,
    this.required = true,
    this.dependencies = const [],
    this.resultReference,
  });

  ValidationItem copyWith({
    String? id,
    String? category,
    String? name,
    ValidationItemStatus? status,
    bool? required,
    List<String>? dependencies,
    String? resultReference,
  }) {
    return ValidationItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      status: status ?? this.status,
      required: required ?? this.required,
      dependencies: dependencies ?? this.dependencies,
      resultReference: resultReference ?? this.resultReference,
    );
  }
}

class ReleaseValidationPlan {
  final String id;
  final String changeId;
  final String impactAssessmentId;

  final ValidationPlanStatus status;
  final List<ValidationItem> items;
  final String? blockingReason;

  const ReleaseValidationPlan({
    required this.id,
    required this.changeId,
    required this.impactAssessmentId,
    this.status = ValidationPlanStatus.unknown,
    this.items = const [],
    this.blockingReason,
  });

  ReleaseValidationPlan copyWith({
    String? id,
    String? changeId,
    String? impactAssessmentId,
    ValidationPlanStatus? status,
    List<ValidationItem>? items,
    String? blockingReason,
  }) {
    return ReleaseValidationPlan(
      id: id ?? this.id,
      changeId: changeId ?? this.changeId,
      impactAssessmentId: impactAssessmentId ?? this.impactAssessmentId,
      status: status ?? this.status,
      items: items ?? this.items,
      blockingReason: blockingReason ?? this.blockingReason,
    );
  }
}
