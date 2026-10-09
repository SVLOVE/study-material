import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StudySessionData {
  final String id;
  final String title;
  final String subject;
  final String topic;
  final String examCategory;
  final DateTime scheduledDate;
  final int durationMinutes;
  final String learningObjective;
  
  StudySessionData({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.examCategory,
    required this.scheduledDate,
    required this.durationMinutes,
    required this.learningObjective,
  });
}

class StudyReminderScreen extends ConsumerStatefulWidget {
  final String reminderId;

  const StudyReminderScreen({
    super.key,
    required this.reminderId,
  });

  @override
  ConsumerState<StudyReminderScreen> createState() => _StudyReminderScreenState();
}

class _StudyReminderScreenState extends ConsumerState<StudyReminderScreen> {
  bool _isLoading = true;
  String? _error;
  StudySessionData? _sessionData;
  List<StudySessionData> _upcomingSessions = [];
  
  // Simulated reminder config
  bool _reminderEnabled = true;
  String _selectedInterval = '30 minutes before';
  bool _isProcessingAction = false;

  final List<String> _intervals = [
    'At the scheduled time',
    '10 minutes before',
    '30 minutes before',
    'One hour before',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudyReminder();
  }

  Future<void> _fetchStudyReminder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));
      
      final now = DateTime.now();
      
      if (widget.reminderId == 'invalid') {
        _sessionData = null;
      } else {
        _sessionData = StudySessionData(
          id: widget.reminderId,
          title: 'Indian Polity - Constitution Basics',
          subject: 'General Studies',
          topic: 'Making of the Constitution',
          examCategory: 'TNPSC Group 4',
          scheduledDate: now.add(const Duration(hours: 2)),
          durationMinutes: 120,
          learningObjective: 'Understand the key committees, drafting process, and major sources of the Indian Constitution.',
        );
        
        _upcomingSessions = [
          StudySessionData(
            id: 'session_2',
            title: 'Quantitative Aptitude - Ratio',
            subject: 'Mathematics',
            topic: 'Ratio and Proportion',
            examCategory: 'TNPSC Group 4',
            scheduledDate: now.add(const Duration(days: 1, hours: 2)),
            durationMinutes: 90,
            learningObjective: 'Master advanced ratio problems and mixture concepts.',
          ),
          StudySessionData(
            id: 'session_3',
            title: 'Current Affairs Weekly',
            subject: 'Current Affairs',
            topic: 'May 2026 Week 1',
            examCategory: 'TNPSC Group 4',
            scheduledDate: now.add(const Duration(days: 2, hours: 5)),
            durationMinutes: 60,
            learningObjective: 'Review important national and state-level events.',
          ),
        ];
      }
      
    } catch (e) {
      _error = 'Failed to load study reminder details.';
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
            content: Text(enable ? 'Study reminder enabled.' : 'Study reminder disabled.'),
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

  Future<void> _handleIntervalChange(String? newValue) async {
    if (newValue == null || newValue == _selectedInterval) return;
    
    setState(() => _isProcessingAction = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _selectedInterval = newValue;
          _reminderEnabled = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set to: $newValue'),
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
        title: const Text('Study Reminder', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
              onPressed: _fetchStudyReminder,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sessionData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Session Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('The requested study session could not be found.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('View Study Planner'),
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
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Stay consistent with your exam preparation.',
                    style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMainSessionCard(),
                              const SizedBox(height: 24),
                              _buildSessionDetailsCard(),
                              const SizedBox(height: 24),
                              _buildActionsCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSettingsCard(),
                              const SizedBox(height: 24),
                              _buildUpcomingSessionsList(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMainSessionCard(),
                        const SizedBox(height: 24),
                        _buildSessionDetailsCard(),
                        const SizedBox(height: 24),
                        _buildActionsCard(),
                        const SizedBox(height: 24),
                        _buildSettingsCard(),
                        const SizedBox(height: 24),
                        _buildUpcomingSessionsList(),
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

  Widget _buildMainSessionCard() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book, color: Colors.teal, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sessionData!.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _sessionData!.subject,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Color(0xFF5A31F4)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(_sessionData!.scheduledDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                            ),
                            Text(
                              DateFormat('h:mm a').format(_sessionData!.scheduledDate),
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE4DBF6)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 18, color: Color(0xFF5A31F4)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_sessionData!.durationMinutes} min',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                              ),
                              Text(
                                'Duration',
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetailsCard() {
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
          const Text('Session Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildDetailRow('Exam', _sessionData!.examCategory),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Topic', _sessionData!.topic),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          _buildDetailRow('Objective', _sessionData!.learningObjective),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 14, height: 1.4)),
        ),
      ],
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
              const Text('Reminder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
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
            const Text('Notify me', style: TextStyle(fontSize: 14, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE4DBF6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedInterval,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5A31F4)),
                  items: _intervals.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: _isProcessingAction ? null : _handleIntervalChange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionsList() {
    if (_upcomingSessions.isEmpty) return const SizedBox.shrink();

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
          const Text('Upcoming in your plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingSessions.length,
            separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final session = _upcomingSessions[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMM').format(session.scheduledDate),
                          style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('d').format(session.scheduledDate),
                          style: const TextStyle(color: Color(0xFF5A31F4), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${session.durationMinutes} min • ${session.subject}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.go('/dashboard'), // Assuming planner is in dashboard
              child: const Text('View Full Calendar', style: TextStyle(color: Color(0xFF5A31F4))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Start Session'),
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
                onPressed: () => context.go('/materials'),
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('View Materials'),
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
