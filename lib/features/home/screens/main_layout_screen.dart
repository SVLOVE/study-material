import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../exams/presentation/screens/exam_hub_screen.dart';
import '../../practice/presentation/screens/practice_arena_screen.dart';
import '../../mock_tests/presentation/screens/mock_test_center_screen.dart';
import '../../profile/presentation/screens/profile_overview_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExamHubScreen(),
    const PracticeArenaScreen(),
    const MockTestCenterScreen(),
    const ProfileOverviewScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;

          if (isDesktop || isTablet) {
            return Row(
              children: [
                _buildSidebar(isTablet),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: _screens[_currentIndex],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Mobile Layout
          return Column(
            children: [
              _buildMobileTopBar(),
              Expanded(
                child: _screens[_currentIndex],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 768
          ? _buildBottomNavigationBar()
          : null,
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, size: 20, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search exams, topics, questions...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF0F0F11).withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0F0F11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_none, color: Color(0xFF0F0F11)),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              setState(() => _currentIndex = 4);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE4DBF6),
                child: Icon(Icons.person_outline, size: 20, color: Color(0xFF0F0F11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GovPrep AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F0F11),
                letterSpacing: 1.0,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 22, color: Color(0xFF0F0F11)),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, size: 22, color: Color(0xFF0F0F11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isTablet) {
    return Container(
      width: isTablet ? 80 : 260,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          right: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (isTablet)
            const Text(
              'GP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F0F11),
                letterSpacing: 1.0,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'GovPrep AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0F11),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 48),
          _buildSidebarItem(0, 'Dashboard', Icons.dashboard_outlined, isTablet),
          _buildSidebarItem(1, 'Exams', Icons.school_outlined, isTablet),
          _buildSidebarItem(2, 'Practice', Icons.quiz_outlined, isTablet),
          _buildSidebarItem(3, 'Mock Tests', Icons.assignment_outlined, isTablet),
          _buildSidebarItem(4, 'Leaderboard', Icons.leaderboard_outlined, isTablet),
          const Spacer(),
          _buildSidebarItem(5, 'Sign Out', Icons.logout_outlined, isTablet, onTap: () {
            Supabase.instance.client.auth.signOut();
            context.go('/login');
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon, bool isTablet, {VoidCallback? onTap}) {
    final isSelected = _currentIndex == index && index != 5;

    return InkWell(
      onTap: onTap ?? () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: isTablet ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (!isTablet) const SizedBox(width: 16),
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.6),
            ),
            if (!isTablet) ...[
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.6),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index < _screens.length) {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: const Color(0xFF0F0F11),
        unselectedItemColor: const Color(0xFF0F0F11).withValues(alpha: 0.4),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Exams'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), activeIcon: Icon(Icons.quiz), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Tests'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
