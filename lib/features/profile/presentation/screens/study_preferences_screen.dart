import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudyPreferencesScreen extends ConsumerStatefulWidget {
  const StudyPreferencesScreen({super.key});

  @override
  ConsumerState<StudyPreferencesScreen> createState() => _StudyPreferencesScreenState();
}

class _StudyPreferencesScreenState extends ConsumerState<StudyPreferencesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _originalPreferences;

  // Form State
  int _sessionDuration = 25; // 25, 45, 60, 90
  int _breakDuration = 5; // 5, 10, 15
  String _explanationPreference = 'detailed'; // concise, detailed
  
  bool _showQuestionNumbering = true;
  bool _showAnswerFeedback = true;
  bool _showExplanationsAfterSubmit = true;
  bool _showProgress = true;
  
  bool _reviseBookmarked = true;
  bool _reviseIncorrect = true;
  bool _reviseCompleted = false;
  
  bool _enableReminders = true;

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
          .select('study_preferences')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['study_preferences'] != null) {
        final prefs = response['study_preferences'] as Map<String, dynamic>;
        _originalPreferences = prefs;
        
        setState(() {
          _sessionDuration = prefs['session_duration'] ?? 25;
          _breakDuration = prefs['break_duration'] ?? 5;
          _explanationPreference = prefs['explanation_preference'] ?? 'detailed';
          
          _showQuestionNumbering = prefs['show_question_numbering'] ?? true;
          _showAnswerFeedback = prefs['show_answer_feedback'] ?? true;
          _showExplanationsAfterSubmit = prefs['show_explanations_after_submit'] ?? true;
          _showProgress = prefs['show_progress'] ?? true;
          
          _reviseBookmarked = prefs['revise_bookmarked'] ?? true;
          _reviseIncorrect = prefs['revise_incorrect'] ?? true;
          _reviseCompleted = prefs['revise_completed'] ?? false;
          
          _enableReminders = prefs['enable_reminders'] ?? true;
        });
      } else {
        _originalPreferences = _getCurrentState();
      }
    } catch (e) {
      debugPrint('Failed to load study preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load preferences. Using defaults.'), backgroundColor: Colors.orange),
        );
      }
      _originalPreferences = _getCurrentState();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _getCurrentState() {
    return {
      'session_duration': _sessionDuration,
      'break_duration': _breakDuration,
      'explanation_preference': _explanationPreference,
      'show_question_numbering': _showQuestionNumbering,
      'show_answer_feedback': _showAnswerFeedback,
      'show_explanations_after_submit': _showExplanationsAfterSubmit,
      'show_progress': _showProgress,
      'revise_bookmarked': _reviseBookmarked,
      'revise_incorrect': _reviseIncorrect,
      'revise_completed': _reviseCompleted,
      'enable_reminders': _enableReminders,
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
            .update({'study_preferences': current})
            .eq('id', user.id);
            
        if (mounted) {
          setState(() => _originalPreferences = Map.from(current));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Study preferences saved successfully.')),
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
        content: const Text('You have unsaved study preferences. Leave without saving?', style: TextStyle(color: Color(0xFF0F0F11))),
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
              Text('Study Preferences', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Customize how you study, practice, and review.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
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
                  _buildSummaryCard(isDark),
                  const SizedBox(height: 32),
                  _buildSessionStructureSection(isDark),
                  const SizedBox(height: 24),
                  _buildExplanationsSection(isDark),
                  const SizedBox(height: 24),
                  _buildDisplaySection(isDark),
                  const SizedBox(height: 24),
                  _buildRevisionSection(isDark),
                  const SizedBox(height: 24),
                  _buildRemindersSection(isDark),
                  const SizedBox(height: 32),
                  _buildInfoCard(isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(bool isDark) {
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
              const Icon(Icons.psychology_outlined, color: Color(0xFF5A31F4)),
              const SizedBox(width: 12),
              Text('Experience Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSummaryChip('$_sessionDuration min sessions', Icons.timer_outlined, isDark),
              _buildSummaryChip('$_explanationPreference Explanations', Icons.description_outlined, isDark),
              if (_reviseBookmarked) _buildSummaryChip('Revise Bookmarked', Icons.bookmark_border, isDark),
              if (_reviseIncorrect) _buildSummaryChip('Revise Incorrect', Icons.close, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, IconData icon, bool isDark) {
    return Chip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF5A31F4)),
      label: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
      side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
    );
  }

  Widget _buildSessionStructureSection(bool isDark) {
    return _buildSection(
      title: 'Session Structure',
      icon: Icons.access_time_outlined,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Session Duration', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : Colors.grey[800])),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [25, 45, 60, 90].map((mins) => _buildChoiceChip('$mins min', _sessionDuration == mins, () => setState(() => _sessionDuration = mins), isDark)).toList(),
          ),
          const SizedBox(height: 20),
          Text('Break Duration', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : Colors.grey[800])),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5, 10, 15].map((mins) => _buildChoiceChip('$mins min', _breakDuration == mins, () => setState(() => _breakDuration = mins), isDark)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5A31F4) : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF5A31F4) : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationsSection(bool isDark) {
    return _buildSection(
      title: 'Question Explanations',
      icon: Icons.lightbulb_outline,
      isDark: isDark,
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text('Detailed Explanations', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontWeight: FontWeight.w600)),
            subtitle: Text('Show step-by-step reasoning where available.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
            value: 'detailed',
            groupValue: _explanationPreference,
            activeColor: const Color(0xFF5A31F4),
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              if (val != null) setState(() => _explanationPreference = val);
            },
          ),
          RadioListTile<String>(
            title: Text('Concise Explanations', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontWeight: FontWeight.w600)),
            subtitle: Text('Show only the core logic and correct answer.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
            value: 'concise',
            groupValue: _explanationPreference,
            activeColor: const Color(0xFF5A31F4),
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              if (val != null) setState(() => _explanationPreference = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySection(bool isDark) {
    return _buildSection(
      title: 'Practice Display',
      icon: Icons.visibility_outlined,
      isDark: isDark,
      child: Column(
        children: [
          _buildSwitchListTile('Show Question Numbering', 'Display "Question 1 of 10" during practice.', _showQuestionNumbering, (val) => setState(() => _showQuestionNumbering = val), isDark),
          _buildSwitchListTile('Display Answer Feedback', 'Immediately highlight if an answer was correct.', _showAnswerFeedback, (val) => setState(() => _showAnswerFeedback = val), isDark),
          _buildSwitchListTile('Show Explanations After Submit', 'Auto-expand the explanation after submitting.', _showExplanationsAfterSubmit, (val) => setState(() => _showExplanationsAfterSubmit = val), isDark),
          _buildSwitchListTile('Show Progress Indicator', 'Display a progress bar during sessions.', _showProgress, (val) => setState(() => _showProgress = val), isDark),
        ],
      ),
    );
  }

  Widget _buildRevisionSection(bool isDark) {
    return _buildSection(
      title: 'Revision Behavior',
      icon: Icons.replay_outlined,
      isDark: isDark,
      child: Column(
        children: [
          _buildSwitchListTile('Include Bookmarked', 'Prioritize bookmarked questions in revision.', _reviseBookmarked, (val) => setState(() => _reviseBookmarked = val), isDark),
          _buildSwitchListTile('Include Incorrect', 'Target previously incorrect questions.', _reviseIncorrect, (val) => setState(() => _reviseIncorrect = val), isDark),
          _buildSwitchListTile('Include Completed Topics', 'Re-test topics already marked as mastered.', _reviseCompleted, (val) => setState(() => _reviseCompleted = val), isDark),
        ],
      ),
    );
  }

  Widget _buildRemindersSection(bool isDark) {
    return _buildSection(
      title: 'Study Reminders',
      icon: Icons.notifications_none,
      isDark: isDark,
      child: Column(
        children: [
          _buildSwitchListTile('Enable Study Reminders', 'Allow GovPrep AI to send local notifications.', _enableReminders, (val) => setState(() => _enableReminders = val), isDark),
          if (_enableReminders)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate to explicit reminder/notification settings if they exist
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Advanced reminder scheduling is managed in Notification Settings.')));
                  },
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: const Text('Configure Schedule'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF5A31F4)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchListTile(String title, String subtitle, bool value, Function(bool) onChanged, bool isDark) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF5A31F4),
      contentPadding: EdgeInsets.zero,
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

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3B3B1F) : const Color(0xFFFDF0D5).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF3B3B1F) : const Color(0xFFFDF0D5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: isDark ? const Color(0xFFFFD700) : const Color(0xFFB8860B)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personalization Notice', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                const SizedBox(height: 8),
                Text(
                  'Your study preferences influence how practice sessions and mock tests behave. If an exam restricts certain features (like immediate explanations), strict exam rules will override these preferences.',
                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
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
                    _sessionDuration = _originalPreferences!['session_duration'] ?? 25;
                    _breakDuration = _originalPreferences!['break_duration'] ?? 5;
                    _explanationPreference = _originalPreferences!['explanation_preference'] ?? 'detailed';
                    _showQuestionNumbering = _originalPreferences!['show_question_numbering'] ?? true;
                    _showAnswerFeedback = _originalPreferences!['show_answer_feedback'] ?? true;
                    _showExplanationsAfterSubmit = _originalPreferences!['show_explanations_after_submit'] ?? true;
                    _showProgress = _originalPreferences!['show_progress'] ?? true;
                    _reviseBookmarked = _originalPreferences!['revise_bookmarked'] ?? true;
                    _reviseIncorrect = _originalPreferences!['revise_incorrect'] ?? true;
                    _reviseCompleted = _originalPreferences!['revise_completed'] ?? false;
                    _enableReminders = _originalPreferences!['enable_reminders'] ?? true;
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
                  : const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
