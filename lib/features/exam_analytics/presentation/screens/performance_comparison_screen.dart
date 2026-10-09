import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PerformanceComparisonScreen extends StatefulWidget {
  const PerformanceComparisonScreen({super.key});

  @override
  State<PerformanceComparisonScreen> createState() => _PerformanceComparisonScreenState();
}

class _PerformanceComparisonScreenState extends State<PerformanceComparisonScreen> {
  bool _isLoading = true;
  String _timeRange = 'Last 30 Days';
  String _metric = 'Accuracy';

  @override
  void initState() {
    super.initState();
    _fetchComparisonData();
  }

  Future<void> _fetchComparisonData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Mock network
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
        title: const Text('Performance Comparison', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFilterBar(),
              const SizedBox(height: 32),
              _buildPerformanceSummary(),
              const SizedBox(height: 32),
              _buildComparisonChart(),
              const SizedBox(height: 32),
              _buildPerformanceInsight(),
              const SizedBox(height: 32),
              _buildDimensionComparison('Subject Performance Comparison', [
                {'name': 'General Studies', 'current': '76%', 'previous': '68%', 'change': '+8%', 'status': 'Improving'},
                {'name': 'Aptitude', 'current': '82%', 'previous': '84%', 'change': '-2%', 'status': 'Stable'},
                {'name': 'English', 'current': '65%', 'previous': '55%', 'change': '+10%', 'status': 'Improving'},
                {'name': 'Current Affairs', 'current': '58%', 'previous': '60%', 'change': '-2%', 'status': 'Needs Attention'},
              ]),
              const SizedBox(height: 32),
              _buildDimensionComparison('Topic Performance Comparison', [
                {'name': 'Indian Polity', 'current': '88%', 'previous': '78%', 'change': '+10%', 'status': 'Improving'},
                {'name': 'Modern History', 'current': '62%', 'previous': '72%', 'change': '-10%', 'status': 'Declining'},
                {'name': 'Environment', 'current': '55%', 'previous': '52%', 'change': '+3%', 'status': 'Stable'},
              ]),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Performance Comparison', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text('Compare your learning performance and understand where you are improving.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildDropdown('Exam', 'TNPSC Group 4', ['TNPSC Group 4', 'TNPSC Group 2']),
        _buildDropdown('Period', _timeRange, ['Last 7 Days', 'Last 30 Days', 'Last 90 Days'], (val) {
          if (val != null) {
            setState(() => _timeRange = val);
            _fetchComparisonData();
          }
        }),
        _buildDropdown('Compare', 'Previous Period', ['Previous Period', 'Previous Mock']),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, [Function(String?)? onChanged]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text('$label: $e'))).toList(),
          onChanged: onChanged ?? (val) {},
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Accuracy', '76%', '68%', '+8%', true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Avg Score', '142', '120', '+22', true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Questions', '450', '320', '+130', true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Time/Q', '42s', '45s', '-3s', true)),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildSummaryCard('Accuracy', '76%', '68%', '+8%', true)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Avg Score', '142', '120', '+22', true)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Questions', '450', '320', '+130', true)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Time/Q', '42s', '45s', '-3s', true)),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String current, String previous, String change, bool isPositive) {
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(current, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(changeIcon, size: 14, color: changeColor),
              const SizedBox(width: 4),
              Text(change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: changeColor)),
              const SizedBox(width: 8),
              Text('vs $previous', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Performance Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              _buildMetricSwitcher(),
            ],
          ),
          const SizedBox(height: 24),
          // Custom Line Chart Simulation
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _SimpleLineChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Current Period', Colors.blueAccent),
              const SizedBox(width: 24),
              _buildLegendItem('Previous Period', Colors.grey[400]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _metric,
          isDense: true,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          items: ['Accuracy', 'Score', 'Time'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _metric = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildPerformanceInsight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE2ECE9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.teal),
              const SizedBox(width: 8),
              const Text('Performance Insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your accuracy improved significantly compared to the previous period, particularly in General Studies and Indian Polity. However, your time efficiency decreased slightly. Consider focusing on speed without sacrificing accuracy in upcoming practice sessions.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionComparison(String title, List<Map<String, String>> data) {
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              columns: const [
                DataColumn(label: Text('Subject/Topic')),
                DataColumn(label: Text('Current')),
                DataColumn(label: Text('Previous')),
                DataColumn(label: Text('Change')),
                DataColumn(label: Text('Status')),
              ],
              rows: data.map((item) {
                final isPositive = item['change']!.startsWith('+');
                final changeColor = isPositive ? Colors.green : (item['change'] == '-2%' ? Colors.orange : Colors.red);
                return DataRow(
                  cells: [
                    DataCell(Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)))),
                    DataCell(Text(item['current']!, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(item['previous']!, style: const TextStyle(color: Colors.grey))),
                    DataCell(Text(item['change']!, style: TextStyle(fontWeight: FontWeight.bold, color: changeColor))),
                    DataCell(_buildStatusBadge(item['status']!)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Improving':
        bgColor = const Color(0xFFE2F0D9);
        textColor = Colors.green[800]!;
        break;
      case 'Needs Attention':
      case 'Declining':
        bgColor = const Color(0xFFFFEAEA);
        textColor = Colors.red[800]!;
        break;
      case 'Stable':
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final currentPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final previousPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = size.height - (i * (size.height / 4));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Mock data points
    final currentPoints = [0.4, 0.5, 0.55, 0.7, 0.65, 0.8, 0.76];
    final previousPoints = [0.3, 0.45, 0.4, 0.5, 0.6, 0.55, 0.68];

    final currentPath = Path();
    final previousPath = Path();

    final stepX = size.width / (currentPoints.length - 1);

    for (int i = 0; i < currentPoints.length; i++) {
      final cx = i * stepX;
      final cy = size.height - (currentPoints[i] * size.height);
      final px = i * stepX;
      final py = size.height - (previousPoints[i] * size.height);

      if (i == 0) {
        currentPath.moveTo(cx, cy);
        previousPath.moveTo(px, py);
      } else {
        currentPath.lineTo(cx, cy);
        previousPath.lineTo(px, py);
      }
    }

    canvas.drawPath(previousPath, previousPaint);
    canvas.drawPath(currentPath, currentPaint);

    // Draw dots
    final dotPaintCurrent = Paint()..color = Colors.blueAccent;
    final dotPaintPrevious = Paint()..color = Colors.grey[400]!;

    for (int i = 0; i < currentPoints.length; i++) {
      final cx = i * stepX;
      final cy = size.height - (currentPoints[i] * size.height);
      final px = i * stepX;
      final py = size.height - (previousPoints[i] * size.height);

      canvas.drawCircle(Offset(cx, cy), 4, dotPaintCurrent);
      canvas.drawCircle(Offset(px, py), 3, dotPaintPrevious);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
