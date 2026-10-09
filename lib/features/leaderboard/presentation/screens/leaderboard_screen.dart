import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardEntry {
  final String id;
  final String displayName;
  final int rank;
  final double score;
  final String avatarUrl;

  LeaderboardEntry({
    required this.id,
    required this.displayName,
    required this.rank,
    required this.score,
    required this.avatarUrl,
  });
}

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  bool _isLoading = true;
  List<LeaderboardEntry> _entries = [];
  LeaderboardEntry? _currentUserEntry;
  
  String _selectedExam = 'TNPSC Group 4';
  String _selectedPeriod = 'This Week';

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Simulate backend call

      // Generate fake backend response
      final List<LeaderboardEntry> allEntries = List.generate(50, (index) {
        return LeaderboardEntry(
          id: 'user_$index',
          displayName: 'Learner ${100 + index}',
          rank: index + 1,
          score: 95.0 - (index * 0.4),
          avatarUrl: '', // Real app would use actual public URLs
        );
      });

      _entries = allEntries;
      
      // Simulate current user at rank 42
      _currentUserEntry = LeaderboardEntry(
        id: 'me',
        displayName: 'You',
        rank: 42,
        score: 82.4,
        avatarUrl: '',
      );
      
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
        title: const Text('Leaderboard', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDropdown(
                        value: _selectedExam,
                        items: ['TNPSC Group 4', 'UPSC Prelims', 'SSC CGL'],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedExam = val);
                            _fetchLeaderboard();
                          }
                        },
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(width: 16),
                      _buildDropdown(
                        value: _selectedPeriod,
                        items: ['Today', 'This Week', 'This Month', 'All Time'],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedPeriod = val);
                            _fetchLeaderboard();
                          }
                        },
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isMobile)
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Color(0xFF0F0F11)),
                  tooltip: 'How rankings work',
                  onPressed: _showRankingInfo,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.leaderboard_outlined, size: 64, color: Color(0xFF0F0F11)),
            const SizedBox(height: 16),
            const Text('Leaderboard is getting ready', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('Complete eligible mock tests and practice activities to appear in rankings.', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6)), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildTopThree(),
                    const SizedBox(height: 32),
                    _buildLeaderboardList(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_currentUserEntry != null && _currentUserEntry!.rank > 3)
          _buildPinnedCurrentUserRow(),
      ],
    );
  }

  Widget _buildTopThree() {
    if (_entries.length < 3) return const SizedBox.shrink();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildTopRankerCard(_entries[1], 2, 100)),
        const SizedBox(width: 12),
        Expanded(child: _buildTopRankerCard(_entries[0], 1, 130)),
        const SizedBox(width: 12),
        Expanded(child: _buildTopRankerCard(_entries[2], 3, 90)),
      ],
    );
  }

  Widget _buildTopRankerCard(LeaderboardEntry entry, int rank, double height) {
    final isFirst = rank == 1;
    final color = isFirst ? const Color(0xFFFDF0D5) : const Color(0xFFFFFFFF);
    final borderColor = isFirst ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6);
    
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isFirst ? 2 : 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE4DBF6),
            radius: isFirst ? 24 : 18,
            child: Text(
              '${entry.rank}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isFirst ? 18 : 14, color: const Color(0xFF0F0F11)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: isFirst ? 14 : 12, color: const Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 4),
          Text(
            entry.score.toStringAsFixed(1),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final remainingEntries = _entries.skip(3).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: remainingEntries.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
        itemBuilder: (context, index) {
          final entry = remainingEntries[index];
          final isCurrentUser = entry.id == _currentUserEntry?.id;
          return _buildLeaderboardRow(entry, isCurrentUser: isCurrentUser);
        },
      ),
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntry entry, {bool isCurrentUser = false, bool isPinned = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFE4DBF6).withValues(alpha: isPinned ? 1.0 : 0.3) : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
            ),
          ),
          CircleAvatar(
            backgroundColor: const Color(0xFFF3F4F6),
            radius: 16,
            child: Icon(Icons.person, size: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry.displayName,
              style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500, fontSize: 15, color: const Color(0xFF0F0F11)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            entry.score.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F0F11)),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedCurrentUserRow() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE4DBF6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F0F11), width: 1.5),
              ),
              child: _buildLeaderboardRow(_currentUserEntry!, isCurrentUser: true, isPinned: true),
            ),
          ),
        ),
      ),
    );
  }

  void _showRankingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('How rankings work', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        content: const Text(
          'Rankings are calculated from eligible completed assessments and verified performance data within the selected time period.\n\nRanking Score = Average Mock Score + Accuracy + Consistency',
          style: TextStyle(color: Color(0xFF0F0F11), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF0F0F11))),
          ),
        ],
      ),
    );
  }
}
