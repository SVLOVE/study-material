import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RewardsCenterScreen extends StatefulWidget {
  const RewardsCenterScreen({super.key});

  @override
  State<RewardsCenterScreen> createState() => _RewardsCenterScreenState();
}

class _RewardsCenterScreenState extends State<RewardsCenterScreen> {
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All Rewards',
    'Study Milestones',
    'Streak Rewards',
    'Challenge Rewards',
    'Special Rewards',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRewardsData();
  }

  Future<void> _fetchRewardsData() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for user rewards
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
        title: const Text('Rewards Center', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F0F11)),
            onPressed: _fetchRewardsData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)))
            : RefreshIndicator(
                onRefresh: _fetchRewardsData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildRewardSummary(),
                      const SizedBox(height: 32),
                      _buildCategoryFilter(),
                      const SizedBox(height: 24),
                      _buildRewardsCollection(),
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
          'Celebrate Your Progress',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 4),
        Text(
          'Explore rewards earned through your consistent preparation journey.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildRewardSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSummaryCard(
              title: 'Total Earned',
              value: '18',
              caption: 'Rewards unlocked',
              icon: Icons.emoji_events,
              color: Colors.amber,
              width: (constraints.maxWidth - 12) / 2,
            ),
            _buildSummaryCard(
              title: 'Available',
              value: '3',
              caption: 'Ready to claim',
              icon: Icons.card_giftcard,
              color: Colors.green,
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
    required String caption,
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
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
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
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text(caption, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
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
              if (selected) setState(() => _selectedCategoryIndex = index);
            },
            selectedColor: const Color(0xFF0F0F11),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0F0F11),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildRewardsCollection() {
    // Determine which rewards to show based on the selected category filter
    // In a real app, this would filter a list of reward models.
    List<Widget> rewards = [];

    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 1) {
      rewards.add(
        _buildRewardCard(
          title: 'Topic Master',
          description: 'Successfully completed revision of 10 major syllabus topics.',
          icon: Icons.menu_book,
          iconColor: Colors.blue,
          category: 'Study Milestones',
          status: 'Earned',
          statusColor: Colors.green,
          date: 'Earned on Oct 8, 2026',
        ),
      );
    }
    
    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 2) {
      rewards.add(
        _buildRewardCard(
          title: 'Consistent Learner',
          description: 'Maintained a 7-day active study streak.',
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          category: 'Streak Rewards',
          status: 'Available',
          statusColor: Colors.teal,
          isClaimable: true,
        ),
      );
    }

    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 3) {
      rewards.add(
        _buildRewardCard(
          title: 'Monthly Study Milestone',
          description: 'Finished all weekly challenges in a single month.',
          icon: Icons.flag,
          iconColor: Colors.purple,
          category: 'Challenge Rewards',
          status: 'Locked',
          statusColor: Colors.grey,
          lockedReason: 'Complete all weekly challenges this month to unlock.',
        ),
      );
    }
    
    if (rewards.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: rewards,
    );
  }

  Widget _buildRewardCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String category,
    required String status,
    required Color statusColor,
    String? date,
    String? lockedReason,
    bool isClaimable = false,
  }) {
    final bool isLocked = status == 'Locked';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLocked ? Colors.white.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[200] : iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(isLocked ? Icons.lock : icon, color: isLocked ? Colors.grey : iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLocked ? Colors.grey[600] : const Color(0xFF0F0F11)))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),
          if (lockedReason != null)
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(lockedReason, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
              ],
            )
          else if (isClaimable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                ElevatedButton(
                  onPressed: () {
                    // Logic to claim reward
                    _showRewardDetailsModal(
                      title: title,
                      description: description,
                      icon: icon,
                      iconColor: iconColor,
                      status: status,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A31F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  ),
                  child: const Text('Claim Reward', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                if (date != null) Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
        ],
      ),
    );
  }

  void _showRewardDetailsModal({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String status,
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
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 48),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This reward confirms your study streak. Claim it to add it to your permanent achievements.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF0F0F11)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward claimed successfully!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A31F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm Claim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          Icon(Icons.card_giftcard, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No Rewards Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'Keep practising and completing your study goals to discover new rewards in this category.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => setState(() => _selectedCategoryIndex = 0),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              side: const BorderSide(color: Color(0xFFF3F4F6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View All Rewards'),
          ),
        ],
      ),
    );
  }
}
