import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SyllabusTopic {
  final String id;
  final String title;
  final String status; // Not Started, Practiced, Revised, Completed
  final double? accuracy;
  final int questionsPracticed;
  final bool isFocusArea;

  SyllabusTopic({
    required this.id,
    required this.title,
    required this.status,
    this.accuracy,
    this.questionsPracticed = 0,
    this.isFocusArea = false,
  });
}

class SyllabusSubject {
  final String id;
  final String title;
  final int totalTopics;
  final int completedTopics;
  final double progress;
  final double? accuracy;
  final List<SyllabusTopic> topics;

  SyllabusSubject({
    required this.id,
    required this.title,
    required this.totalTopics,
    required this.completedTopics,
    required this.progress,
    this.accuracy,
    required this.topics,
  });
}

class ExamSyllabusScreen extends StatefulWidget {
  const ExamSyllabusScreen({super.key});

  @override
  State<ExamSyllabusScreen> createState() => _ExamSyllabusScreenState();
}

class _ExamSyllabusScreenState extends State<ExamSyllabusScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  final String _targetExam = 'UPSC Civil Services';

  List<SyllabusSubject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSyllabus();
  }

  Future<void> _fetchSyllabus() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock network
      _subjects = [
        SyllabusSubject(
          id: 'sub_1',
          title: 'Indian Polity',
          totalTopics: 12,
          completedTopics: 4,
          progress: 0.33,
          accuracy: 0.68,
          topics: [
            SyllabusTopic(id: 't_1', title: 'Fundamental Rights', status: 'Completed', accuracy: 0.81, questionsPracticed: 45),
            SyllabusTopic(id: 't_2', title: 'Directive Principles', status: 'Practiced', accuracy: 0.65, questionsPracticed: 20, isFocusArea: true),
            SyllabusTopic(id: 't_3', title: 'Parliament', status: 'Not Started'),
          ],
        ),
        SyllabusSubject(
          id: 'sub_2',
          title: 'Modern History',
          totalTopics: 18,
          completedTopics: 0,
          progress: 0.0,
          topics: [
            SyllabusTopic(id: 't_4', title: 'Revolt of 1857', status: 'Not Started'),
            SyllabusTopic(id: 't_5', title: 'Indian National Congress', status: 'Not Started'),
          ],
        ),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Exam Syllabus', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target Exam: $_targetExam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              const Text('Explore your complete syllabus, track what you\'ve covered, and practice each topic.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 32),
              
              _buildProgressSummary(),
              const SizedBox(height: 32),
              
              _buildSearchBox(),
              const SizedBox(height: 32),
              
              const Text('Subjects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              
              if (_subjects.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16)),
                  child: const Text('Syllabus not available yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                )
              else
                ..._subjects.map((subject) => _buildSubjectCard(subject)),
                
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
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
              const Text('Overall Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE2F0D9), borderRadius: BorderRadius.circular(8)),
                child: const Text('18% Completed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSummaryMetric('Subjects', '14')),
              Expanded(child: _buildSummaryMetric('Topics', '142')),
              Expanded(child: _buildSummaryMetric('Completed', '26')),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.18,
              backgroundColor: Color(0xFFF3F4F6),
              color: Color(0xFF0F0F11),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('26 of 142 topics completed', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search subjects or topics...',
                hintStyle: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SyllabusSubject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          title: Text(subject.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Text('${subject.totalTopics} topics', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                const SizedBox(width: 12),
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text('${subject.completedTopics} completed', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                if (subject.accuracy != null) ...[
                  const SizedBox(width: 12),
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Text('Acc: ${(subject.accuracy! * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                ]
              ],
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/subjects/${subject.id}'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0F0F11)),
                        foregroundColor: const Color(0xFF0F0F11),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Open Subject Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...subject.topics.map((t) => _buildTopicRow(t)).toList(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopicRow(SyllabusTopic topic) {
    Color statusColor;
    if (topic.status == 'Completed') statusColor = Colors.green;
    else if (topic.status == 'Practiced' || topic.status == 'Revised') statusColor = Colors.blue;
    else statusColor = Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: InkWell(
        onTap: () => context.push('/topics/${topic.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(topic.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                        if (topic.isFocusArea) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Focus Area', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (topic.accuracy != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(topic.accuracy! * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const Text('Accuracy', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/practice'), // Existing practice arena hook
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0F0F11)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Practice', style: TextStyle(color: Color(0xFF0F0F11))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/question-bank'), // Existing question bank hook
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEAE4F7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Questions', style: TextStyle(color: Color(0xFF0F0F11))),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
      ),
    );
  }
}
