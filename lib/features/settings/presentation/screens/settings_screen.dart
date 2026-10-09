import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _profileData = response;
          });
        }
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      debugPrint('Error loading account data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Account Settings', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Manage your account and sign-in preferences.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)))
            : _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAccountOverviewCard(isDark),
                              const SizedBox(height: 24),
                              _buildFooter(isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 2,
                          child: _buildMainSections(isDark),
                        ),
                      ],
                    )
                  else ...[
                    _buildAccountOverviewCard(isDark),
                    const SizedBox(height: 24),
                    _buildMainSections(isDark),
                    const SizedBox(height: 32),
                    _buildFooter(isDark),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountOverviewCard(bool isDark) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = _profileData?['full_name'] ?? 'User';
    final email = user?.email ?? 'Unknown Email';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
    final createdAt = user?.createdAt != null 
        ? DateFormat('MMMM yyyy').format(DateTime.parse(user!.createdAt))
        : 'Unknown Date';
    final isEmailVerified = user?.emailConfirmedAt != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF5A31F4).withValues(alpha: 0.1),
            child: Text(
              initial,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4)),
            ),
          ),
          const SizedBox(height: 16),
          Text(fullName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text(email, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isEmailVerified ? Icons.verified : Icons.warning_amber_rounded, size: 16, color: isEmailVerified ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Text(isEmailVerified ? 'Email Verified' : 'Unverified Email', style: TextStyle(color: isEmailVerified ? Colors.green : Colors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Member since $createdAt', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/profile/edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5A31F4),
                side: const BorderSide(color: Color(0xFF5A31F4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSections(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Sign-in and Authentication', isDark),
        _buildSectionContainer([
          _buildSettingsTile(
            icon: Icons.password_outlined,
            title: 'Change Password',
            description: 'Update your account password',
            onTap: () => context.push('/settings/change-password'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(
            icon: Icons.devices_outlined,
            title: 'Active Sessions',
            description: 'Review devices logged into your account.',
            onTap: () => context.push('/settings/active-sessions'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(
            icon: Icons.history_outlined,
            title: 'Login Activity',
            description: 'Review recent sign-in events.',
            onTap: () => context.push('/settings/login-activity'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: 'Two-Factor Authentication',
            description: 'Add an extra layer of security.',
            onTap: () => context.push('/settings/two-factor-auth'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(
            icon: Icons.vpn_key_outlined,
            title: 'Account Recovery',
            description: 'Manage account recovery methods.',
            onTap: () => context.push('/settings/account-recovery'),
            isDark: isDark,
          ),
        ], isDark),
        const SizedBox(height: 32),
        
        _buildSectionTitle('Account Preferences', isDark),
        _buildSectionContainer([
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language Settings',
            description: 'Manage app display language',
            onTap: () => context.push('/profile/language'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(
            icon: Icons.color_lens_outlined,
            title: 'Appearance Settings',
            description: 'Customize light/dark mode',
            onTap: () => context.push('/profile/appearance'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(
            icon: Icons.psychology_outlined,
            title: 'Study Preferences',
            description: 'Customize your study experience',
            onTap: () => context.push('/profile/study-preferences'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSettingsTile(
            icon: Icons.assignment_outlined,
            title: 'Exam Preferences',
            description: 'Manage target examinations',
            onTap: () => context.push('/profile/exam-preferences'),
            isDark: isDark,
          ),
        ], isDark),
        const SizedBox(height: 32),

        _buildSectionTitle('Account Information and Data', isDark),
        _buildSectionContainer([
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Settings',
            description: 'Manage data usage and visibility',
            onTap: () => context.push('/profile/privacy'),
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildUnavailableTile(Icons.download_outlined, 'Export Data', 'Download a copy of your personal data.', isDark),
        ], isDark),
        const SizedBox(height: 32),
        
        _buildSectionTitle('Session Management', isDark),
        _buildSectionContainer([
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.logout, color: isDark ? Colors.white : const Color(0xFF0F0F11), size: 20),
            ),
            title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
            subtitle: Text('Sign out from this device', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 13)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) context.go('/login');
            },
          ),
        ], isDark),
        const SizedBox(height: 32),

        _buildSectionTitle('Danger Zone', isDark),
        _buildSectionContainer([
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            ),
            title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            subtitle: Text('Permanently remove your account and data', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 13)),
            onTap: () {
              context.push('/settings/delete-account');
            },
          ),
        ], isDark, borderColor: Colors.redAccent.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
    );
  }

  Widget _buildSectionContainer(List<Widget> children, bool isDark, {Color? borderColor}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? (isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6))),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: isDark ? Colors.white : const Color(0xFF0F0F11), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
      subtitle: Text(description, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 13)),
      trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400]),
      onTap: onTap,
    );
  }
  
  Widget _buildUnavailableTile(IconData icon, String title, String description, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[500] : Colors.grey[500])),
      subtitle: Text(description, style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 13)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Unavailable', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title is not yet implemented in this environment.')));
      },
    );
  }

  Widget _buildFooter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('GovPrep AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 4),
          Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[600] : Colors.grey[400])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Privacy Policy', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ),
              Text('•', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400])),
              TextButton(
                onPressed: () {},
                child: Text('Terms of Service', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ),
            ],
          ),
          TextButton(
            onPressed: () => context.push('/help'),
            child: Text('Help Center', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}
