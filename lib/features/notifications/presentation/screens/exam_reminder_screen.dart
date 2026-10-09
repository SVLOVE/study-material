import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExamData {
  final String id;
  final String name;
  final String category;
  final DateTime? examDate;
  final String stage;
  final DateTime? applicationDeadline;
  
  ExamData({
    required this.id,
    required this.name,
    required this.category,
    this.examDate,
    required this.stage,
    this.applicationDeadline,
  });
}

class ExamReminderScreen extends ConsumerStatefulWidget {
  final String examId;

  const ExamReminderScreen({
    super.key,
    required this.examId,
  });

  @override
  ConsumerState<ExamReminderScreen> createState() => _ExamReminderScreenState();
}

class _ExamReminderScreenState extends ConsumerState<ExamReminderScreen> {
  bool _isLoading = true;
  String? _error;
  ExamData? _examData;
  
  // Simulated reminder config
  bool _reminderEnabled = true;
  String _selectedInterval = 'One week before';
  bool _isProcessingAction = false;

  final List<String> _intervals = [
    'On the exam day',
    'One day before',
    'Three days before',
    'One week before',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExamDetails();
  }

  Future<void> _fetchExamDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));
      
      final now = DateTime.now();
      
      if (widget.examId == 'invalid') {
        _examData = null;
      } else {
        _examData = ExamData(
          id: widget.examId,
          name: 'TNPSC Group 4',
          category: 'TNPSC',
          examDate: now.add(const Duration(days: 45, hours: 3)),
          stage: 'Preliminary',
          applicationDeadline: now.subtract(const Duration(days: 10)),
        );
      }
      
    } catch (e) {
      _error = 'Failed to load exam details.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleToggleReminder(bool enable) async {
    setState(() => _isProcessingAction = true);
    
    try {
      // Simulate backend sync
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _reminderEnabled = enable;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable ? 'Reminder enabled.' : 'Reminder disabled.'),
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
      // Simulate backend sync
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _selectedInterval = newValue;
          _reminderEnabled = true; // Auto enable if they change interval
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
        title: const Text('Exam Reminder', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
              onPressed: _fetchExamDetails,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_examData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Exam Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('The requested exam details could not be found.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/notifications'),
              child: const Text('Back to Notifications'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Review your upcoming exam details and manage reminder preferences.',
                    style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildExamSummaryCard(),
                  const SizedBox(height: 24),
                  _buildCountdownCard(),
                  const SizedBox(height: 24),
                  _buildReminderConfigurationCard(),
                  const SizedBox(height: 24),
                  _buildPreparationActions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamSummaryCard() {
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: Color(0xFF5A31F4), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_examData!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text('${_examData!.category} • ${_examData!.stage}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Exam Date',
                  _examData!.examDate != null ? DateFormat('MMM d, yyyy').format(_examData!.examDate!) : 'Not available',
                  Icons.event,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Deadline',
                  _examData!.applicationDeadline != null ? DateFormat('MMM d, yyyy').format(_examData!.applicationDeadline!) : 'Not available',
                  Icons.timer_off,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownCard() {
    if (_examData!.examDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final difference = _examData!.examDate!.difference(now);
    
    if (difference.isNegative) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text('Exam date has passed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your exam is approaching', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${difference.inDays}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange[900]),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Days remaining',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderConfigurationCard() {
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
              const Text('Reminder Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              if (_isProcessingAction)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              if (!_isProcessingAction)
                Switch(
                  value: _reminderEnabled,
                  onChanged: _handleToggleReminder,
                  activeColor: const Color(0xFF5A31F4),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _reminderEnabled ? 'You will be notified based on your selected interval.' : 'Reminders for this exam are currently disabled.',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          if (_reminderEnabled) ...[
            const SizedBox(height: 24),
            const Text('Notify me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11))),
            const SizedBox(height: 12),
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
                      child: Text(value),
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

  Widget _buildPreparationActions() {
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
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: const Text('Start Practice'),
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
                onPressed: () => context.go('/syllabus'), // Placeholder for existing related screen
                icon: const Icon(Icons.menu_book, size: 18),
                label: const Text('View Syllabus'),
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
