import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DailyGoalData {
  final String id;
  final int studyTimeTargetMinutes;
  final int studyTimeCompletedMinutes;
  final int questionsTarget;
  final int questionsCompleted;
  final int topicsTarget;
  final int topicsCompleted;
  
  DailyGoalData({
    required this.id,
    required this.studyTimeTargetMinutes,
    required this.studyTimeCompletedMinutes,
    required this.questionsTarget,
    required this.questionsCompleted,
    required this.topicsTarget,
    required this.topicsCompleted,
  });

  bool get isCompleted =>
      studyTimeCompletedMinutes >= studyTimeTargetMinutes &&
      questionsCompleted >= questionsTarget &&
      topicsCompleted >= topicsTarget;
}

class DailyGoalReminderScreen extends ConsumerStatefulWidget {
  final String reminderId;

  const DailyGoalReminderScreen({
    super.key,
    required this.reminderId,
  });

  @override
  ConsumerState<DailyGoalReminderScreen> createState() => _DailyGoalReminderScreenState();
}

class _DailyGoalReminderScreenState extends ConsumerState<DailyGoalReminderScreen> {
  bool _isLoading = true;
  String? _error;
  DailyGoalData? _goalData;
  
  // Simulated reminder config
  bool _reminderEnabled = true;
  String _selectedTime = '08:00 AM';
  bool _isProcessingAction = false;

  final List<String> _times = [
    '06:00 AM',
    '07:00 AM',
    '08:00 AM',
    '09:00 AM',
    '05:00 PM',
    '06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _fetchGoalDetails();
  }

  Future<void> _fetchGoalDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (widget.reminderId == 'invalid') {
        _goalData = null;
      } else {
        // Mock progress (partially completed)
        _goalData = DailyGoalData(
          id: widget.reminderId,
          studyTimeTargetMinutes: 180,
          studyTimeCompletedMinutes: 120,
          questionsTarget: 50,
          questionsCompleted: 20,
          topicsTarget: 3,
          topicsCompleted: 1,
        );
      }
      
    } catch (e) {
      _error = 'Failed to load daily goal details.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleToggleReminder(bool enable) async {
    setState(() => _isProcessingAction = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _reminderEnabled = enable;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable ? 'Daily reminder enabled.' : 'Daily reminder disabled.'),
            backgroundColor: const Color(0xFF5A31F4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _handleTimeChange(String? newValue) async {
    if (newValue == null || newValue == _selectedTime) return;
    
    setState(() => _isProcessingAction = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _selectedTime = newValue;
          _reminderEnabled = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily reminder scheduled for $newValue'),
            backgroundColor: const Color(0xFF5A31F4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
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
              context.go('/notifications');
            }
          },
        ),
        title: const Text('Daily Goal', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
              onPressed: _fetchGoalDetails,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_goalData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Goal Configured', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('You haven\'t set a daily preparation goal yet.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Set Daily Goal'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Keep your preparation on track, one day at a time.',
                    style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildGoalProgressSection(),
                              const SizedBox(height: 24),
                              _buildQuickActions(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMotivationCard(),
                              const SizedBox(height: 24),
                              _buildSettingsCard(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGoalProgressSection(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildMotivationCard(),
                        const SizedBox(height: 24),
                        _buildSettingsCard(),
                      ],
                    ),
                    
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalProgressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _goalData!.isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _goalData!.isCompleted ? 'Completed' : 'In Progress',
                  style: TextStyle(
                    color: _goalData!.isCompleted ? Colors.green[800] : Colors.orange[900],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildProgressIndicator(
            label: 'Study Time',
            completed: _goalData!.studyTimeCompletedMinutes,
            target: _goalData!.studyTimeTargetMinutes,
            unit: 'min',
            color: const Color(0xFF5A31F4),
            icon: Icons.timer,
          ),
          const SizedBox(height: 24),
          _buildProgressIndicator(
            label: 'Practice Questions',
            completed: _goalData!.questionsCompleted,
            target: _goalData!.questionsTarget,
            unit: 'questions',
            color: Colors.orange,
            icon: Icons.quiz,
          ),
          const SizedBox(height: 24),
          _buildProgressIndicator(
            label: 'Topics to Cover',
            completed: _goalData!.topicsCompleted,
            target: _goalData!.topicsTarget,
            unit: 'topics',
            color: Colors.teal,
            icon: Icons.menu_book,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator({
    required String label,
    required int completed,
    required int target,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    final double safeTarget = target > 0 ? target.toDouble() : 1.0;
    final double progress = (completed / safeTarget).clamp(0.0, 1.0);
    final bool isDone = completed >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const Spacer(),
            Text(
              '$completed / $target $unit',
              style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.green : Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(isDone ? Colors.green : color),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0D9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, color: Colors.green[800], size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            _goalData!.isCompleted 
                ? 'Fantastic work today!' 
                : 'Keep going!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900]),
          ),
          const SizedBox(height: 8),
          Text(
            _goalData!.isCompleted 
                ? 'You reached all your daily targets. Take a well-deserved break.'
                : 'Small daily steps build strong preparation habits. Continue with your next planned study activity.',
            style: TextStyle(color: Colors.green[900], height: 1.4, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Reminder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              if (_isProcessingAction)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Switch(
                  value: _reminderEnabled,
                  onChanged: _handleToggleReminder,
                  activeColor: const Color(0xFF5A31F4),
                ),
            ],
          ),
          if (_reminderEnabled) ...[
            const SizedBox(height: 16),
            const Text('Notify me every day at', style: TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE4DBF6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTime,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5A31F4)),
                  items: _times.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: _isProcessingAction ? null : _handleTimeChange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resume Preparation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.menu_book, size: 18),
                label: const Text('Continue Studying'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A31F4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/dashboard'), // Assuming practice is accessible from dashboard
                icon: const Icon(Icons.quiz, size: 18),
                label: const Text('Practice Questions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F0F11),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFE4DBF6), width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
