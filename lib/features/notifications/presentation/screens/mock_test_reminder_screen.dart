import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class MockTestData {
  final String id;
  final String title;
  final String examCategory;
  final String subject;
  final DateTime scheduledDate;
  final int durationMinutes;
  final int questionsCount;
  final int maximumMarks;
  final bool isAttempted;
  final String instructions;
  
  MockTestData({
    required this.id,
    required this.title,
    required this.examCategory,
    required this.subject,
    required this.scheduledDate,
    required this.durationMinutes,
    required this.questionsCount,
    required this.maximumMarks,
    required this.isAttempted,
    required this.instructions,
  });

  bool get isPast => DateTime.now().isAfter(scheduledDate);
  bool get canStart => !isAttempted; // Add more robust rules later based on time constraints if needed
}

class MockTestReminderScreen extends ConsumerStatefulWidget {
  final String reminderId;

  const MockTestReminderScreen({
    super.key,
    required this.reminderId,
  });

  @override
  ConsumerState<MockTestReminderScreen> createState() => _MockTestReminderScreenState();
}

class _MockTestReminderScreenState extends ConsumerState<MockTestReminderScreen> {
  bool _isLoading = true;
  String? _error;
  MockTestData? _testData;
  Timer? _timer;
  
  // Simulated reminder config
  bool _reminderEnabled = true;
  String _selectedInterval = '30 minutes before';
  bool _isProcessingAction = false;

  final List<String> _intervals = [
    'At test time',
    '10 minutes before',
    '30 minutes before',
    'One hour before',
  ];

  @override
  void initState() {
    super.initState();
    _fetchTestDetails();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {}); // Refresh countdown
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTestDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (widget.reminderId == 'invalid') {
        _testData = null;
      } else {
        _testData = MockTestData(
          id: widget.reminderId,
          title: 'Full Length Mock Test - 3',
          examCategory: 'TNPSC Group 4',
          subject: 'General Studies & Tamil',
          scheduledDate: DateTime.now().add(const Duration(days: 1, hours: 2, minutes: 15)),
          durationMinutes: 180,
          questionsCount: 200,
          maximumMarks: 300,
          isAttempted: false,
          instructions: 'Ensure you have a stable internet connection. You cannot pause the test once started. Submit your answers before the timer runs out.',
        );
      }
      
    } catch (e) {
      _error = 'Failed to load mock test details.';
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
            content: Text(enable ? 'Test reminder enabled.' : 'Test reminder disabled.'),
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
        title: const Text('Mock Test Reminder', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
              onPressed: _fetchTestDetails,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_testData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Test Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('The requested mock test could not be found.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/mock-tests'),
              child: const Text('View All Mock Tests'),
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
                    'Be ready for your next practice test.',
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
                              _buildMainTestCard(),
                              const SizedBox(height: 24),
                              _buildTestInformationCard(),
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
                              _buildCountdownCard(),
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
                        _buildMainTestCard(),
                        const SizedBox(height: 24),
                        _buildCountdownCard(),
                        const SizedBox(height: 24),
                        _buildTestInformationCard(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
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

  Widget _buildMainTestCard() {
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
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment, color: Colors.deepPurple, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _testData!.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_testData!.examCategory} • ${_testData!.subject}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Questions', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${_testData!.questionsCount}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Marks', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${_testData!.maximumMarks}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Duration', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${_testData!.durationMinutes} min',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard() {
    final now = DateTime.now();
    final isPast = _testData!.isPast;
    
    String countdownText = '';
    
    if (isPast) {
      countdownText = 'Scheduled time has passed';
    } else {
      final difference = _testData!.scheduledDate.difference(now);
      if (difference.inDays > 0) {
        countdownText = '${difference.inDays} days, ${difference.inHours % 24} hours';
      } else if (difference.inHours > 0) {
        countdownText = '${difference.inHours} hours, ${difference.inMinutes % 60} mins';
      } else {
        countdownText = '${difference.inMinutes} minutes';
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFF3F4F6) : const Color(0xFFFDF0D5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPast ? Colors.grey[300]! : Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPast ? Icons.history : Icons.access_time, 
                color: isPast ? Colors.grey[700] : Colors.orange[800], 
                size: 20
              ),
              const SizedBox(width: 8),
              Text(
                isPast ? 'Status' : 'Starts In', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: isPast ? Colors.grey[800] : Colors.orange[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            countdownText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPast ? Colors.grey[900] : Colors.orange[900],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(color: isPast ? Colors.grey[700] : Colors.orange[800], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(_testData!.scheduledDate),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isPast ? Colors.grey[900] : Colors.orange[900]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(color: isPast ? Colors.grey[700] : Colors.orange[800], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(_testData!.scheduledDate),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isPast ? Colors.grey[900] : Colors.orange[900]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestInformationCard() {
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
          const Text('Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _testData!.instructions,
                    style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 14),
                  ),
                ),
              ],
            ),
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
              const Text('Test Reminder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_testData!.canStart)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/mock-tests/runner/${_testData!.id}'),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A31F4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            if (_testData!.canStart)
              const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/mock-tests/${_testData!.id}'),
                icon: const Icon(Icons.description, size: 18),
                label: const Text('View Test Details'),
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
