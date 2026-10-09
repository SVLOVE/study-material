import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glow_button.dart';
import '../../domain/models/focus_session_model.dart';

class FocusSessionSummaryScreen extends StatefulWidget {
  final FocusSessionModel session;

  const FocusSessionSummaryScreen({super.key, required this.session});

  @override
  State<FocusSessionSummaryScreen> createState() => _FocusSessionSummaryScreenState();
}

class _FocusSessionSummaryScreenState extends State<FocusSessionSummaryScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  bool _isReflectionSaved = false;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final m = seconds ~/ 60;
    return '$m min';
  }

  void _saveReflection() {
    if (_reflectionController.text.trim().isNotEmpty) {
      setState(() {
        _isReflectionSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCompletionBanner(),
                    const SizedBox(height: 24),
                    _buildMainSummaryCard(),
                    const SizedBox(height: 24),
                    _buildAccomplishments(),
                    const SizedBox(height: 24),
                    _buildMistakeSummary(),
                    const SizedBox(height: 24),
                    _buildReflectionSection(),
                    const SizedBox(height: 24),
                    _buildNextActionCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF0F0F11)),
            onPressed: () => context.go('/dashboard'),
          ),
          const Expanded(
            child: Text(
              'Session Complete',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance for close button
        ],
      ),
    );
  }

  Widget _buildCompletionBanner() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F0D9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade200, width: 2),
          ),
          child: const Icon(Icons.check_circle, size: 48, color: Colors.green),
        ),
        const SizedBox(height: 16),
        const Text(
          'Here\'s what you accomplished.',
          style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainSummaryCard() {
    final dateFormat = DateFormat('d MMM yyyy');
    return GlassContainer(
      blur: 20,
      opacity: 0.9,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.topic,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.session.exam} • ${widget.session.subject}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4DBF6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dateFormat.format(widget.session.startedAt),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(color: Color(0xFFEAE4F7)),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(Icons.timer, 'Focused Time', _formatDuration(widget.session.focusedSeconds)),
                ),
                Expanded(
                  child: _buildMetricItem(Icons.task_alt, 'Activity', widget.session.activityType),
                ),
              ],
            ),
            if (widget.session.activityType == 'Practice') ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(Icons.question_answer, 'Attempted', '20 Questions'), // Mock metric
                  ),
                  Expanded(
                    child: _buildMetricItem(Icons.analytics, 'Accuracy', '85%'), // Mock metric
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF555555)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccomplishments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What You Accomplished',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          blur: 10,
          opacity: 0.9,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildBulletPoint('Completed planned Practice Session.'),
                const SizedBox(height: 12),
                _buildBulletPoint('Studied for ${_formatDuration(widget.session.focusedSeconds)} continuously.'),
                const SizedBox(height: 12),
                _buildBulletPoint('Strong accuracy in ${widget.session.subject}.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
        ),
      ],
    );
  }

  Widget _buildMistakeSummary() {
    if (widget.session.activityType != 'Practice') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Next',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          blur: 10,
          opacity: 0.9,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('3 questions answered incorrectly.', style: TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFDECEB), borderRadius: BorderRadius.circular(8)),
                      child: const Text('1 Repeated', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/mistake-notebook');
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Review Mistakes'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F0F11),
                    side: const BorderSide(color: Color(0xFF0F0F11)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Reflection',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          blur: 10,
          opacity: 0.9,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What do you want to remember from this session?', style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
                const SizedBox(height: 12),
                _isReflectionSaved
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _reflectionController.text,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF0F0F11)),
                        ),
                      )
                    : TextField(
                        controller: _reflectionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Write a short private note...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: const Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                      ),
                if (!_isReflectionSaved) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _saveReflection,
                      child: const Text('Save Reflection', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextActionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Continue Your Preparation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          blur: 10,
          opacity: 1.0,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE4DBF6), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.refresh, color: Colors.deepPurple),
              ),
              title: const Text('Revise This Topic', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              subtitle: const Text('Solidify what you just learned.', style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Route to topic revision
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
        top: false,
        child: Column(
          children: [
            GlowButton(
              text: 'Return to Dashboard',
              onPressed: () {
                context.go('/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }
}
