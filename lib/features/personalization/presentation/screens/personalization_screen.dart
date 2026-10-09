import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/preparation_preference.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  bool _usePersonalization = true;

  @override
  Widget build(BuildContext context) {
    final preferences = dummyPreferences;

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
          'Your Preparation Preferences',
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
                'GovPrep AI learns from how you prepare to make your study experience more relevant.',
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 32),
              ...preferences.map((pref) => _buildPreferenceCard(pref)),
              const SizedBox(height: 32),
              _buildControlSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(PreparationPreference preference) {
    IconData icon;
    switch (preference.preferenceType) {
      case 'language':
        icon = Icons.language;
        break;
      case 'studyPattern':
        icon = Icons.nightlight_round;
        break;
      case 'practiceStyle':
        icon = Icons.category;
        break;
      case 'sessionPattern':
        icon = Icons.timer;
        break;
      default:
        icon = Icons.insights;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatLabel(preference.preferenceType),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
                ),
              ),
              if (preference.isUserControlled)
                TextButton(
                  onPressed: () {
                    // Navigate to settings page
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(preference.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(preference.description, style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(preference.observationSource, style: const TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String type) {
    switch (type) {
      case 'language': return 'Language';
      case 'studyPattern': return 'Study Pattern';
      case 'practiceStyle': return 'Practice Style';
      case 'sessionPattern': return 'Session Pattern';
      default: return 'Preference';
    }
  }

  Widget _buildControlSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personalization Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use my preparation activity for personalization', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            value: _usePersonalization,
            onChanged: (val) {
              setState(() {
                _usePersonalization = val;
              });
            },
            activeColor: Colors.deepPurple,
            contentPadding: EdgeInsets.zero,
          ),
          if (!_usePersonalization)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Personalization is off. Your core exam preparation features continue to work normally.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          const Divider(height: 32),
          TextButton(
            onPressed: () {
              _showResetDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: const Text('Reset observed preferences', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reset personalization?'),
          content: const Text('This will remove derived preparation preferences.\n\nYour exam attempts, scores, bookmarks, and study history will not be deleted.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personalization preferences reset.')));
              },
              child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
