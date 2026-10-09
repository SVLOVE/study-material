import 'package:flutter/material.dart';
import '../../learning_state_reliability/domain/models/learning_state_incident.dart';
import '../../learning_state_reliability/application/services/learning_state_reliability_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminOperationalHealthScreen extends StatefulWidget {
  const AdminOperationalHealthScreen({super.key});

  @override
  State<AdminOperationalHealthScreen> createState() => _AdminOperationalHealthScreenState();
}

class _AdminOperationalHealthScreenState extends State<AdminOperationalHealthScreen> {
  List<LearningStateIncident> _activeIncidents = [];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    
    learningStateReliabilityService.incidentStream.listen((_) {
      if (mounted) {
        _loadIncidents();
      }
    });
  }

  void _loadIncidents() {
    setState(() {
      _activeIncidents = learningStateReliabilityService.activeIncidents
          .where((i) => i.status != IncidentStatus.resolved)
          .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    });
  }

  Color _getSeverityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.low: return Colors.blue;
      case IncidentSeverity.medium: return Colors.orange;
      case IncidentSeverity.high: return Colors.red;
      case IncidentSeverity.critical: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7), // GovPrep Lavender background
      appBar: AppBar(
        title: const Text('Operational Health', style: TextStyle(color: Color(0xFF0F0F11))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F0F11)),
      ),
      body: _activeIncidents.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text('System is Healthy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  Text('No active operational incidents.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _activeIncidents.length,
              itemBuilder: (context, index) {
                final incident = _activeIncidents[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/admin/recovery-verification', extra: incident);
                  },
                  child: Card(
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
                            Expanded(
                              child: Text(
                                incident.type,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(incident.severity).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                incident.severity.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getSeverityColor(incident.severity),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Status: ${incident.status.name.toUpperCase()}', style: const TextStyle(fontSize: 14)),
                        if (incident.scopeType != null)
                          Text('Scope: ${incident.scopeType} / ${incident.scopeId ?? "Global"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (incident.operationId != null)
                          Text('Last Op: ${incident.operationId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          'Detected: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(incident.detectedAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ),
                );
              },
            ),
    );
  }
}
