import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glow_button.dart';
import '../../domain/models/mistake_record.dart';

class MistakeNotebookScreen extends StatefulWidget {
  const MistakeNotebookScreen({super.key});

  @override
  State<MistakeNotebookScreen> createState() => _MistakeNotebookScreenState();
}

class _MistakeNotebookScreenState extends State<MistakeNotebookScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedSubject = 'All Subjects';

  List<MistakeRecord> get _filteredMistakes {
    return dummyMistakes.where((mistake) {
      final matchesSearch = mistake.questionText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mistake.topicName.toLowerCase().contains(_searchQuery.toLowerCase());
          
      final matchesStatus = _selectedStatus == 'All' || 
          (_selectedStatus == 'Needs Review' && !mistake.isResolved) ||
          (_selectedStatus == 'Resolved' && mistake.isResolved) ||
          (_selectedStatus == 'Repeated' && mistake.incorrectAttemptCount > 1);

      final matchesSubject = _selectedSubject == 'All Subjects' || mistake.subjectName == _selectedSubject;

      return matchesSearch && matchesStatus && matchesSubject;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Mistake Notebook',
          style: TextStyle(
            color: Color(0xFF0F0F11),
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    'Turn mistakes into your strongest preparation advantage.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryMetrics(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: _filteredMistakes.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildMistakeCard(_filteredMistakes[index]),
                        );
                      },
                      childCount: _filteredMistakes.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard('Needs Review', dummyMistakes.where((m) => !m.isResolved).length.toString(), const Color(0xFFFDF0D5)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('Repeated', dummyMistakes.where((m) => m.incorrectAttemptCount > 1).length.toString(), const Color(0xFFE4DBF6)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('Resolved', dummyMistakes.where((m) => m.isResolved).length.toString(), const Color(0xFFE2F0D9)),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassContainer(
      blur: 10,
      opacity: 0.7,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by question, topic, or subject...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0F0F11)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.5),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', _selectedStatus == 'All', () => setState(() => _selectedStatus = 'All')),
          const SizedBox(width: 8),
          _buildFilterChip('Needs Review', _selectedStatus == 'Needs Review', () => setState(() => _selectedStatus = 'Needs Review')),
          const SizedBox(width: 8),
          _buildFilterChip('Repeated', _selectedStatus == 'Repeated', () => setState(() => _selectedStatus = 'Repeated')),
          const SizedBox(width: 8),
          _buildFilterChip('Resolved', _selectedStatus == 'Resolved', () => setState(() => _selectedStatus = 'Resolved')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF0F0F11) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF0F0F11),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMistakeCard(MistakeRecord mistake) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return GestureDetector(
      onTap: () {
        context.push('/mistakes/${mistake.id}', extra: mistake);
      },
      child: GlassContainer(
        blur: 15,
        opacity: 0.8,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: mistake.isResolved ? const Color(0xFFE2F0D9) : const Color(0xFFFDF0D5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mistake.isResolved ? 'Resolved' : 'Needs Review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: mistake.isResolved ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ),
                  if (mistake.incorrectAttemptCount > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4DBF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.repeat, size: 14, color: Colors.deepPurple),
                          const SizedBox(width: 4),
                          Text(
                            'Repeated ${mistake.incorrectAttemptCount}x',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                mistake.questionText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag(mistake.examName),
                  _buildTag(mistake.subjectName),
                  _buildTag(mistake.topicName),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEAE4F7)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mistake.mistakeCategory ?? 'Uncategorized',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF555555), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last attempted: ${dateFormat.format(mistake.lastRecordedAt)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF555555), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          const Text(
            'No Mistakes Found',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your mistakes will appear here as you\npractice and take mock tests.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 32),
          GlowButton(
            text: 'Start Practice',
            onPressed: () {
              context.push('/practice-arena');
            },
          ),
        ],
      ),
    );
  }
}
