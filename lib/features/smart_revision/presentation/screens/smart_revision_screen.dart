import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glow_button.dart';
import '../../domain/models/revision_queue_item.dart';

class SmartRevisionScreen extends StatefulWidget {
  const SmartRevisionScreen({super.key});

  @override
  State<SmartRevisionScreen> createState() => _SmartRevisionScreenState();
}

class _SmartRevisionScreenState extends State<SmartRevisionScreen> {
  final List<RevisionQueueItem> _queue = dummyRevisionQueue;
  String _selectedFilter = 'All';

  List<RevisionQueueItem> get _filteredQueue {
    if (_selectedFilter == 'All') return _queue;
    return _queue.where((item) => item.type == _selectedFilter).toList();
  }

  void _startPriorityRevision() {
    if (_queue.isNotEmpty) {
      final item = _queue.first;
      // Start revision focus session with the item
      context.push('/focus/setup', extra: item);
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
        title: const Text(
          'Smart Revision',
          style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0F0F11)),
            onPressed: () {
              // Search action
            },
          ),
        ],
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
                    'Focus on the topics and mistakes that need your attention most.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 24),
                  _buildSummarySection(),
                  const SizedBox(height: 32),
                  GlowButton(
                    text: 'Start Priority Revision',
                    onPressed: _startPriorityRevision,
                  ),
                  const SizedBox(height: 32),
                  _buildFilters(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildQueueCard(_filteredQueue[index]);
                },
                childCount: _filteredQueue.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return GlassContainer(
      blur: 15,
      opacity: 0.8,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryMetric('2', 'High Priority', Colors.red),
            Container(height: 40, width: 1, color: Colors.grey.shade300),
            _buildSummaryMetric('1', 'Due Today', Colors.orange),
            Container(height: 40, width: 1, color: Colors.grey.shade300),
            _buildSummaryMetric('1', 'Overdue', Colors.deepOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Mistake', 'WeakTopic', 'Scheduled', 'Bookmark'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          String label = filter;
          if (filter == 'WeakTopic') label = 'Weak Topics';
          if (filter == 'Mistake') label = 'Mistakes';
          if (filter == 'Bookmark') label = 'Bookmarks';
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: const Color(0xFFFFFFFF),
              selectedColor: const Color(0xFFE4DBF6),
              labelStyle: TextStyle(
                color: isSelected ? Colors.deepPurple.shade800 : const Color(0xFF0F0F11),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQueueCard(RevisionQueueItem item) {
    Color priorityColor = Colors.grey;
    Color priorityBg = const Color(0xFFF3F4F6);
    if (item.priority == 'High') {
      priorityColor = Colors.red;
      priorityBg = const Color(0xFFFDECEB);
    } else if (item.priority == 'Medium') {
      priorityColor = Colors.orange;
      priorityBg = const Color(0xFFFDF0D5);
    }

    IconData typeIcon = Icons.refresh;
    if (item.type == 'Mistake') typeIcon = Icons.error_outline;
    if (item.type == 'WeakTopic') typeIcon = Icons.trending_down;
    if (item.type == 'Bookmark') typeIcon = Icons.bookmark_outline;
    if (item.type == 'Scheduled') typeIcon = Icons.calendar_today;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Open focus session setup pre-filled with this item's context
            context.push('/focus/setup');
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: priorityBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(typeIcon, size: 14, color: priorityColor),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${item.priority.toUpperCase()} PRIORITY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.exam} • ${item.subject}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFF555555)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.reason,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.dueAt != null || item.lastReviewedAt != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.lastReviewedAt != null)
                        Text(
                          'Last reviewed: ${_formatDate(item.lastReviewedAt!)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      if (item.dueAt != null)
                        Text(
                          item.dueAt!.isBefore(DateTime.now())
                              ? 'Overdue by ${_daysBetween(item.dueAt!, DateTime.now())} days'
                              : 'Due: ${_formatDate(item.dueAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: item.dueAt!.isBefore(DateTime.now()) ? Colors.deepOrange : Colors.grey,
                            fontWeight: item.dueAt!.isBefore(DateTime.now()) ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
