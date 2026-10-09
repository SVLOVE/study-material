import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  String _targetExamName = 'Not selected';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('full_name, selected_exam_id, current_level, language_preference')
            .eq('id', user.id)
            .maybeSingle();
            
        if (profile != null) {
          _profile = profile;
          
          if (profile['selected_exam_id'] != null) {
             final exam = await Supabase.instance.client
                .from('exams')
                .select('name')
                .eq('id', profile['selected_exam_id'])
                .maybeSingle();
             if (exam != null) {
               _targetExamName = exam['name'] ?? 'Unknown Exam';
             }
          }
        }
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Sign out?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: const Text('You will need to sign in again to access your account.', style: TextStyle(color: Color(0xFF0F0F11))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF0F0F11))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAE4F7),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAE4F7),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(0xFF0F0F11)),
              const SizedBox(height: 16),
              const Text('Couldn\'t load your profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final user = Supabase.instance.client.auth.currentUser;
    final fullName = _profile!['full_name'] ?? 'User';
    final email = user?.email ?? '';
    final currentLevel = _profile!['current_level'] ?? 'Beginner';
    final languagePref = _profile!['language_preference'] ?? 'English';

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0F0F11)),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHero(fullName, email, currentLevel),
                  const SizedBox(height: 32),
                  const Text('Your Preparation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 16),
                  _buildPreparationSummary(),
                  const SizedBox(height: 32),
                  const Text('Preparation Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 16),
                  _buildPreparationProfile(currentLevel, languagePref),
                  const SizedBox(height: 32),
                  const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 16),
                  _buildAccountSection(),
                  const SizedBox(height: 32),
                  const Text('Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 16),
                  _buildSecuritySection(),
                  const SizedBox(height: 32),
                  const Text('Account Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  const SizedBox(height: 16),
                  _buildAccountActions(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(String fullName, String email, String level) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFE4DBF6),
            child: Text(
              _getInitials(fullName),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeroBadge('Target', _targetExamName),
              const SizedBox(width: 16),
              _buildHeroBadge('Level', level),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await context.push('/profile/edit');
                _loadProfile();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFF3F4F6), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationSummary() {
    // In a real app, these would come from backend stats
    final hasStats = false; 

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: hasStats
          ? const Column(
              children: [
                // Render stats grid
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Start your preparation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 8),
                Text('Your preparation statistics will appear as you practice and complete tests.', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6), height: 1.5)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/practice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start Practicing'),
                ),
              ],
            ),
    );
  }

  Widget _buildPreparationProfile(String level, String lang) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.flag_outlined,
            title: 'Target Exam',
            subtitle: _targetExamName,
            onTap: () {}, // Can hook up to existing exam selector
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildListTile(
            icon: Icons.trending_up,
            title: 'Preparation Level',
            subtitle: level,
            onTap: () {},
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildListTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: lang,
            onTap: () {},
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildListTile(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            subtitle: 'View your learning milestones',
            onTap: () => context.push('/achievements'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Update your display name and details',
            onTap: () async {
              await context.push('/profile/edit');
              _loadProfile();
            },
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildListTile(
            icon: Icons.receipt_long_outlined,
            title: 'Billing & Subscription',
            subtitle: 'Manage subscription and view history',
            onTap: () {
              context.push('/billing');
            },
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildListTile(
            icon: Icons.analytics_outlined,
            title: 'Progress & Analytics',
            subtitle: 'View your performance trends',
            onTap: () {
              context.push('/progress');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Password',
            subtitle: 'Change your password',
            onTap: () {}, // Route to existing password change if implemented
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildListTile(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Not enabled', // Real state fetched from auth
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            ),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: _handleSignOut,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0F0F11), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      subtitle: Text(subtitle, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6), fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF0F0F11)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
