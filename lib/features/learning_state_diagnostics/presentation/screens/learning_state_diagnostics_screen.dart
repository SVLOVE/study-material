import 'package:flutter/material.dart';
import '../../domain/models/learning_state_diagnostic_event.dart';
import '../../application/services/learning_state_diagnostic_service.dart';
import 'package:intl/intl.dart';

class LearningStateDiagnosticsScreen extends StatefulWidget {
  const LearningStateDiagnosticsScreen({super.key});

  @override
  State<LearningStateDiagnosticsScreen> createState() => _LearningStateDiagnosticsScreenState();
}

class _LearningStateDiagnosticsScreenState extends State<LearningStateDiagnosticsScreen> {
  final List<LearningStateDiagnosticEvent> _events = [];

  @override
  void initState() {
    super.initState();
    learningStateDiagnosticService.eventStream.listen((LearningStateDiagnosticEvent event) {
      if (mounted) {
        setState(() {
          _events.insert(0, event); // Add to top
        });
      }
    });
  }

  Color _getStatusColor(DiagnosticEventStatus status) {
    switch (status) {
      case DiagnosticEventStatus.success:
        return Colors.green;
      case DiagnosticEventStatus.stale:
      case DiagnosticEventStatus.pending:
        return Colors.orange;
      case DiagnosticEventStatus.failed:
      case DiagnosticEventStatus.invalid:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7), // GovPrep Lavender background
      appBar: AppBar(
        title: const Text('Developer Diagnostics', style: TextStyle(color: Color(0xFF0F0F11))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F0F11)),
      ),
      body: _events.isEmpty
          ? const Center(child: Text('No diagnostic events yet.', style: TextStyle(color: Color(0xFF555555))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              event.eventType,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(event.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(event.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (event.operationId != null)
                          Text('Op ID: ${event.operationId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (event.stateVersion != null)
                          Text('Version: ${event.stateVersion}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (event.scopeType != null)
                          Text('Scope: ${event.scopeType} / ${event.scopeId ?? "N/A"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (event.failureCategory != DiagnosticFailureCategory.none)
                          Text('Failure: ${event.failureCategory.name}', style: const TextStyle(fontSize: 12, color: Colors.red)),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('HH:mm:ss.SSS').format(event.occurredAt),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
