import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/composition_validation_result.dart';
import '../../../session_launcher/domain/models/study_session_configuration.dart';
import '../../../practice_composition/domain/models/practice_composition.dart';

class CompositionValidationScreen extends StatefulWidget {
  final String actionId;

  const CompositionValidationScreen({super.key, required this.actionId});

  @override
  State<CompositionValidationScreen> createState() => _CompositionValidationScreenState();
}

class _CompositionValidationScreenState extends State<CompositionValidationScreen> {
  bool _isValidating = true;
  late CompositionValidationResult _validationResult;
  late StudySessionConfiguration _config;
  PracticeComposition? _composition;

  @override
  void initState() {
    super.initState();
    _config = dummyConfiguration.copyWith(mode: 'Adaptive');
    _composition = dummyAdaptiveComposition;

    // Simulate backend validation
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _validationResult = dummyValidationResult;
          _isValidating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Validating Practice',
          style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold),
        ),
      ),
      body: _isValidating ? _buildLoading() : _buildValidationResult(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.deepPurple),
          SizedBox(height: 16),
          Text('Checking available questions...', style: TextStyle(color: Color(0xFF555555))),
        ],
      ),
    );
  }

  Widget _buildValidationResult() {
    final bool fullyAvailable = _validationResult.status == 'FullyAvailable';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(fullyAvailable),
            const SizedBox(height: 24),
            if (_validationResult.explanation != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: fullyAvailable ? const Color(0xFFE2F0D9) : const Color(0xFFFDF0D5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      fullyAvailable ? Icons.check_circle : Icons.info_outline,
                      color: fullyAvailable ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _validationResult.explanation!,
                        style: TextStyle(
                          color: fullyAvailable ? Colors.green.shade900 : Colors.orange.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text('Practice Setup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 16),
            _buildSetupSummary(),
            const SizedBox(height: 24),
            const Text('Coverage Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 16),
            ..._validationResult.coverage.map(_buildCoverageItem),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Start Practice using actual delivered context
                  context.go('/practice');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F11),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  fullyAvailable ? 'Start Practice' : 'Continue with ${_validationResult.deliveredQuestionCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (!fullyAvailable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop(); // Go back to adjust configuration
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0F0F11)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Adjust Practice', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool fullyAvailable) {
    return Row(
      children: [
        Icon(
          fullyAvailable ? Icons.check_circle : Icons.build_circle,
          color: fullyAvailable ? Colors.green : Colors.orange,
          size: 32,
        ),
        const SizedBox(width: 12),
        Text(
          fullyAvailable ? 'Practice Ready' : 'Practice Adjusted',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
      ],
    );
  }

  Widget _buildSetupSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Requested Questions', '${_validationResult.requestedQuestionCount}'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildSummaryRow(
            'Available Questions',
            '${_validationResult.availableQuestionCount}',
            isHighlight: _validationResult.availableQuestionCount < _validationResult.requestedQuestionCount,
          ),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildSummaryRow('Language', _validationResult.deliveredLanguage ?? 'N/A'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildSummaryRow('Difficulty', _validationResult.deliveredDifficulty ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF555555))),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.orange.shade800 : const Color(0xFF0F0F11),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverageItem(CompositionCoverageItem item) {
    Color iconColor;
    IconData iconData;

    switch (item.status) {
      case 'Complete':
        iconColor = Colors.green;
        iconData = Icons.check;
        break;
      case 'Partial':
      case 'Adjusted':
        iconColor = Colors.orange;
        iconData = Icons.info_outline;
        break;
      case 'Mismatch':
      case 'Unavailable':
        iconColor = Colors.red;
        iconData = Icons.close;
        break;
      default:
        iconColor = Colors.grey;
        iconData = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.attribute, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(item.details, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
