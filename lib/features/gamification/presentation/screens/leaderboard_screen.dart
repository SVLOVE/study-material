import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true;
  String _selectedPeriod = 'Weekly';
  String _selectedCategory = 'TNPSC';

  final List<String> _periods = ['Weekly', 'Monthly', 'All Time'];
  final List<String> _categories = [
    'TNPSC',
    'UPSC',
    'SSC',
    'Banking',
    'Defence',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for leaderboard data
    await Future.delayed(const Duration(milliseconds: 600));
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
        title: const Text('Leaderboard', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchLeaderboard,
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
                _buildUserSummaryCard(),
                const SizedBox(height: 32),
                _buildTopPerformers(),
                const SizedBox(height: 32),
                _buildFullRankingList(),
                const SizedBox(height: 48),
                _buildHowRankingsWork(),
                const SizedBox(height: 48),
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
        const Text('Leaderboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text('Compare your progress and stay motivated.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ChoiceChip(
                  label: Text(period),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = period);
                      _fetchLeaderboard();
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF5A31F4),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                      _fetchLeaderboard();
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFE2F0D9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.green[800] : const Color(0xFF0F0F11),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isSelected ? Colors.green : const Color(0xFFF3F4F6)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Ranking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('#24', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 14),
                          const SizedBox(width: 4),
                          Text('3', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('XP', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('1,250', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFDF0D5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Performers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMobile) _buildTopPerformerCard(rank: 2, name: 'Priya K.', xp: 3100, color: Colors.grey[400]!, height: 160),
                if (!isMobile) const SizedBox(width: 16),
                if (isMobile) _buildTopPerformerCard(rank: 1, name: 'Anand S.', xp: 3450, color: Colors.orange, height: 180),
                if (isMobile) const SizedBox(height: 16),
                if (!isMobile) _buildTopPerformerCard(rank: 1, name: 'Anand S.', xp: 3450, color: Colors.orange, height: 180),
                if (isMobile) _buildTopPerformerCard(rank: 2, name: 'Priya K.', xp: 3100, color: Colors.grey[400]!, height: 160),
                if (!isMobile) const SizedBox(width: 16),
                if (isMobile) const SizedBox(height: 16),
                _buildTopPerformerCard(rank: 3, name: 'Karthik R.', xp: 2900, color: Colors.brown[400]!, height: 140),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopPerformerCard({required int rank, required String name, required int xp, required Color color, required double height}) {
    return Container(
      width: 140,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text('#$rank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('$xp XP', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFullRankingList() {
    // Generate dummy ranking data
    final rankings = List.generate(15, (index) {
      final rank = index + 4;
      return {
        'rank': rank,
        'name': 'Participant $rank',
        'xp': 2800 - (index * 50),
        'change': index % 3 == 0 ? 1 : (index % 4 == 0 ? -2 : 0),
        'isCurrentUser': rank == 24, // Matches user summary card
      };
    });

    // Ensure the current user (#24) is in the list for demonstration
    if (!rankings.any((r) => r['rank'] == 24)) {
      rankings.add({
        'rank': 24,
        'name': 'You',
        'xp': 1250,
        'change': 3,
        'isCurrentUser': true,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Full Ranking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rankings.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final data = rankings[index];
              final isCurrentUser = data['isCurrentUser'] as bool;
              final rank = data['rank'] as int;
              final name = data['name'] as String;
              final xp = data['xp'] as int;
              final change = data['change'] as int;

              return Container(
                color: isCurrentUser ? const Color(0xFFE4DBF6).withValues(alpha: 0.3) : Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: SizedBox(
                    width: 40,
                    child: Text('#$rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isCurrentUser ? const Color(0xFF5A31F4) : Colors.grey[800])),
                  ),
                  title: Text(isCurrentUser ? 'You' : name, style: TextStyle(fontSize: 14, fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF0F0F11))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (change > 0)
                        Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                            Text('$change', style: const TextStyle(color: Colors.green, fontSize: 12)),
                          ],
                        )
                      else if (change < 0)
                        Row(
                          children: [
                            Icon(Icons.arrow_downward, color: Colors.red, size: 14),
                            Text('${change.abs()}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        )
                      else
                        const SizedBox(width: 24),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 60,
                        child: Text('$xp XP', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isCurrentUser ? const Color(0xFF5A31F4) : Colors.grey[700])),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHowRankingsWork() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[800], size: 20),
              const SizedBox(width: 12),
              const Text('How Rankings Work', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rankings are based on verified XP earned by completing mock tests, practicing questions, and maintaining study consistency during the selected period. Ties are resolved by accuracy rate. Only authorized public profiles are fully displayed.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}
