import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileOverviewScreen extends ConsumerStatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  ConsumerState<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends ConsumerState<ProfileOverviewScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _profileData;
  String _targetExamName = 'Not selected';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, selected_exam_id, current_level, language_preference')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        _profileData = profile;
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
      } else {
        _profileData = {}; // Empty profile fallback
      }
    } catch (e) {
      _error = 'Failed to load profile details.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
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
        body: Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4))),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAE4F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchProfile,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = Supabase.instance.client.auth.currentUser;
    final fullName = _profileData?['full_name'] ?? 'User';
    final email = user?.email ?? '';
    final isEmailVerified = user?.emailConfirmedAt != null;
    
    // Academic Profile values
    final currentLevel = _profileData?['current_level'] ?? 'Beginner';
    final languagePref = _profileData?['language_preference'] ?? 'English';

    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
                onPressed: () => context.pop(),
              )
            : null,
        title: Column(
          children: [
            const Text('My Profile', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Your account and exam preparation at a glance.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0F0F11)),
            onPressed: () {
              // Phase 147 route
              context.push('/profile/edit').then((_) => _fetchProfile());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: RefreshIndicator(
                  onRefresh: _fetchProfile,
                  color: const Color(0xFF5A31F4),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 768 ? 48 : 24,
                      vertical: 24,
                    ),
                    children: [
                      _buildIdentityCard(fullName, email, isEmailVerified),
                      const SizedBox(height: 32),
                      
                      const Text('Academic Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      const SizedBox(height: 16),
                      _buildAcademicSummary(currentLevel, languagePref),
                      
                      const SizedBox(height: 32),
                      
                      const Text('Study Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      const SizedBox(height: 16),
                      _buildStudyProgress(),
                      
                      const SizedBox(height: 32),
                      
                      const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      const SizedBox(height: 16),
                      _buildSettingsSection(),

                      const SizedBox(height: 32),
                      
                      const Text('Security & Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      const SizedBox(height: 16),
                      _buildSecuritySection(isEmailVerified),
                      
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIdentityCard(String name, String email, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFE4DBF6),
            child: Text(
              _getInitials(name),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4)),
            ),
          ),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(email, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
              if (isVerified) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, size: 16, color: Color(0xFF4CAF50)),
              ],
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              context.push('/profile/edit').then((_) => _fetchProfile());
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: const BorderSide(color: Color(0xFFE4DBF6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSummary(String level, String lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.school_outlined, 'Target Exam', _targetExamName),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildInfoRow(Icons.trending_up, 'Preparation Level', level),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildInfoRow(Icons.language, 'Preparation Language', lang),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          InkWell(
            onTap: () {
              // Phase 148 route placeholder
              context.push('/profile/academic').catchError((e) {
                debugPrint('Route not available yet.');
                return null;
              });
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('View Academic Profile', style: TextStyle(color: Color(0xFF5A31F4), fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18, color: Color(0xFF5A31F4)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F8FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF5A31F4), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F8FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics_outlined, color: Color(0xFF5A31F4)),
          ),
          const SizedBox(height: 16),
          const Text('No study activity yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'Your progress, streaks, and mock test statistics will appear here once you begin practicing.',
            style: TextStyle(color: Colors.grey[600], height: 1.4, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _buildSettingsTile(Icons.person_outline, 'Edit Profile', '/profile/edit'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.school_outlined, 'Academic Profile', '/profile/academic'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.assignment_outlined, 'Exam Preferences', '/profile/exam-preferences'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.language_outlined, 'Language Settings', '/profile/language'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.color_lens_outlined, 'Appearance Settings', '/profile/appearance'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.tune_outlined, 'Preparation Preferences', '/profile/preparation'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.psychology_outlined, 'Study Preferences', '/profile/study-preferences'),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(bool isEmailVerified) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF0F0F11)),
            title: const Text('Email Verification', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(isEmailVerified ? 'Verified' : 'Unverified', style: TextStyle(color: isEmailVerified ? Colors.green : Colors.orange)),
            trailing: isEmailVerified ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.settings_outlined, 'Account Settings', '/settings'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.shield_outlined, 'Privacy Settings', '/profile/privacy'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(Icons.logout, 'Sign Out', '/logout', isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String route, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : const Color(0xFF0F0F11);
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        if (route == '/logout') {
          Supabase.instance.client.auth.signOut();
          context.go('/login');
        } else {
          try {
            context.push(route).then((_) => _fetchProfile());
          } catch (e) {
            debugPrint('Route $route is not implemented yet.');
          }
        }
      },
    );
  }
}
