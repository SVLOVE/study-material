import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExamReadinessDashboard extends StatefulWidget {
  const ExamReadinessDashboard({super.key});

  @override
  State<ExamReadinessDashboard> createState() => _ExamReadinessDashboardState();
}

class _ExamReadinessDashboardState extends State<ExamReadinessDashboard> {
  bool _isLoading = true;
  String _selectedExam = 'TNPSC Group 4';
  
  @override
  void initState() {
    super.initState();
    _fetchReadinessData();
  }

  Future<void> _fetchReadinessData() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Exam Readiness', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchReadinessData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildReadinessSummary(),
                const SizedBox(height: 32),
                _buildSyllabusCoverage(),
                const SizedBox(height: 32),
                _buildSubjectReadiness(),
                const SizedBox(height: 32),
                _buildTopicsToFocusOn(),
                const SizedBox(height: 32),
                _buildMockTestPerformance(),
                const SizedBox(height: 32),
                _buildNextSteps(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Exam Readiness', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text('Understand your preparation progress and identify areas that need attention.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedExam,
              isDense: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              items: ['TNPSC Group 4', 'TNPSC Group 2'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedExam = val);
                  _fetchReadinessData();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadinessSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Readiness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0D5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('On Track', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('74%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Readiness Score', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('68%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Evidence Coverage', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
                        SizedBox(width: 4),
                        Text('+4%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Trend (30 Days)', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusCoverage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Syllabus Coverage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildProgressBar('Completed', 42, 120, Colors.teal),
          const SizedBox(height: 16),
          _buildProgressBar('In Progress', 35, 120, Colors.orange),
          const SizedBox(height: 16),
          _buildProgressBar('Not Started', 43, 120, Colors.grey[300]!),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final pct = value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            Text('$value / $total topics', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectReadiness() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subject Readiness', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return GridView.count(
              crossAxisCount: isMobile ? 1 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.5 : 2.0,
              children: [
                _buildSubjectCard('General Studies', 'Strong', '82% coverage', '76% acc', const Color(0xFFE2F0D9), Colors.green),
                _buildSubjectCard('Aptitude', 'Improving', '65% coverage', '68% acc', const Color(0xFFE2ECE9), Colors.teal),
                _buildSubjectCard('Current Affairs', 'Needs Attention', '40% coverage', '55% acc', const Color(0xFFFFEAEA), Colors.redAccent),
                _buildSubjectCard('English', 'Not Enough Data', '10% coverage', '--', const Color(0xFFF3F4F6), Colors.grey),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubjectCard(String title, String status, String coverage, String accuracy, Color bgColor, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(coverage, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              Text(accuracy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsToFocusOn() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Topics to Focus On', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildFocusTopicItem('Modern History', 'General Studies', 'Accuracy has declined compared with previous period.'),
          _buildFocusTopicItem('Time and Work', 'Aptitude', 'Revision is due based on your learning state.'),
          _buildFocusTopicItem('Indian Economy', 'General Studies', 'Performance evidence is insufficient for readiness assessment.'),
        ],
      ),
    );
  }

  Widget _buildFocusTopicItem(String title, String subject, String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.orange, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(subject, style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(reason, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onPressed: () => context.push('/practice'), // Navigate to practice or topic
          ),
        ],
      ),
    );
  }

  Widget _buildMockTestPerformance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mock Test Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMockTestStat('Recent Score', '142/200', true),
              ),
              Expanded(
                child: _buildMockTestStat('Accuracy', '76%', true),
              ),
              Expanded(
                child: _buildMockTestStat('Completed', '5 Tests', null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockTestStat(String label, String value, bool? isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Row(
          children: [
            if (isPositive != null)
              Icon(isPositive ? Icons.trending_up : Icons.trending_down, size: 14, color: isPositive ? Colors.green : Colors.red),
            if (isPositive != null) const SizedBox(width: 4),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextSteps() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE4DBF6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended Next Steps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4))),
          const SizedBox(height: 16),
          _buildActionItem(Icons.repeat, 'Revise Time and Work', 'Revision is due', () => context.push('/revision')),
          const SizedBox(height: 12),
          _buildActionItem(Icons.play_arrow, 'Take a Mock Test', 'Establish a baseline for Current Affairs', () => context.push('/mock-tests')),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5A31F4)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Color(0xFF5A31F4), size: 20),
          ],
        ),
      ),
    );
  }
}
