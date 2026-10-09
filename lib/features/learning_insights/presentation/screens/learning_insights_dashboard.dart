import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LearningInsightsDashboard extends StatefulWidget {
  const LearningInsightsDashboard({super.key});

  @override
  State<LearningInsightsDashboard> createState() => _LearningInsightsDashboardState();
}

class _LearningInsightsDashboardState extends State<LearningInsightsDashboard> {
  bool _isLoading = true;
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch
    await Future.delayed(const Duration(milliseconds: 700));
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
        title: const Text('Learning Insights', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchInsights,
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
                _buildOverviewMetrics(),
                const SizedBox(height: 32),
                _buildActivityTrend(),
                const SizedBox(height: 32),
                _buildStrengthsAndWeaknesses(),
                const SizedBox(height: 32),
                _buildActionableInsights(),
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
              const Text('Learning Insights', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text('Understand your progress and decide what to focus on next.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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
              value: _selectedPeriod,
              isDense: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              items: ['Last 7 Days', 'Last 30 Days', 'All Time'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedPeriod = val);
                  _fetchInsights();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewMetrics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return GridView.count(
          crossAxisCount: isMobile ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.5 : 1.2,
          children: [
            _buildMetricCard('Questions Attempted', '452', Icons.format_list_numbered, Colors.blue),
            _buildMetricCard('Answer Accuracy', '68%', Icons.check_circle_outline, Colors.green),
            _buildMetricCard('Study Sessions', '14', Icons.schedule, Colors.orange),
            _buildMetricCard('Current Streak', '3 Days', Icons.local_fire_department, Colors.redAccent),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildActivityTrend() {
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
          const Text('Learning Activity Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text('Questions attempted per day over the $_selectedPeriod', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 24),
          // Custom simulated bar chart
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar(30, 'Mon'),
                _buildChartBar(80, 'Tue'),
                _buildChartBar(0, 'Wed'), // No activity
                _buildChartBar(120, 'Thu'),
                _buildChartBar(45, 'Fri'),
                _buildChartBar(90, 'Sat'),
                _buildChartBar(60, 'Sun'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartBar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (height > 0)
          Tooltip(
            message: '${height.toInt()} questions',
            child: Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF5A31F4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
        else
          const SizedBox(height: 12),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStrengthsAndWeaknesses() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildTopicListCard(
                title: 'Strengths',
                icon: Icons.trending_up,
                iconColor: Colors.green,
                topics: [
                  {'name': 'Polity', 'stat': '85% Acc'},
                  {'name': 'History', 'stat': '78% Acc'},
                ],
              ),
            ),
            if (!isMobile) const SizedBox(width: 24),
            if (isMobile) const SizedBox(height: 24),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildTopicListCard(
                title: 'Areas to Improve',
                icon: Icons.trending_down,
                iconColor: Colors.red,
                topics: [
                  {'name': 'Current Affairs', 'stat': '45% Acc'},
                  {'name': 'Aptitude', 'stat': '52% Acc'},
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopicListCard({required String title, required IconData icon, required Color iconColor, required List<Map<String, String>> topics}) {
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
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 20),
          ...topics.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
                Text(t['stat']!, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionableInsights() {
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
          const Text('Actionable Observations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          _buildInsightItem(
            'Current Affairs needs practice',
            'Your accuracy has dropped in this subject over the last week.',
            'Start Practice',
            () => context.push('/practice'),
          ),
          _buildInsightItem(
            'Revisit previously incorrect answers',
            'You have 12 saved mistakes in Aptitude ready for revision.',
            'Go to Revision',
            () => context.push('/revision'),
          ),
          _buildInsightItem(
            'Consistent Study Pattern',
            'You have maintained a steady 3-day study streak. Keep it up!',
            'View Study Plan',
            () => context.push('/study-plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String desc, String actionLabel, VoidCallback onAction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFFFDF0D5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onAction,
                  child: Text(actionLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFDF0D5))),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
