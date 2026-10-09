import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class StudyTask {
  final String id;
  final String title;
  final String subject;
  final String topic;
  final String type; // 'Practice', 'Mock Test', 'Revision'
  final int durationMinutes;
  final int questionCount;
  final bool isCompleted;

  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.type,
    required this.durationMinutes,
    this.questionCount = 0,
    this.isCompleted = false,
  });
}

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  bool _isLoading = true;
  final String _targetExam = 'UPSC Civil Services'; // Simulated backend response
  List<StudyTask> _todayTasks = [];
  
  // Simulated weekly overview completion states (Mon to Sun)
  final List<bool> _weeklyCompletion = [true, true, false, true, false, false, false];

  @override
  void initState() {
    super.initState();
    _fetchPlannerData();
  }

  Future<void> _fetchPlannerData() async {
    setState(() => _isLoading = true);
    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));
      
      _todayTasks = [
        StudyTask(
          id: 't_1',
          title: 'General Studies Practice',
          subject: 'Indian Polity',
          topic: 'Fundamental Rights',
          type: 'Practice',
          durationMinutes: 20,
          questionCount: 20,
          isCompleted: false,
        ),
        StudyTask(
          id: 't_2',
          title: 'Current Affairs Review',
          subject: 'General Awareness',
          topic: 'October 2026',
          type: 'Revision',
          durationMinutes: 15,
          isCompleted: true,
        ),
        StudyTask(
          id: 't_3',
          title: 'Percentages Practice',
          subject: 'Quantitative Aptitude',
          topic: 'Percentages',
          type: 'Practice',
          durationMinutes: 25,
          questionCount: 25,
          isCompleted: false,
        ),
        StudyTask(
          id: 't_4',
          title: 'Sectional Mock Test',
          subject: 'Indian Economy',
          topic: 'Banking & Finance',
          type: 'Mock Test',
          durationMinutes: 30,
          questionCount: 30,
          isCompleted: false,
        ),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleTaskAction(StudyTask task) {
    if (task.isCompleted) return;

    if (task.type == 'Practice' || task.type == 'Revision') {
      context.push('/focus/setup');
    } else if (task.type == 'Mock Test') {
      context.push('/mock-tests');
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
          onPressed: () => context.pop(),
        ),
        title: const Text('Study Planner', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0F0F11)),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preparing for: $_targetExam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              const Text('Stay consistent with a focused preparation plan.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 32),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildTodaySection()),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _buildOverviewSection()),
                      ],
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTodayProgressCard(),
                      const SizedBox(height: 32),
                      _buildDateSelector(),
                      const SizedBox(height: 32),
                      _buildTodaySection(),
                      const SizedBox(height: 48),
                      _buildOverviewSection(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          final isToday = index == 2;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF0F0F11) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isToday ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6)),
            ),
            child: Column(
              children: [
                Text('Oct', style: TextStyle(fontSize: 12, color: isToday ? Colors.white70 : const Color(0xFF0F0F11).withValues(alpha: 0.5))),
                const SizedBox(height: 4),
                Text('${index + 5}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isToday ? Colors.white : const Color(0xFF0F0F11))),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTodayProgressCard() {
    final completedCount = _todayTasks.where((t) => t.isCompleted).length;
    final totalCount = _todayTasks.length;
    final double progress = totalCount > 0 ? (completedCount / totalCount) : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Text('$completedCount of $totalCount tasks completed', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF3F4F6),
              color: Colors.green,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (MediaQuery.of(context).size.width >= 800) ...[
          _buildTodayProgressCard(),
          const SizedBox(height: 32),
          _buildDateSelector(),
          const SizedBox(height: 32),
        ],
        const Text('Today\'s Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        if (_todayTasks.isEmpty)
          const Text('Your Study Plan Is Empty. Create a focused study plan to organize your preparation.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayTasks.length,
            itemBuilder: (context, index) {
              final task = _todayTasks[index];
              return _buildTaskCard(task);
            },
          ),
      ],
    );
  }

  Widget _buildTaskCard(StudyTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: task.isCompleted ? const Color(0xFFE2F0D9) : const Color(0xFFF3F4F6), width: task.isCompleted ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.isCompleted ? Colors.green : const Color(0xFF0F0F11).withValues(alpha: 0.3),
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEAE4F7), borderRadius: BorderRadius.circular(6)),
                      child: Text(task.type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('${task.subject} — ${task.title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11), decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 4),
                Text(task.topic, style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (task.questionCount > 0) ...[
                      Icon(Icons.format_list_numbered, size: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text('${task.questionCount} questions', style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                      const SizedBox(width: 16),
                    ],
                    Icon(Icons.access_time, size: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text('${task.durationMinutes} min', style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                  ],
                ),
                if (!task.isCompleted) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _handleTaskAction(task),
                    child: const Row(
                      children: [
                        Text('Start Task', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('This Week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(6)),
                    child: const Text('7 day study streak', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final completed = _weeklyCompletion[index];
                  final isToday = index == 2;
                  
                  return Column(
                    children: [
                      Text(days[index], style: TextStyle(fontSize: 12, color: isToday ? const Color(0xFF0F0F11) : const Color(0xFF0F0F11).withValues(alpha: 0.5), fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                      const SizedBox(height: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completed ? Colors.green : const Color(0xFFF3F4F6),
                          border: isToday && !completed ? Border.all(color: const Color(0xFF0F0F11), width: 2) : null,
                        ),
                        child: completed ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 32),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 24),
              _buildProgressRow('Study Time', '3h 40m'),
              const SizedBox(height: 12),
              _buildProgressRow('Questions', '184'),
              const SizedBox(height: 12),
              _buildProgressRow('Mock Tests', '2'),
              const SizedBox(height: 12),
              _buildProgressRow('Tasks', '21 / 28'),
            ],
          ),
        ),
        
        const SizedBox(height: 48),
        const Text('Coming Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUpcomingRow('Tomorrow', 'Revision — Indian Economy'),
              const Divider(height: 32, color: Color(0xFFF3F4F6)),
              _buildUpcomingRow('Friday', 'Sectional Mock Test'),
              const Divider(height: 32, color: Color(0xFFF3F4F6)),
              _buildUpcomingRow('Saturday', 'Weak Topic Practice'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildUpcomingRow(String day, String task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE4DBF6))),
            const SizedBox(width: 12),
            Text(task, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
          ],
        ),
      ],
    );
  }
}
