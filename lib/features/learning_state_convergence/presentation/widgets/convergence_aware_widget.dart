import 'package:flutter/material.dart';
import '../../domain/models/learning_state_convergence_status.dart';
import '../../application/services/learning_state_convergence_service.dart';

class ConvergenceAwareWidget extends StatelessWidget {
  final String scopeType;
  final String? scopeId;
  final String consumerStateVersion;
  final Widget child;

  const ConvergenceAwareWidget({
    Key? key,
    required this.scopeType,
    this.scopeId,
    required this.consumerStateVersion,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = learningStateConvergenceService.verifyConvergence(
      scopeType: scopeType,
      scopeId: scopeId,
      consumerStateVersion: consumerStateVersion,
    );

    if (status == ConsumerConvergenceStatus.converged || status == ConsumerConvergenceStatus.notApplicable) {
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusBanner(context, status),
        const SizedBox(height: 8),
        Opacity(
          opacity: 0.6,
          child: child,
        ),
      ],
    );
  }

  Widget _buildStatusBanner(BuildContext context, ConsumerConvergenceStatus status) {
    String message;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case ConsumerConvergenceStatus.pending:
        message = 'Your latest activity is still being processed.';
        backgroundColor = const Color(0xFFE2ECE9); // Muted Teal
        textColor = const Color(0xFF0F0F11);
        break;
      case ConsumerConvergenceStatus.stale:
        message = 'New progress is available. Updating your progress...';
        backgroundColor = const Color(0xFFFDF0D5); // Soft Yellow
        textColor = const Color(0xFF0F0F11);
        break;
      case ConsumerConvergenceStatus.failed:
      case ConsumerConvergenceStatus.unavailable:
        message = 'Unable to refresh your progress.';
        backgroundColor = const Color(0xFFFDECEA);
        textColor = const Color(0xFFC62828);
        break;
      default:
        message = '';
        backgroundColor = Colors.transparent;
        textColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (status == ConsumerConvergenceStatus.pending || status == ConsumerConvergenceStatus.stale)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (status == ConsumerConvergenceStatus.pending || status == ConsumerConvergenceStatus.stale)
            const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
