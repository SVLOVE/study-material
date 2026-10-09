import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationPreferences {
  final bool studyReminders;
  final bool examUpdates;
  final bool mockTestAlerts;
  final bool achievementNotifications;
  final bool subscriptionAlerts;
  final bool systemAnnouncements;
  
  // Delivery channels
  final bool inAppEnabled;
  final bool emailEnabled;
  
  // Quiet hours
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  NotificationPreferences({
    this.studyReminders = true,
    this.examUpdates = true,
    this.mockTestAlerts = true,
    this.achievementNotifications = true,
    this.subscriptionAlerts = true,
    this.systemAnnouncements = true,
    this.inAppEnabled = true,
    this.emailEnabled = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
  });

  NotificationPreferences copyWith({
    bool? studyReminders,
    bool? examUpdates,
    bool? mockTestAlerts,
    bool? achievementNotifications,
    bool? subscriptionAlerts,
    bool? systemAnnouncements,
    bool? inAppEnabled,
    bool? emailEnabled,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationPreferences(
      studyReminders: studyReminders ?? this.studyReminders,
      examUpdates: examUpdates ?? this.examUpdates,
      mockTestAlerts: mockTestAlerts ?? this.mockTestAlerts,
      achievementNotifications: achievementNotifications ?? this.achievementNotifications,
      subscriptionAlerts: subscriptionAlerts ?? this.subscriptionAlerts,
      systemAnnouncements: systemAnnouncements ?? this.systemAnnouncements,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  bool _isLoading = true;
  String? _error;
  NotificationPreferences? _preferences;
  bool _isSaving = false;

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
      _preferences = NotificationPreferences();
    } catch (e) {
      _error = 'Failed to load preferences.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences(NotificationPreferences newPrefs) async {
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
            content: Text('Preferences saved successfully.'),
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

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    if (_preferences == null) return;
    
    final initialTime = isStart ? _preferences!.quietHoursStart : _preferences!.quietHoursEnd;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5A31F4),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F0F11),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != initialTime) {
      final newPrefs = isStart 
          ? _preferences!.copyWith(quietHoursStart: pickedTime)
          : _preferences!.copyWith(quietHoursEnd: pickedTime);
      _savePreferences(newPrefs);
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
            const Text('Notification Preferences', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Choose which updates you receive.', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: true,
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
                  _buildSectionHeader('Delivery Channels', Icons.campaign),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'In-App Notifications',
                        description: 'Receive updates directly inside the GovPrep AI app.',
                        value: _preferences!.inAppEnabled,
                        onChanged: (val) {
                          if (!val && !_preferences!.emailEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('At least one delivery channel must be enabled.'), backgroundColor: Colors.orange));
                            return;
                          }
                          _savePreferences(_preferences!.copyWith(inAppEnabled: val));
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Email Notifications',
                        description: 'Receive daily digests and critical updates via email.',
                        value: _preferences!.emailEnabled,
                        onChanged: (val) {
                          if (!val && !_preferences!.inAppEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('At least one delivery channel must be enabled.'), backgroundColor: Colors.orange));
                            return;
                          }
                          _savePreferences(_preferences!.copyWith(emailEnabled: val));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Study & Preparation', Icons.menu_book),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'Study Reminders',
                        description: 'Daily alerts to keep your preparation on track.',
                        value: _preferences!.studyReminders,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(studyReminders: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Exam & Current Affairs Updates',
                        description: 'Alerts for important exam dates and relevant news.',
                        value: _preferences!.examUpdates,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(examUpdates: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Mock Test Alerts',
                        description: 'Reminders for scheduled full-length mock tests.',
                        value: _preferences!.mockTestAlerts,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(mockTestAlerts: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Account & Gamification', Icons.person),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'Achievements & Milestones',
                        description: 'Notifications when you unlock badges or level up.',
                        value: _preferences!.achievementNotifications,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(achievementNotifications: val)),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'Subscription & Billing',
                        description: 'Critical updates about plan renewals and payments.',
                        value: _preferences!.subscriptionAlerts,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(subscriptionAlerts: val)),
                        isCritical: true, // Example marking
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      _buildToggleRow(
                        title: 'System Announcements',
                        description: 'Platform maintenance and feature updates.',
                        value: _preferences!.systemAnnouncements,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(systemAnnouncements: val)),
                        isCritical: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Quiet Hours', Icons.nights_stay),
                  _buildCard(
                    children: [
                      _buildToggleRow(
                        title: 'Enable Quiet Hours',
                        description: 'Mute non-critical notifications during this time.',
                        value: _preferences!.quietHoursEnabled,
                        onChanged: (val) => _savePreferences(_preferences!.copyWith(quietHoursEnabled: val)),
                      ),
                      if (_preferences!.quietHoursEnabled) ...[
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context, true),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE4DBF6)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('From', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(
                                          _preferences!.quietHoursStart.format(context),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context, false),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE4DBF6)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('To', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(
                                          _preferences!.quietHoursEnd.format(context),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
