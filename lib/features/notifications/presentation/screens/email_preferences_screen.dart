import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailPreferences {
  // Study & Prep
  final bool studyPlanSummaries;
  final bool weeklyProgressReports;
  
  // Exams & Current Affairs
  final bool examDateReminders;
  final bool currentAffairsDigests;
  
  // Learning & Motivation
  final bool achievementSummaries;
  final bool streakReminders;

  // Subscription & Billing
  final bool billingNotices; // Required

  // Product & Platform
  final bool newFeatureAnnouncements;
  final bool promotionalMessages;
  
  // Digest Frequency
  final String digestFrequency; // 'immediate', 'daily', 'weekly', 'none'

  EmailPreferences({
    this.studyPlanSummaries = true,
    this.weeklyProgressReports = true,
    this.examDateReminders = true,
    this.currentAffairsDigests = false,
    this.achievementSummaries = true,
    this.streakReminders = true,
    this.billingNotices = true,
    this.newFeatureAnnouncements = true,
    this.promotionalMessages = false,
    this.digestFrequency = 'weekly',
  });

  EmailPreferences copyWith({
    bool? studyPlanSummaries,
    bool? weeklyProgressReports,
    bool? examDateReminders,
    bool? currentAffairsDigests,
    bool? achievementSummaries,
    bool? streakReminders,
    bool? billingNotices,
    bool? newFeatureAnnouncements,
    bool? promotionalMessages,
    String? digestFrequency,
  }) {
    return EmailPreferences(
      studyPlanSummaries: studyPlanSummaries ?? this.studyPlanSummaries,
      weeklyProgressReports: weeklyProgressReports ?? this.weeklyProgressReports,
      examDateReminders: examDateReminders ?? this.examDateReminders,
      currentAffairsDigests: currentAffairsDigests ?? this.currentAffairsDigests,
      achievementSummaries: achievementSummaries ?? this.achievementSummaries,
      streakReminders: streakReminders ?? this.streakReminders,
      billingNotices: billingNotices ?? this.billingNotices,
      newFeatureAnnouncements: newFeatureAnnouncements ?? this.newFeatureAnnouncements,
      promotionalMessages: promotionalMessages ?? this.promotionalMessages,
      digestFrequency: digestFrequency ?? this.digestFrequency,
    );
  }
}

class EmailPreferencesScreen extends ConsumerStatefulWidget {
  const EmailPreferencesScreen({super.key});

  @override
  ConsumerState<EmailPreferencesScreen> createState() => _EmailPreferencesScreenState();
}

class _EmailPreferencesScreenState extends ConsumerState<EmailPreferencesScreen> {
  bool _isLoading = true;
  String? _error;
  EmailPreferences? _preferences;
  bool _isSaving = false;

  final String _userEmail = 'user@example.com';
  final bool _isEmailVerified = true;

  @override
  void initState() {
    super.initState();
    _fetchPreferences();
  }

  Future<void> _fetchPreferences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 600));
      _preferences = EmailPreferences();
    } catch (e) {
      _error = 'Failed to load email preferences.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences(EmailPreferences newPrefs) async {
    setState(() => _isSaving = true);
    try {
      // Simulate backend save
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _preferences = newPrefs;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email preferences saved.'),
            backgroundColor: Color(0xFF5A31F4),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save preferences.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
              context.go('/settings');
            }
          },
        ),
        title: Column(
          children: [
            const Text('Email Preferences', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Manage what reaches your inbox.', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF5A31F4)),
            tooltip: 'General Notification Preferences',
            onPressed: () => context.push('/notification-preferences'),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchPreferences,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_preferences == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEmailStatusCard(),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Study & Preparation', Icons.menu_book),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'Study Plan Summaries',
                        description: 'Updates on your current syllabus progression.',
                        value: _preferences!.studyPlanSummaries,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(studyPlanSummaries: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Weekly Progress Reports',
                        description: 'Detailed analysis of your performance each week.',
                        value: _preferences!.weeklyProgressReports,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(weeklyProgressReports: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Exams & Current Affairs', Icons.public),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'Exam Date Reminders',
                        description: 'Application deadlines and admit card releases.',
                        value: _preferences!.examDateReminders,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(examDateReminders: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Current Affairs Digests',
                        description: 'Daily or weekly roundups of important news.',
                        value: _preferences!.currentAffairsDigests,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(currentAffairsDigests: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Learning & Motivation', Icons.emoji_events),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'Achievement Summaries',
                        description: 'Emails when you unlock major badges or milestones.',
                        value: _preferences!.achievementSummaries,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(achievementSummaries: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Streak Reminders',
                        description: 'Gentle nudges to keep your daily study streak alive.',
                        value: _preferences!.streakReminders,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(streakReminders: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Subscription & Product', Icons.info_outline),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'Billing & Subscriptions',
                        description: 'Invoices, renewals, and payment failures.',
                        value: _preferences!.billingNotices,
                        onChanged: (val) {},
                        isCritical: true,
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Feature Announcements',
                        description: 'News about major platform upgrades.',
                        value: _preferences!.newFeatureAnnouncements,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(newFeatureAnnouncements: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Promotional Offers',
                        description: 'Discounts and marketing updates from GovPrep.',
                        value: _preferences!.promotionalMessages,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(promotionalMessages: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Digest Frequency', Icons.schedule),
                  _buildCard(
                    children: [
                      _buildRadioOption(
                        title: 'Immediate',
                        description: 'Send emails as soon as events happen.',
                        value: 'immediate',
                        groupValue: _preferences!.digestFrequency,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(digestFrequency: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildRadioOption(
                        title: 'Daily Digest',
                        description: 'Bundle updates into a single daily email.',
                        value: 'daily',
                        groupValue: _preferences!.digestFrequency,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(digestFrequency: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildRadioOption(
                        title: 'Weekly Digest',
                        description: 'A comprehensive summary sent every Sunday.',
                        value: 'weekly',
                        groupValue: _preferences!.digestFrequency,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(digestFrequency: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildRadioOption(
                        title: 'No Optional Digests',
                        description: 'Only receive critical transactional emails.',
                        value: 'none',
                        groupValue: _preferences!.digestFrequency,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(digestFrequency: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE4DBF6).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.email_outlined, color: Color(0xFF5A31F4)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userEmail,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _isEmailVerified ? Icons.check_circle : Icons.error,
                      size: 14,
                      color: _isEmailVerified ? const Color(0xFF2E6559) : Colors.orange[800],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isEmailVerified ? 'Verified' : 'Unverified',
                      style: TextStyle(
                        color: _isEmailVerified ? const Color(0xFF2E6559) : Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Usually route to account settings
              context.push('/profile');
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5A31F4),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF5A31F4)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0F11).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isCritical = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11)),
                    ),
                    if (isCritical) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'REQUIRED',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                        ),
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: isCritical && value ? null : (_isSaving ? null : onChanged),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF5A31F4),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: const Color(0xFFF3F4F6),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String description,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: _isSaving ? null : () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: _isSaving ? null : onChanged,
              activeColor: const Color(0xFF5A31F4),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
