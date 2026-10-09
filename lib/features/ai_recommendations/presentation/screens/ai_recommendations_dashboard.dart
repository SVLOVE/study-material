import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiRecommendationsDashboard extends StatefulWidget {
  const AiRecommendationsDashboard({super.key});

  @override
  State<AiRecommendationsDashboard> createState() => _AiRecommendationsDashboardState();
}

class _AiRecommendationsDashboardState extends State<AiRecommendationsDashboard> {
  bool _isLoading = true;
  String _selectedExam = 'TNPSC Group 4';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Weak Topics', 'Revision', 'Practice', 'Mock Tests'];

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
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
        title: const Text('AI Recommendations', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchRecommendations,
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
                _buildFilters(),
                const SizedBox(height: 32),
                _buildRecommendationsList(),
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
              const Text('AI Recommendations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 4),
              Text('Your next best steps toward exam readiness.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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
                  _fetchRecommendations();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
              backgroundColor: const Color(0xFFFFFFFF),
              selectedColor: const Color(0xFFE4DBF6),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFFF3F4F6)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    // Determine which items to show based on filter
    // In a real app this would filter an actual list of models
    final items = <Widget>[];

    if (_selectedFilter == 'All' || _selectedFilter == 'Weak Topics') {
      items.add(_buildRecommendationCard(
        title: 'Strengthen Weak Topic',
        subject: 'General Studies',
        topic: 'Indian Economy',
        reason: 'Your recent practice accuracy in this topic has dropped to 45%.',
        priority: 'High Priority',
        priorityColor: Colors.red,
        priorityBg: const Color(0xFFFFEAEA),
        time: '30 mins',
        actionLabel: 'Practice Questions',
        onAction: () => context.push('/practice'),
      ));
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Revision') {
      items.add(_buildRecommendationCard(
        title: 'Revise Overdue Topic',
        subject: 'Aptitude',
        topic: 'Time and Work',
        reason: 'You have not revised this topic since your last mock test.',
        priority: 'Recommended',
        priorityColor: Colors.orange,
        priorityBg: const Color(0xFFFDF0D5),
        time: '15 mins',
        actionLabel: 'Revise Topic',
        onAction: () => context.push('/revision'),
      ));
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Mock Tests') {
      items.add(_buildRecommendationCard(
        title: 'Take a Sectional Mock',
        subject: 'Current Affairs',
        topic: 'Last 6 Months',
        reason: 'You need to establish a baseline performance score for recent events.',
        priority: 'Optional',
        priorityColor: Colors.teal,
        priorityBg: const Color(0xFFE2ECE9),
        time: '45 mins',
        actionLabel: 'Start Mock Test',
        onAction: () => context.push('/mock-tests'),
      ));
    }

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('You are fully caught up with this category.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Column(
      children: items.map((e) => Padding(padding: const EdgeInsets.only(bottom: 16), child: e)).toList(),
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String subject,
    required String topic,
    required String reason,
    required String priority,
    required Color priorityColor,
    required Color priorityBg,
    required String time,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(priority, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: priorityColor)),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text('$subject • $topic', style: const TextStyle(fontSize: 14, color: Colors.teal, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.insights, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
