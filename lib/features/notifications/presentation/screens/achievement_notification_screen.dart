import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AchievementReward {
  final String type; // 'XP', 'Badge', 'Title'
  final String value;
  final String description;

  AchievementReward({
    required this.type,
    required this.value,
    required this.description,
  });
}

class AchievementData {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime earnedDate;
  final String iconUrl; // or local asset path
  final List<AchievementReward> rewards;
  final String progressContext;

  AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.earnedDate,
    required this.iconUrl,
    required this.rewards,
    required this.progressContext,
  });
}

class AchievementNotificationScreen extends ConsumerStatefulWidget {
  final String notificationId;

  const AchievementNotificationScreen({
    super.key,
    required this.notificationId,
  });

  @override
  ConsumerState<AchievementNotificationScreen> createState() => _AchievementNotificationScreenState();
}

class _AchievementNotificationScreenState extends ConsumerState<AchievementNotificationScreen> {
  bool _isLoading = true;
  String? _error;
  AchievementData? _achievement;

  @override
  void initState() {
    super.initState();
    _fetchAchievementDetails();
  }

  Future<void> _fetchAchievementDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));

      if (widget.notificationId == 'invalid') {
        _achievement = null;
      } else {
        _achievement = AchievementData(
          id: widget.notificationId,
          title: 'Century Solver',
          description: 'Successfully complete 100 practice questions with an accuracy above 80%.',
          category: 'Practice Milestone',
          earnedDate: DateTime.now().subtract(const Duration(hours: 1)),
          iconUrl: 'assets/icons/trophy.png', // Fallback to icons if needed
          rewards: [
            AchievementReward(type: 'XP', value: '+500', description: 'Experience Points'),
            AchievementReward(type: 'Badge', value: 'Century Badge', description: 'Profile decoration'),
          ],
          progressContext: 'You have consistently maintained an 82% accuracy rate over the last 15 days of preparation.',
        );
      }
    } catch (e) {
      _error = 'Failed to load achievement details.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/notifications');
            }
          },
        ),
        title: const Text('Achievement Unlocked', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAchievementDetails,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_achievement == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Achievement Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('The requested achievement details are unavailable.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/achievements'), // Assuming this route exists
              child: const Text('View All Achievements'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // Slightly narrower for achievements
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Celebrate the milestones you\'ve earned through your preparation.',
                    style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildAchievementSummaryCard(),
                              const SizedBox(height: 24),
                              _buildExplanationCard(),
                              const SizedBox(height: 24),
                              _buildActions(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRewardsCard(),
                              const SizedBox(height: 24),
                              _buildProgressContextCard(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAchievementSummaryCard(),
                        const SizedBox(height: 24),
                        _buildRewardsCard(),
                        const SizedBox(height: 24),
                        _buildExplanationCard(),
                        const SizedBox(height: 24),
                        _buildProgressContextCard(),
                        const SizedBox(height: 24),
                        _buildActions(),
                      ],
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDF0D5).withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0D5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 4),
            ),
            child: Icon(Icons.emoji_events, color: Colors.orange[800], size: 48),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE4DBF6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              _achievement!.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF5A31F4),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _achievement!.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Earned on ${DateFormat('MMMM d, yyyy').format(_achievement!.earnedDate)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Achievement Criteria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _achievement!.description,
                  style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    if (_achievement!.rewards.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rewards Granted', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          ..._achievement!.rewards.map((reward) {
            IconData iconData;
            Color iconColor;
            
            if (reward.type == 'XP') {
              iconData = Icons.star;
              iconColor = Colors.orange;
            } else if (reward.type == 'Badge') {
              iconData = Icons.shield;
              iconColor = const Color(0xFF5A31F4);
            } else {
              iconData = Icons.card_giftcard;
              iconColor = Colors.teal;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.value,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                        ),
                        Text(
                          reward.description,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressContextCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Colors.teal[700], size: 20),
              const SizedBox(width: 8),
              const Text('Your Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _achievement!.progressContext,
            style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'), // Replace with actual achievements board
                icon: const Icon(Icons.grid_view, size: 18),
                label: const Text('View All Achievements'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A31F4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/dashboard'), // Link to gamification history
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Gamification History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F0F11),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
