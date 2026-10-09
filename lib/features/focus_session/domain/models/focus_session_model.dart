enum FocusSessionStatus {
  ready,
  running,
  paused,
  completed,
  interrupted,
}

class FocusSessionModel {
  final String id;
  final String title;
  final String exam;
  final String subject;
  final String topic;
  final String activityType; // "Practice", "Revision", "Flashcards"
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final FocusSessionStatus status;
  final int focusedSeconds;
  final String? taskReferenceId;

  FocusSessionModel({
    required this.id,
    required this.title,
    required this.exam,
    required this.subject,
    required this.topic,
    required this.activityType,
    required this.durationMinutes,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.focusedSeconds,
    this.taskReferenceId,
  });

  FocusSessionModel copyWith({
    FocusSessionStatus? status,
    int? focusedSeconds,
    DateTime? endedAt,
  }) {
    return FocusSessionModel(
      id: id,
      title: title,
      exam: exam,
      subject: subject,
      topic: topic,
      activityType: activityType,
      durationMinutes: durationMinutes,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      focusedSeconds: focusedSeconds ?? this.focusedSeconds,
      taskReferenceId: taskReferenceId,
    );
  }
}
