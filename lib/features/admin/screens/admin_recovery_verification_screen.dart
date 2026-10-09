import 'dart:async';
import 'package:flutter/material.dart';
import '../../learning_state_reliability/domain/models/learning_state_incident.dart';
import '../../learning_state_recovery_verification/application/services/learning_state_recovery_verification_service.dart';
import '../../learning_state_recovery_verification/domain/models/learning_state_recovery_verification.dart';

class AdminRecoveryVerificationScreen extends StatefulWidget {
  final LearningStateIncident incident;
  const AdminRecoveryVerificationScreen({super.key, required this.incident});

  @override
  State<AdminRecoveryVerificationScreen> createState() => _AdminRecoveryVerificationScreenState();
}

class _AdminRecoveryVerificationScreenState extends State<AdminRecoveryVerificationScreen> {
  LearningStateRecoveryVerification? _verification;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _verification = learningStateRecoveryVerificationService.getActiveVerification(widget.incident.id);
    
    _subscription = learningStateRecoveryVerificationService.verificationStream.listen((update) {
      if (update.incidentId == widget.incident.id && mounted) {
        setState(() {
          _verification = update;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        title: const Text('Recovery Verification', style: TextStyle(color: Color(0xFF0F0F11))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F0F11)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Incident: ${widget.incident.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Scope: ${widget.incident.scopeType} / ${widget.incident.scopeId ?? "Global"}'),
                    Text('Severity: ${widget.incident.severity.name.toUpperCase()}'),
                    Text('Status: ${widget.incident.status.name.toUpperCase()}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_verification != null) ...[
              const Text('Recovery Verification Progress:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildCheckRow('Publication Verified', _verification!.publicationVerified),
              _buildCheckRow('Distribution Verified', _verification!.distributionVerified),
              _buildCheckRow('Convergence Verified', _verification!.convergenceVerified),
              const SizedBox(height: 20),
              if (_verification!.isFullyVerified)
                const Center(
                  child: Text('Incident Resolved Successfully', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3460),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  learningStateRecoveryVerificationService.verifyRecoveryForIncident(widget.incident);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recovery verification started.')),
                  );
                },
                child: const Text('Start Verification', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(String label, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(isVerified ? Icons.check_circle : Icons.radio_button_unchecked, color: isVerified ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
