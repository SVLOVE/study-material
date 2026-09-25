import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_dashboard_screen.dart';
import '../../syllabus/screens/syllabus_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardScreen(),
    const SyllabusScreen(),
    Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: const Center(child: Text('Practice Section Coming Soon!', style: TextStyle(color: Colors.cyanAccent, fontSize: 20)))),
    Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: const Center(child: Text('Profile Section Coming Soon!', style: TextStyle(color: Colors.purpleAccent, fontSize: 20)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for glass effect behind nav bar
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: Colors.cyanAccent,
              unselectedItemColor: Colors.white54,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Syllabus'),
                BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Practice'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
