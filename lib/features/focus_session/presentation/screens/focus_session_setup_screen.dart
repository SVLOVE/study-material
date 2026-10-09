import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glow_button.dart';

class FocusSessionSetupScreen extends StatefulWidget {
  const FocusSessionSetupScreen({super.key});

  @override
  State<FocusSessionSetupScreen> createState() => _FocusSessionSetupScreenState();
}

class _FocusSessionSetupScreenState extends State<FocusSessionSetupScreen> {
  int _selectedDuration = 25; // Default 25 minutes
  final List<int> _durations = [15, 25, 45, 60, 90];
  
  String _selectedActivity = 'Practice';
  final List<String> _activities = [
    'Practice',
    'Revision',
    'Flashcards',
    'Study Material',
  ];

  void _startSession() {
    context.pushReplacement(
      '/focus/active',
      extra: {
        'duration': _selectedDuration,
        'activity': _selectedActivity,
        'exam': 'TNPSC Group 2',
        'subject': 'Indian Polity',
        'topic': 'Fundamental Rights',
      },
    );
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
          'Focus Session',
          style: TextStyle(
            color: Color(0xFF0F0F11),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose what you want to accomplish in this session.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 32),
                  _buildContextCard(),
                  const SizedBox(height: 32),
                  const Text(
                    'Activity Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  _buildActivitySelector(),
                  const SizedBox(height: 32),
                  const Text(
                    'Duration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  ),
                  const SizedBox(height: 16),
                  _buildDurationSelector(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: GlowButton(
            text: 'Start Focus Session',
            onPressed: _startSession,
          ),
        ),
      ),
    );
  }

  Widget _buildContextCard() {
    return GlassContainer(
      blur: 15,
      opacity: 0.8,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Goal', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text(
              'Revise Fundamental Rights & Duties',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag('TNPSC Group 2', Icons.assignment),
                _buildTag('Polity', Icons.book),
                _buildTag('Fundamental Rights', Icons.segment),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF555555)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _activities.map((activity) {
        final isSelected = _selectedActivity == activity;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedActivity = activity;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
            ),
            child: Text(
              activity,
              style: TextStyle(
                color: isSelected ? Colors.deepPurple.shade800 : const Color(0xFF0F0F11),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _durations.map((duration) {
          final isSelected = _selectedDuration == duration;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDuration = duration;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? const Color(0xFF0F0F11) : Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    '$duration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                    ),
                  ),
                  Text(
                    'min',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
