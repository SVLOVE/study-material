import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BadgesDashboard extends StatefulWidget {
  const BadgesDashboard({super.key});

  @override
  State<BadgesDashboard> createState() => _BadgesDashboardState();
}

class _BadgesDashboardState extends State<BadgesDashboard> {
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Practice',
    'Mock Tests',
    'Revision',
    'Consistency',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  Future<void> _fetchBadges() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch
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
        title: const Text('My Badges', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchBadges,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildBadgeSummary(),
                const SizedBox(height: 32),
                _buildCategories(),
                const SizedBox(height: 32),
                _buildRecentlyEarned(),
                const SizedBox(height: 32),
                _buildBadgeGrid(),
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
        const Text('My Badges', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text('Your preparation milestones, collected along the way.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildBadgeSummary() {
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('Earned', '12', Colors.orange),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildSummaryStat('Locked', '38', Colors.grey[400]!),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildSummaryStat('Total', '50', Colors.white),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                  _fetchBadges();
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
    );
  }

  Widget _buildRecentlyEarned() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recently Earned', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF0D5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.orange, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Performer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text('Achieved 90%+ in 3 consecutive mock tests.', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text('Earned 2 days ago', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Badge Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildBadgeItem(
                  title: 'First Step',
                  icon: Icons.flag,
                  isEarned: true,
                ),
                _buildBadgeItem(
                  title: 'Mock Test Rookie',
                  icon: Icons.assignment_turned_in,
                  isEarned: true,
                ),
                _buildBadgeItem(
                  title: 'Speedster',
                  icon: Icons.speed,
                  isEarned: true,
                ),
                _buildBadgeItem(
                  title: 'Consistency Key',
                  icon: Icons.local_fire_department,
                  isEarned: false,
                  progress: 3,
                  total: 7,
                ),
                _buildBadgeItem(
                  title: 'Revision Master',
                  icon: Icons.autorenew,
                  isEarned: false,
                ),
                _buildBadgeItem(
                  title: 'Flawless',
                  icon: Icons.verified,
                  isEarned: false,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeItem({
    required String title,
    required IconData icon,
    required bool isEarned,
    int? progress,
    int? total,
  }) {
    return InkWell(
      onTap: () {
        _showBadgeDetails(context, title, icon, isEarned, progress, total);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isEarned ? const Color(0xFFFDF0D5) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEarned ? icon : Icons.lock,
                color: isEarned ? Colors.orange : Colors.grey[400],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEarned ? const Color(0xFF0F0F11) : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isEarned && progress != null && total != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / total,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text('$progress/$total', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
            ] else if (!isEarned) ...[
              const SizedBox(height: 8),
              Text('Locked', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, String title, IconData icon, bool isEarned, int? progress, int? total) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isEarned ? const Color(0xFFFDF0D5) : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEarned ? icon : Icons.lock,
                  color: isEarned ? Colors.orange : Colors.grey[400],
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'This badge is awarded for demonstrating exceptional consistency or performance in your exam preparation.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isEarned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Earned on Oct 01, 2026', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else if (progress != null && total != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('$progress / $total', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / total,
                        backgroundColor: const Color(0xFFF3F4F6),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        minHeight: 8,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                  child: Text('Keep practicing to unlock', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    if (!isEarned) {
                      context.push('/practice');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEarned ? 'Close' : 'Start Practicing'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
