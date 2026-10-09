import '../../../core/widgets/glass_container.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Sakthi!',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildAdminCard(
                        context,
                        icon: Icons.upload_file,
                        title: 'Upload Material',
                        color: Colors.purpleAccent,
                        onTap: () => context.push('/admin/upload'),
                      ),
                      _buildAdminCard(
                        context,
                        icon: Icons.delete_outline,
                        title: 'Manage Materials',
                        color: Colors.redAccent,
                        onTap: () {
                          context.push('/admin/manage-materials');
                        },
                      ),
                      _buildAdminCard(
                        context,
                        icon: Icons.people_outline,
                        title: 'Manage Users',
                        color: Colors.greenAccent,
                        onTap: () {
                          context.push('/admin/manage-users');
                        },
                      ),
                      _buildAdminCard(
                        context,
                        icon: Icons.library_books,
                        title: 'Manage Syllabus',
                        color: Colors.orangeAccent,
                        onTap: () {
                          context.push('/admin/manage-syllabus');
                        },
                      ),
                      _buildAdminCard(
                        context,
                        icon: Icons.health_and_safety,
                        title: 'Operational Health',
                        color: Colors.blueAccent,
                        onTap: () {
                          context.push('/admin/operational-health');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
