import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _userName = 'Student';
  String? _targetExam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('full_name, selected_exam_id')
            .eq('id', user.id)
            .maybeSingle();

        if (profileResponse != null) {
          _userName = profileResponse['full_name'] ?? 'Student';
          
          final examId = profileResponse['selected_exam_id'];
          if (examId != null) {
            final examResponse = await Supabase.instance.client
                .from('exams')
                .select('name')
                .eq('id', examId)
                .maybeSingle();
            
            if (examResponse != null) {
              _targetExam = examResponse['name'];
            }
          }
        }
      }
    } catch (e) {
      // Silently handle backend errors for now
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If backend data is still loading, show skeleton
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAE4F7),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTargetExamCard(),
                const SizedBox(height: 32),
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressStats(),
                const SizedBox(height: 24),
                _buildGoalCard(),
                const SizedBox(height: 32),
                const Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your preparation progress.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecommendations(),
                const SizedBox(height: 32),
                const Text(
                  'Upcoming Mock Test',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                  ),
                ),
                const SizedBox(height: 16),
                _buildUpcomingMockTest(),
                const SizedBox(height: 32),
                const Text(
                  'Focus Areas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Topics that need more practice.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFocusAreas(),
                const SizedBox(height: 32),
                const Text(
                  'Exam Readiness',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                  ),
                ),
                const SizedBox(height: 16),
                _buildReadinessCard(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTimeBasedGreeting() + ', $_userName 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Continue your personalized exam preparation journey.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      toolbarHeight: 100,
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildTargetExamCard() {
    final hasExam = _targetExam != null && _targetExam!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4DBF6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Target Exam',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasExam) ...[
            Text(
              _targetExam!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F0F11),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Preparation progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F0F11),
                  ),
                ),
                Text(
                  '0%', // Placeholder since no real progress data exists yet
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.0,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete your first practice session to see your progress here.',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: null, // Disabled until practice feature is built
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F11),
                  disabledBackgroundColor: const Color(0xFFF3F4F6),
                  disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue Preparation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text(
              'Select a target exam to personalize your dashboard.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0F0F11),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => context.push('/onboarding/language'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F11),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Select Target Exam',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildProgressStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'Questions',
              value: '—',
              subtitle: 'No activity yet',
              width: isMobile ? (constraints.maxWidth - 16) / 2 : 140,
            ),
            _buildStatCard(
              title: 'Accuracy',
              value: '—',
              subtitle: 'No activity yet',
              width: isMobile ? (constraints.maxWidth - 16) / 2 : 140,
            ),
            _buildStatCard(
              title: 'Study Time',
              value: '—',
              subtitle: 'No activity yet',
              width: isMobile ? (constraints.maxWidth - 16) / 2 : 140,
            ),
            _buildStatCard(
              title: 'Streak',
              value: '—',
              subtitle: 'No activity yet',
              width: isMobile ? (constraints.maxWidth - 16) / 2 : 140,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({required String title, required String value, required String subtitle, required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDF0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Goal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0F11),
                ),
              ),
              Icon(Icons.flag_outlined, size: 20, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Set your daily practice goal to stay consistent.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_outlined, size: 32, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Keep practicing and personalized recommendations will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMockTest() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0D9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_outlined, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No upcoming mock tests available.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusAreas() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Center(
        child: Text(
          'Complete a few practice sessions to identify your focus areas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE2ECE9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_outlined, size: 20, color: Color(0xFF0F0F11)),
              const SizedBox(width: 8),
              Text(
                'Your current readiness',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your readiness score will appear after enough practice data is available.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
