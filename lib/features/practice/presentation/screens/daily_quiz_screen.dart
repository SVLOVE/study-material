import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  final String _targetExam = 'UPSC Civil Services';

  void _startQuiz() {
    _showConfirmationSheet('Daily Quiz', 10, 'Mixed', 'English', 5);
  }

  void _startQuick5() {
    _showConfirmationSheet('Quick 5', 5, 'Mixed', 'English', 3);
  }

  void _startWeakArea() {
    _showConfirmationSheet('Focus Challenge', 10, 'Indian Polity', 'English', 5);
  }

  void _startCurrentAffairs() {
    _showConfirmationSheet('Current Affairs', 10, 'Latest Events', 'English', 5);
  }

  void _showConfirmationSheet(String title, int qCount, String difficulty, String language, int minutes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: const Color(0xFFFFFFFF),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              _buildMetaRow(Icons.help_outline, 'Questions', '$qCount'),
              const SizedBox(height: 8),
              _buildMetaRow(Icons.bar_chart, 'Difficulty', difficulty),
              const SizedBox(height: 8),
              _buildMetaRow(Icons.language, 'Language', language),
              const SizedBox(height: 8),
              _buildMetaRow(Icons.timer, 'Estimated Time', '$minutes min'),
              const SizedBox(height: 24),
              const Text('Your answers will be recorded as an attempt.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0F0F11)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF0F0F11))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        // Route to existing Practice Arena engine
                        context.push('/practice'); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F0F11),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Start Quiz'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      ],
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
        title: const Text('Daily Quiz', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Exam: $_targetExam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  const Text('A short challenge to keep your preparation moving every day.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  
                  const SizedBox(height: 32),
                  
                  // Primary Challenge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F11),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(8)),
                          child: const Text('TODAY\'S CHALLENGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                        const SizedBox(height: 24),
                        const Text('10 Questions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('~5 Minutes', style: TextStyle(fontSize: 16, color: Colors.white70)),
                        const SizedBox(height: 32),
                        const Text('UPSC Civil Services\nGeneral Studies', style: TextStyle(fontSize: 14, color: Colors.white70)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F0F11),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Start Quiz →', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  
                  const Text('Quick Challenges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 16),
                  
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int cols = constraints.maxWidth > 600 ? 2 : 1;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: cols == 2 ? 1.5 : 2.5,
                        children: [
                          _buildQuickChallengeCard('Quick 5', '5 Questions', 'Quick Practice', _startQuick5),
                          _buildQuickChallengeCard('Quick 10', '10 Questions', 'Mixed Practice', _startQuiz),
                          _buildFocusChallengeCard('Focus Challenge', 'Indian Polity — Fundamental Rights', 'Your accuracy: 48%', _startWeakArea),
                          _buildQuickChallengeCard('Current Affairs', 'Today\'s Update', 'Test yourself on today\'s important current affairs.', _startCurrentAffairs),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Daily Quizzes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      TextButton(onPressed: () {}, child: const Text('View All')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildHistoryRow('Oct 6', '8 / 10', '80%'),
                  _buildHistoryRow('Oct 5', '7 / 10', '70%'),
                  _buildHistoryRow('Oct 4', '9 / 10', '90%'),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChallengeCard(String title, String subtitle, String description, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
              const SizedBox(height: 8),
              Expanded(child: Text(description, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusChallengeCard(String title, String topic, String accuracy, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, size: 20, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 8),
              Text(topic, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Expanded(child: Text(accuracy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryRow(String date, String score, String percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
          Row(
            children: [
              Text(score, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE2F0D9), borderRadius: BorderRadius.circular(6)),
                child: Text(percentage, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
