import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/study_session_configuration.dart';
import '../../../adaptive_difficulty/domain/models/adaptive_difficulty_state.dart';
import '../../../practice_composition/domain/models/practice_composition.dart';

class SessionLauncherScreen extends StatefulWidget {
  final String actionId;

  const SessionLauncherScreen({super.key, required this.actionId});

  @override
  State<SessionLauncherScreen> createState() => _SessionLauncherScreenState();
}

class _SessionLauncherScreenState extends State<SessionLauncherScreen> {
  late StudySessionConfiguration _config;
  AdaptiveDifficultyState? _adaptiveState;
  PracticeComposition? _composition;
  bool _useAdaptiveDifficulty = true;

  @override
  void initState() {
    super.initState();
    // Simulate resolving configuration from Phase 60 Context & Phase 58 Action
    _config = dummyConfiguration.copyWith(mode: 'Adaptive');
    _adaptiveState = dummyAdaptiveState;
    _composition = dummyAdaptiveComposition;
    
    // Auto-apply recommended difficulty if adaptive state is present
    if (_adaptiveState != null) {
      _config = _config.copyWith(difficulty: _adaptiveState!.recommendedDifficulty);
    }
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
          'Session Setup',
          style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A practice session shaped by your current preparation.',
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 24),
              const Text('Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              _buildConfigurationCard(),
              const SizedBox(height: 24),
              if (_config.mode == 'Adaptive' && _composition != null) ...[
                const Text('Practice Composition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 16),
                _buildCompositionCard(),
                const SizedBox(height: 24),
                if (_composition!.explanation != null) ...[
                  const Text('Why this practice?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                  const SizedBox(height: 8),
                  Text(_composition!.explanation!, style: const TextStyle(fontSize: 14, color: Color(0xFF555555))),
                  const SizedBox(height: 32),
                ],
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to validation before practice
                    context.go('/practice/validate');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Start Practice', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildDropdownRow('Language', _config.language, ['English', 'Tamil'], (val) {
            if (val != null) setState(() => _config = _config.copyWith(language: val));
          }),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildDropdownRow('Practice mode', _config.mode, ['Manual', 'Balanced', 'Adaptive'], (val) {
            if (val != null) setState(() => _config = _config.copyWith(mode: val));
          }),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildDropdownRow('Questions', _config.questionCount.toString(), ['10', '15', '25', '50'], (val) {
            if (val != null) setState(() => _config = _config.copyWith(questionCount: int.parse(val)));
          }),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildDifficultySection(),
        ],
      ),
    );
  }

  Widget _buildCompositionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _composition!.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2ECE9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.questionCount} Qs',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.sourceType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
                      if (item.reason != null) ...[
                        const SizedBox(height: 4),
                        Text(item.reason!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Difficulty', style: TextStyle(fontSize: 16, color: Color(0xFF0F0F11))),
              DropdownButton<String>(
                value: _config.difficulty,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _config = _config.copyWith(difficulty: val);
                      if (_adaptiveState != null && val != _adaptiveState!.recommendedDifficulty) {
                        _useAdaptiveDifficulty = false;
                      } else {
                        _useAdaptiveDifficulty = true;
                      }
                    });
                  }
                },
                items: ['Easy', 'Medium', 'Hard'].map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              ),
            ],
          ),
          if (_adaptiveState != null && _useAdaptiveDifficulty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE4DBF6).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Adaptive: ${_adaptiveState!.currentDifficulty} → ${_adaptiveState!.recommendedDifficulty}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _adaptiveState!.reason ?? 'Based on recent performance.',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11))),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            onChanged: onChanged,
            items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
          ),
        ],
      ),
    );
  }
}
