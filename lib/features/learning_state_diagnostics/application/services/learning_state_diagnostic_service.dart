import 'dart:async';
import '../../domain/models/learning_state_diagnostic_event.dart';

class LearningStateDiagnosticService {
  final _eventStreamController = StreamController<LearningStateDiagnosticEvent>.broadcast();

  Stream<LearningStateDiagnosticEvent> get eventStream => _eventStreamController.stream;

  void recordEvent(LearningStateDiagnosticEvent event) {
    // In a real application, this would pipe into the backend telemetry or observability service.
    // For now, we broadcast to local listeners (like a Developer UI or debug console).
    _eventStreamController.add(event);
  }

  void dispose() {
    _eventStreamController.close();
  }
}

final learningStateDiagnosticService = LearningStateDiagnosticService();
