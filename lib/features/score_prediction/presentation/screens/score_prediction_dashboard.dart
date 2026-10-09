import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScorePredictionDashboard extends StatefulWidget {
  const ScorePredictionDashboard({super.key});

  @override
  State<ScorePredictionDashboard> createState() => _ScorePredictionDashboardState();
}

class _ScorePredictionDashboardState extends State<ScorePredictionDashboard> {
  bool _isLoading = true;
  String _selectedExam = 'TNPSC Group 4';

  @override
  void initState() {
    super.initState();
    _fetchPredictionData();
  }

  Future<void> _fetchPredictionData() async {
    setState(() => _isLoading = true);
    // Simulate API fetch delay
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
        title: const Text('Score Prediction', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchPredictionData,
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
                _buildPredictionSummary(),
                const SizedBox(height: 32),
                _buildScoreRangeVisualization(),
                const SizedBox(height: 32),
                _buildDataSufficiency(),
                const SizedBox(height: 32),
                _buildFactorsBehindEstimate(),
                const SizedBox(height: 32),
                _buildHistoricalPerformance(),
                const SizedBox(height: 32),
                _buildLimitationsCard(),
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
              const Text('Score Prediction', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text('Explore what your recent performance may indicate about your exam score.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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
                  _fetchPredictionData();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionSummary() {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Estimated Score Range', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('135 - 150', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('out of 200 marks', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.update, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text('Last updated: Today, 10:30 AM', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScoreRangeVisualization() {
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
          const Text('Score Range Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    const Spacer(flex: 135), // Min bound
                    Expanded(
                      flex: 15, // Range width
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const Spacer(flex: 50), // Remainder to 200
                  ],
                ),
              ),
              // Marker for actual recent mock
              Positioned(
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    const Spacer(flex: 142),
                    Container(width: 4, height: 20, color: const Color(0xFF0F0F11)),
                    const Spacer(flex: 58),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              Text('200', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Predicted Range (135 - 150)', Colors.blueAccent.withValues(alpha: 0.6)),
              const SizedBox(width: 16),
              _buildLegendItem('Recent Mock (142)', const Color(0xFF0F0F11), isLine: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isLine = false}) {
    return Row(
      children: [
        Container(
          width: isLine ? 4 : 12,
          height: isLine ? 12 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: isLine ? BoxShape.rectangle : BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildDataSufficiency() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sufficient Evidence Available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 4),
                Text('The estimate is based on 5 recent mock tests and robust syllabus coverage.', style: TextStyle(fontSize: 13, color: Colors.green[900])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFactorsBehindEstimate() {
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
          const Text('Factors Behind the Estimate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildFactorItem('Recent Mock Test Results', 'High performance consistency across the last 3 mocks.'),
          _buildFactorItem('Topic Mastery', 'Strong fundamentals in Polity and Science, balancing weakness in Current Affairs.'),
          _buildFactorItem('Syllabus Coverage', '82% of the high-weightage topics have been covered and revised.'),
        ],
      ),
    );
  }

  Widget _buildFactorItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.teal, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoricalPerformance() {
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
          const Text('Your Performance History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          _buildHistoryRow('Mock Test 5', 'Oct 5, 2026', '142', '+4'),
          _buildHistoryRow('Mock Test 4', 'Sep 28, 2026', '138', '+2'),
          _buildHistoryRow('Mock Test 3', 'Sep 21, 2026', '136', '-1'),
          _buildHistoryRow('Practice Session (Full)', 'Sep 15, 2026', '137', '--'),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String title, String date, String score, String change) {
    final isPositive = change.startsWith('+');
    final isNegative = change.startsWith('-');
    final changeColor = isPositive ? Colors.green : (isNegative ? Colors.red : Colors.grey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 2),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          Row(
            children: [
              Text(change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: changeColor)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(score, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLimitationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimate Limitations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 4),
                Text('Estimates are based on available performance evidence and may not reflect your actual examination result. Avoid relying solely on this prediction for exam readiness.', style: TextStyle(fontSize: 13, color: Colors.orange[900])),
              ],
            ),
          )
        ],
      ),
    );
  }
}
