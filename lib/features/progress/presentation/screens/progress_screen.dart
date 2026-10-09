import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  String _selectedRange = '30 Days';
  
  // Simulated Analytics State
  final String _targetExam = 'UPSC Civil Services';
  
  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Mock backend computation delay
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Your Progress', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preparing for: $_targetExam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                        const SizedBox(height: 8),
                        const Text('Track your preparation, identify weak areas, and keep improving.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/roadmap'),
                    icon: const Icon(Icons.explore),
                    label: const Text('View Roadmap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F0F11),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildFilterRow(),
              const SizedBox(height: 32),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 800) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildOverallSummary()),
                            const SizedBox(width: 32),
                            Expanded(child: _buildStudyConsistency()),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildSubjectPerformance()),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildFocusAreas(),
                                  const SizedBox(height: 32),
                                  _buildStrengths(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  
                  return Column(
                    children: [
                      _buildOverallSummary(),
                      const SizedBox(height: 32),
                      _buildStudyConsistency(),
                      const SizedBox(height: 32),
                      _buildSubjectPerformance(),
                      const SizedBox(height: 32),
                      _buildFocusAreas(),
                      const SizedBox(height: 32),
                      _buildStrengths(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final ranges = ['7 Days', '30 Days', '90 Days', 'All Time'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ranges.map((range) {
          final isSelected = _selectedRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedRange = range);
                _fetchAnalytics();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6)),
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverallSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overall Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricTile('Accuracy', '78%', Icons.check_circle_outline, Colors.green),
              _buildMetricTile('Questions Solved', '642', Icons.format_list_numbered, Colors.blue),
              _buildMetricTile('Mock Tests', '12', Icons.timer_outlined, Colors.pink),
              _buildMetricTile('Study Time', '18h 25m', Icons.access_time, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        ],
      ),
    );
  }

  Widget _buildStudyConsistency() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Study Consistency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(6)),
                child: const Text('6 day streak', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressRow('Study Days', '18 / 30', 0.6),
          const SizedBox(height: 16),
          _buildProgressRow('Tasks Completed', '72%', 0.72),
          const SizedBox(height: 16),
          _buildProgressRow('Avg Daily Study', '38 min', 0.5),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subject Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildSubjectBar('General Studies', 0.82),
          const SizedBox(height: 20),
          _buildSubjectBar('Quantitative Aptitude', 0.74),
          const SizedBox(height: 20),
          _buildSubjectBar('Reasoning', 0.88),
          const SizedBox(height: 20),
          _buildSubjectBar('English', 0.79),
        ],
      ),
    );
  }

  Widget _buildSubjectBar(String subject, double accuracy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
            Text('${(accuracy * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: accuracy,
            backgroundColor: const Color(0xFFF3F4F6),
            color: const Color(0xFFE4DBF6),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildFocusAreas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Focus Areas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Based on recent accuracy:', style: TextStyle(fontSize: 13, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          _buildFocusItem('1', 'Indian Economy', '61%'),
          const SizedBox(height: 8),
          _buildFocusItem('2', 'Probability', '65%'),
          const SizedBox(height: 8),
          _buildFocusItem('3', 'Modern History', '68%'),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F11),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Practice Focus Areas'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFocusItem(String index, String title, String acc) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text(index, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F0F11)))),
        Text(acc, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
      ],
    );
  }

  Widget _buildStrengths() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0D9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green),
              SizedBox(width: 8),
              Text('Your Strengths', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 16),
          _buildStrengthItem('Reasoning is currently your strongest subject.'),
          const SizedBox(height: 8),
          _buildStrengthItem('Your accuracy in Algebra has improved by 8%.'),
        ],
      ),
    );
  }

  Widget _buildStrengthItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Icon(Icons.check_circle, size: 16, color: Colors.green),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.8), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF3F4F6),
            color: const Color(0xFF0F0F11),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
