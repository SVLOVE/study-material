import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _originalPreferences;

  // Privacy preferences
  bool _allowPersonalization = true;
  bool _allowAnalytics = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select('privacy_preferences')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['privacy_preferences'] != null) {
        final prefs = response['privacy_preferences'] as Map<String, dynamic>;
        _originalPreferences = prefs;
        
        setState(() {
          _allowPersonalization = prefs['allow_personalization'] ?? true;
          _allowAnalytics = prefs['allow_analytics'] ?? true;
        });
      } else {
        _originalPreferences = _getCurrentState();
      }
    } catch (e) {
      debugPrint('Failed to load privacy preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load privacy settings. Using defaults.'), backgroundColor: Colors.orange),
        );
      }
      _originalPreferences = _getCurrentState();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _getCurrentState() {
    return {
      'allow_personalization': _allowPersonalization,
      'allow_analytics': _allowAnalytics,
    };
  }

  bool get _hasChanges {
    if (_originalPreferences == null) return false;
    final current = _getCurrentState();
    for (final key in current.keys) {
      if (current[key] != _originalPreferences![key]) return true;
    }
    return false;
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final current = _getCurrentState();
        await Supabase.instance.client
            .from('profiles')
            .update({'privacy_preferences': current})
            .eq('id', user.id);
            
        if (mounted) {
          setState(() => _originalPreferences = Map.from(current));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Privacy settings saved successfully.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges || _isSaving) return true;
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Discard changes?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: const Text('You have unsaved privacy settings. Leave without saving?', style: TextStyle(color: Color(0xFF0F0F11))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay', style: TextStyle(color: Color(0xFF5A31F4))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop()) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFEAE4F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) context.pop();
              }
            },
          ),
          title: Column(
            children: [
              Text('Privacy Settings', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Understand and manage your personal information.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)))
              : _buildBody(isDark),
        ),
        bottomNavigationBar: _hasChanges ? _buildStickyActions(isDark) : null,
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPrivacyOverview(isDark),
                  const SizedBox(height: 24),
                  _buildProfileVisibilitySection(isDark),
                  const SizedBox(height: 24),
                  _buildPersonalInformationSection(isDark),
                  const SizedBox(height: 24),
                  _buildActivitySection(isDark),
                  const SizedBox(height: 24),
                  _buildAnalyticsSection(isDark),
                  const SizedBox(height: 24),
                  _buildDataAccessSection(isDark),
                  const SizedBox(height: 24),
                  _buildDataRemovalSection(isDark),
                  const SizedBox(height: 32),
                  _buildPrivacyPolicyLink(isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyOverview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF5A31F4), size: 28),
              const SizedBox(width: 12),
              Text('Privacy Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You can review and manage supported privacy options here. Your personal study information is protected by GovPrep AI authorization rules. Available controls depend on implemented features.',
            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileVisibilitySection(bool isDark) {
    return _buildSection(
      title: 'Profile Visibility',
      icon: Icons.visibility_outlined,
      isDark: isDark,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: isDark ? Colors.grey[400] : Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Public-profile and community visibility controls are currently unavailable because public features (like study communities or shared leaderboards) have not been implemented yet. Your profile remains entirely private to you.',
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformationSection(bool isDark) {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.badge_outlined,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GovPrep AI stores the following account information to provide a tailored learning experience:',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Basic profile information (Name, Email, Phone)', isDark),
          _buildBulletPoint('Academic and exam preferences', isDark),
          _buildBulletPoint('Study progress, mock test scores, and performance', isDark),
          _buildBulletPoint('Bookmarks and saved study materials', isDark),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Manage Basic Profile'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF5A31F4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 6, color: isDark ? Colors.grey[500] : Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(bool isDark) {
    return _buildSection(
      title: 'Activity and Personalization',
      icon: Icons.auto_awesome_outlined,
      isDark: isDark,
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Personalized Recommendations', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Allow GovPrep AI to use your study activity and practice performance to identify weak topics and suggest tailored study plans.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
            value: _allowPersonalization,
            onChanged: (val) => setState(() => _allowPersonalization = val),
            activeColor: const Color(0xFF5A31F4),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(bool isDark) {
    return _buildSection(
      title: 'Analytics and Usage Data',
      icon: Icons.analytics_outlined,
      isDark: isDark,
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Share Optional Usage Data', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Share anonymized usage data to help us improve GovPrep AI. Essential security and operational logs are strictly retained regardless of this setting.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
            value: _allowAnalytics,
            onChanged: (val) => setState(() => _allowAnalytics = val),
            activeColor: const Color(0xFF5A31F4),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDataAccessSection(bool isDark) {
    return _buildSection(
      title: 'Data Access and Export',
      icon: Icons.download_outlined,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have the right to request a copy of your personal data, including your profile, exam preferences, and study progress.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3B3B1F) : const Color(0xFFFDF0D5).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF3B3B1F) : const Color(0xFFFDF0D5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: isDark ? const Color(0xFFFFD700) : const Color(0xFFB8860B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Automated self-serve data export functionality has not been implemented yet in the backend. Please contact support to request a data dump.',
                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRemovalSection(bool isDark) {
    return _buildSection(
      title: 'Account Data Removal',
      icon: Icons.delete_outline,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account deletion permanently removes your personal information, exam preferences, and study progress according to applicable retention requirements.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                context.push('/settings');
              },
              icon: const Icon(Icons.settings_outlined, size: 16),
              label: const Text('Go to Account Settings'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyLink(bool isDark) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy Policy URL not configured.')));
        },
        icon: const Icon(Icons.open_in_new, size: 16),
        label: const Text('Read Full Privacy Policy'),
        style: TextButton.styleFrom(foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStickyActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving ? null : () {
                if (_originalPreferences != null) {
                  setState(() {
                    _allowPersonalization = _originalPreferences!['allow_personalization'] ?? true;
                    _allowAnalytics = _originalPreferences!['allow_analytics'] ?? true;
                  });
                }
              },
              child: const Text('Discard', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
