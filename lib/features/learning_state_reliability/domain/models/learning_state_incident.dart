enum LearningStateOperationalStatus {
  healthy,
  degraded,
  delayed,
  partiallyUnavailable,
  incident,
  unknown,
}

enum IncidentSeverity {
  low,
  medium,
  high,
  critical,
}

enum IncidentStatus {
  detected,
  acknowledged,
  recovering,
  resolved,
  suppressed,
}

class LearningStateIncident {
  final String id;
  final String type;
  final IncidentSeverity severity;
  IncidentStatus status;
  final String? scopeType;
  final String? scopeId;
  final String? operationId;
  final DateTime detectedAt;
  DateTime? resolvedAt;

  LearningStateIncident({
    required this.id,
    required this.type,
    required this.severity,
    required this.status,
    this.scopeType,
    this.scopeId,
    this.operationId,
    required this.detectedAt,
    this.resolvedAt,
  });

  String get fingerprint => '${type}_${scopeType}_$scopeId';

  @override
  String toString() {
    return 'Incident [$id] $type (Severity: ${severity.name}, Status: ${status.name}) Scope: $scopeType:$scopeId';
  }
}
