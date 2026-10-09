import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreparationPreferencesScreen extends ConsumerStatefulWidget {
  const PreparationPreferencesScreen({super.key});

  @override
  ConsumerState<PreparationPreferencesScreen> createState() => _PreparationPreferencesScreenState();
}

class _PreparationPreferencesScreenState extends ConsumerState<PreparationPreferencesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Form State
  String? _dailyTarget;
  String? _studySession;
  final Set<String> _practiceFormats = {};
  String? _revisionPreference;
  String? _difficultyPreference;
  final Set<String> _studyGoals = {};

  // Original State (to check for unsaved changes)
  String? _originalDailyTarget;
  String? _originalStudySession;
  Set<String> _originalPracticeFormats = {};
  String? _originalRevisionPreference;
  String? _originalDifficultyPreference;
  Set<String> _originalStudyGoals = {};

  // Options
  final List<String> _dailyTargets = ['30 minutes', '1 hour', '2 hours', '3 hours', '4 hours', '4+ hours'];
  final List<String> _studySessions = ['Early Morning', 'Morning', 'Afternoon', 'Evening', 'Night', 'Flexible Schedule'];
  final List<String> _availablePracticeFormats = [
    'Topic-wise practice',
    'Subject-wise practice',
    'Full-length mock tests',
    'Sectional tests',
    'Daily practice questions',
    'Previous-year papers',
  ];
  final List<String> _revisionOptions = [
    'Daily revision',
    'Every few days',
    'Weekly revision',
    'Before a mock test',
    'No fixed schedule'
  ];
  final List<String> _difficultyOptions = ['Easy', 'Moderate', 'Difficult', 'Adaptive'];
  final List<String> _availableGoals = [
    'Build a consistent habit',
    'Complete the syllabus',
    'Improve accuracy',
    'Improve speed',
    'Upcoming examinations',
    'Strengthen weak topics',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
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

      final response = await Supabase.instance.client
          .from('profiles')
          .select('daily_study_target, preferred_study_session, practice_formats, revision_preference, difficulty_preference, study_goals')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _originalDailyTarget = response['daily_study_target'] as String?;
        _originalStudySession = response['preferred_study_session'] as String?;
        _originalRevisionPreference = response['revision_preference'] as String?;
        _originalDifficultyPreference = response['difficulty_preference'] as String?;

        if (response['practice_formats'] != null) {
          final List<dynamic> formats = response['practice_formats'];
          _originalPracticeFormats = formats.map((e) => e.toString()).toSet();
        }
        if (response['study_goals'] != null) {
          final List<dynamic> goals = response['study_goals'];
          _originalStudyGoals = goals.map((e) => e.toString()).toSet();
        }

        // Apply to current state
        _dailyTarget = _originalDailyTarget;
        _studySession = _originalStudySession;
        _revisionPreference = _originalRevisionPreference;
        _difficultyPreference = _originalDifficultyPreference;
        _practiceFormats.addAll(_originalPracticeFormats);
        _studyGoals.addAll(_originalStudyGoals);
      }
    } catch (e) {
      debugPrint('Failed to load preparation preferences. Some columns might be missing: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _hasChanges {
    if (_dailyTarget != _originalDailyTarget) return true;
    if (_studySession != _originalStudySession) return true;
    if (_revisionPreference != _originalRevisionPreference) return true;
    if (_difficultyPreference != _originalDifficultyPreference) return true;
    if (_practiceFormats.length != _originalPracticeFormats.length || !_practiceFormats.containsAll(_originalPracticeFormats)) return true;
    if (_studyGoals.length != _originalStudyGoals.length || !_studyGoals.containsAll(_originalStudyGoals)) return true;
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges || _isSaving) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Discard changes?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: const Text('You have unsaved preparation preferences. Are you sure you want to leave?', style: TextStyle(color: Color(0xFF0F0F11))),
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

  Future<void> _saveChanges() async {
    if (!_hasChanges) return;

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final payload = {
          'daily_study_target': _dailyTarget,
          'preferred_study_session': _studySession,
          'practice_formats': _practiceFormats.toList(),
          'revision_preference': _revisionPreference,
          'difficulty_preference': _difficultyPreference,
          'study_goals': _studyGoals.toList(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await Supabase.instance.client
            .from('profiles')
            .update(payload)
            .eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preparation preferences updated successfully.')),
          );
          
          _originalDailyTarget = _dailyTarget;
          _originalStudySession = _studySession;
          _originalPracticeFormats = Set.from(_practiceFormats);
          _originalRevisionPreference = _revisionPreference;
          _originalDifficultyPreference = _difficultyPreference;
          _originalStudyGoals = Set.from(_studyGoals);
          
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Your backend schema might not support these preference columns yet.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _discardChanges() {
    setState(() {
      _dailyTarget = _originalDailyTarget;
      _studySession = _originalStudySession;
      _revisionPreference = _originalRevisionPreference;
      _difficultyPreference = _originalDifficultyPreference;
      
      _practiceFormats.clear();
      _practiceFormats.addAll(_originalPracticeFormats);
      
      _studyGoals.clear();
      _studyGoals.addAll(_originalStudyGoals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop()) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAE4F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) context.pop();
              }
            },
          ),
          title: Column(
            children: [
              const Text('Preparation Preferences', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Build a study routine that works for you', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
        bottomNavigationBar: _hasChanges ? _buildStickyActions() : null,
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
            Text(_error!, style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPreferences,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
                  _buildSummaryCard(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('1. Daily Study Target', 'Set a realistic goal for your daily preparation time.'),
                  const SizedBox(height: 16),
                  _buildDailyTargetSelector(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('2. Preferred Study Session', 'When do you focus the best?'),
                  const SizedBox(height: 16),
                  _buildStudySessionSelector(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('3. Practice Formats', 'Select multiple formats you want to include in your routine.'),
                  const SizedBox(height: 16),
                  _buildPracticeFormatsSelector(constraints.maxWidth),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('4. Revision Habit', 'How often do you plan to revise?'),
                  const SizedBox(height: 16),
                  _buildRevisionSelector(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('5. Practice Difficulty', 'Choose how you want your questions delivered.'),
                  const SizedBox(height: 16),
                  _buildDifficultySelector(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('6. Preparation Goals', 'What are you aiming to achieve right now?'),
                  const SizedBox(height: 16),
                  _buildGoalsSelector(constraints.maxWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    bool hasAnySelection = _dailyTarget != null || _studySession != null || _practiceFormats.isNotEmpty || _revisionPreference != null || _studyGoals.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF9F8FD), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.analytics_outlined, color: Color(0xFF5A31F4), size: 20),
              ),
              const SizedBox(width: 16),
              const Text('Your Routine Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasAnySelection)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'You haven\'t configured your preferences yet. Fill out the sections below to personalize your GovPrep AI experience.',
                style: TextStyle(color: Colors.grey[600], height: 1.4, fontStyle: FontStyle.italic),
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                if (_dailyTarget != null) _buildSummaryChip(Icons.timer_outlined, _dailyTarget!),
                if (_studySession != null) _buildSummaryChip(Icons.wb_sunny_outlined, _studySession!),
                if (_revisionPreference != null) _buildSummaryChip(Icons.replay_outlined, _revisionPreference!),
                if (_practiceFormats.isNotEmpty) _buildSummaryChip(Icons.menu_book_outlined, '${_practiceFormats.length} Formats'),
                if (_studyGoals.isNotEmpty) _buildSummaryChip(Icons.flag_outlined, '${_studyGoals.length} Goals'),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildSummaryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4DBF6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF5A31F4)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F0F11), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildDailyTargetSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _dailyTargets.map((target) {
        final isSelected = _dailyTarget == target;
        return ChoiceChip(
          label: Text(target),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _dailyTarget = selected ? target : null);
          },
          selectedColor: const Color(0xFF5A31F4),
          labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF0F0F11), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          backgroundColor: Colors.white,
          side: BorderSide(color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        );
      }).toList(),
    );
  }

  Widget _buildStudySessionSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _studySessions.map((session) {
        final isSelected = _studySession == session;
        return ChoiceChip(
          label: Text(session),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _studySession = selected ? session : null);
          },
          selectedColor: const Color(0xFFE4DBF6),
          labelStyle: TextStyle(color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          backgroundColor: Colors.white,
          side: BorderSide(color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        );
      }).toList(),
    );
  }

  Widget _buildPracticeFormatsSelector(double maxWidth) {
    int crossAxisCount = maxWidth > 600 ? 2 : 1;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 4.5,
      ),
      itemCount: _availablePracticeFormats.length,
      itemBuilder: (context, index) {
        final format = _availablePracticeFormats[index];
        final isSelected = _practiceFormats.contains(format);
        
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _practiceFormats.remove(format);
              } else {
                _practiceFormats.add(format);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF9F8FD) : Colors.white,
              border: Border.all(color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    format,
                    style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF0F0F11)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevisionSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: _revisionOptions.map((option) {
          final isSelected = _revisionPreference == option;
          final isLast = _revisionOptions.last == option;
          
          return Column(
            children: [
              RadioListTile<String>(
                title: Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                value: option,
                groupValue: _revisionPreference,
                onChanged: (value) => setState(() => _revisionPreference = value),
                activeColor: const Color(0xFF5A31F4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _difficultyOptions.map((diff) {
        final isSelected = _difficultyPreference == diff;
        // Adaptive is just a label for now until supported
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(diff),
              if (diff == 'Adaptive') ...[
                const SizedBox(width: 4),
                const Icon(Icons.bolt, size: 14, color: Colors.orange),
              ]
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _difficultyPreference = selected ? diff : null);
          },
          selectedColor: const Color(0xFFE4DBF6),
          labelStyle: TextStyle(color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          backgroundColor: Colors.white,
          side: BorderSide(color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        );
      }).toList(),
    );
  }

  Widget _buildGoalsSelector(double maxWidth) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableGoals.map((goal) {
        final isSelected = _studyGoals.contains(goal);
        
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _studyGoals.remove(goal);
              } else {
                _studyGoals.add(goal);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF9F8FD) : Colors.white,
              border: Border.all(color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  goal,
                  style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF0F0F11)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStickyActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving ? null : _discardChanges,
              child: const Text('Discard', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
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
