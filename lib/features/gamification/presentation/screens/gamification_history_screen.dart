import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GamificationHistoryScreen extends StatefulWidget {
  const GamificationHistoryScreen({super.key});

  @override
  State<GamificationHistoryScreen> createState() => _GamificationHistoryScreenState();
}

class _GamificationHistoryScreenState extends State<GamificationHistoryScreen> {
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;
  String _selectedDateRange = 'Last 30 days';

  final List<String> _categories = [
    'All Activity',
    'XP & Levels',
    'Achievements',
    'Challenges',
    'Rewards',
  ];

  final List<String> _dateRanges = [
    'Last 7 days',
    'Last 30 days',
    'Last 90 days',
    'All time',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for gamification event history
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
        title: const Text('Gamification History', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F0F11)),
            onPressed: _fetchHistoryData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)))
            : RefreshIndicator(
                onRefresh: _fetchHistoryData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildHistorySummary(),
                      const SizedBox(height: 32),
                      _buildFilters(),
                      const SizedBox(height: 24),
                      _buildActivityTimeline(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Track Your Progress',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 4),
        Text(
          'A chronological record of your learning achievements over time.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildHistorySummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSummaryCard(
              title: 'Total XP Earned',
              value: '1,250',
              icon: Icons.star,
              color: Colors.amber,
              width: (constraints.maxWidth - 12) / 2,
            ),
            _buildSummaryCard(
              title: 'Achievements',
              value: '12',
              icon: Icons.military_tech,
              color: Colors.purple,
              width: (constraints.maxWidth - 12) / 2,
            ),
            _buildSummaryCard(
              title: 'Challenges',
              value: '24',
              icon: Icons.flag,
              color: Colors.green,
              width: (constraints.maxWidth - 12) / 2,
            ),
            _buildSummaryCard(
              title: 'Current Level',
              value: 'Lvl 5',
              icon: Icons.trending_up,
              color: Colors.blue,
              width: (constraints.maxWidth - 12) / 2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Event History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDateRange,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedDateRange = newValue);
                      _fetchHistoryData();
                    }
                  },
                  items: _dateRanges.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              return ChoiceChip(
                label: Text(_categories[index]),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategoryIndex = index);
                    _fetchHistoryData();
                  }
                },
                selectedColor: const Color(0xFF0F0F11),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTimeline() {
    // Generate simulated event data based on filters
    List<Widget> events = [];

    events.add(_buildTimelineDateDivider('Today, Oct 9, 2026'));

    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 1) {
      events.add(
        _buildTimelineEvent(
          title: 'Level Up!',
          description: 'You reached Level 5. Keep up the great work.',
          icon: Icons.trending_up,
          iconColor: Colors.blue,
          time: '10:30 AM',
          xpValue: null,
        ),
      );
    }

    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 3) {
      events.add(
        _buildTimelineEvent(
          title: 'Daily Challenge Completed',
          description: 'Answered 50 practice questions accurately.',
          icon: Icons.flag,
          iconColor: Colors.green,
          time: '09:15 AM',
          xpValue: '+50 XP',
        ),
      );
    }

    events.add(_buildTimelineDateDivider('Yesterday, Oct 8, 2026'));

    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 2) {
      events.add(
        _buildTimelineEvent(
          title: 'Achievement Unlocked',
          description: 'Topic Master: Completed revision of 10 major syllabus topics.',
          icon: Icons.military_tech,
          iconColor: Colors.purple,
          time: '04:45 PM',
          xpValue: '+100 XP',
        ),
      );
    }

    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 1) {
      events.add(
        _buildTimelineEvent(
          title: 'Practice Session',
          description: 'Completed 45 minutes of Indian Polity practice.',
          icon: Icons.edit_note,
          iconColor: Colors.teal,
          time: '02:00 PM',
          xpValue: '+30 XP',
        ),
      );
    }

    if (events.length == 2) {
      // Only dividers are present
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: events,
      ),
    );
  }

  Widget _buildTimelineDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Text(date, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
          const SizedBox(width: 16),
          Expanded(child: Divider(color: Colors.grey[200])),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String time,
    required String? xpValue,
  }) {
    return InkWell(
      onTap: () {
        // Show detail bottom sheet or navigate
        _showEventDetailsModal(title: title, description: description, icon: icon, iconColor: iconColor, time: time, xpValue: xpValue);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11)))),
                      Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (xpValue != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        xpValue,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetailsModal({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String time,
    required String? xpValue,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 48),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 24),
              if (xpValue != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      Text('Earned $xpValue', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F0F11),
                    side: const BorderSide(color: Color(0xFFF3F4F6)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No Activity Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'No gamification events match your current filters. Try adjusting the category or date range.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedCategoryIndex = 0;
                _selectedDateRange = 'Last 30 days';
              });
              _fetchHistoryData();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              side: const BorderSide(color: Color(0xFFF3F4F6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}
