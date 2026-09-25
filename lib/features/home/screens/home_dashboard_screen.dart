import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/glass_container.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _userName = 'Student';
  String _targetExam = 'Setup your Goal';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('full_name, selected_exam_id')
            .eq('id', user.id)
            .single();

        setState(() {
          _userName = profileResponse['full_name'] ?? 'Student';
        });

        final examId = profileResponse['selected_exam_id'];
        if (examId != null) {
          final examResponse = await Supabase.instance.client
              .from('exams')
              .select('name')
              .eq('id', examId)
              .maybeSingle();

          if (examResponse != null) {
            setState(() {
              _targetExam = examResponse['name'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
            : RefreshIndicator(
                onRefresh: _fetchUserData,
                color: Colors.cyanAccent,
                backgroundColor: const Color(0xFF16213E),
                child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTargetCard(),
                          const SizedBox(height: 24),
                          const Text(
                            'Your Daily Goal',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          _buildDailyGoal(),
                          const SizedBox(height: 24),
                          const Text(
                            'Explore Modules',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          _buildModulesGrid(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (mounted) context.go('/login');
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'Hello, ' + _userName + ' ??',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetCard() {
    return GlassContainer(
      blur: 20,
      opacity: 0.15,
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Exam',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _targetExam,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => context.push('/onboarding/language'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDailyGoal() {
    return GlassContainer(
      blur: 15,
      opacity: 0.05,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Questions Solved', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              Text('24 / 50', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 24 / 50,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildModuleCard('Study Materials', Icons.menu_book, Colors.blueAccent, onTap: () => context.push('/study-materials')),
        _buildModuleCard('Practice', Icons.quiz, Colors.orangeAccent),
        _buildModuleCard('Mock Tests', Icons.timer, Colors.pinkAccent),
        _buildModuleCard('Current Affairs', Icons.public, Colors.greenAccent),
        _buildModuleCard('PYQs', Icons.history, Colors.purpleAccent),
        _buildModuleCard('Analytics', Icons.bar_chart, Colors.cyanAccent),
      ],
    );
  }

  Widget _buildModuleCard(String title, IconData icon, Color glowColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        blur: 10,
        opacity: 0.08,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Icon(icon, color: glowColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}








