import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/glow_button.dart';

class AdminManageSyllabusScreen extends StatefulWidget {
  const AdminManageSyllabusScreen({super.key});

  @override
  State<AdminManageSyllabusScreen> createState() => _AdminManageSyllabusScreenState();
}

class _AdminManageSyllabusScreenState extends State<AdminManageSyllabusScreen> {
  final _subjectNameController = TextEditingController();
  final _topicNameController = TextEditingController();
  List<dynamic> _exams = [];
  String? _selectedExamId;
  List<dynamic> _subjects = [];
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    final response = await Supabase.instance.client.from('exams').select();
    setState(() => _exams = response);
  }

  Future<void> _fetchSubjects(String examId) async {
    final response = await Supabase.instance.client
        .from('subjects')
        .select()
        .eq('exam_id', examId);
    setState(() => _subjects = response);
  }

  Future<void> _addSubject() async {
    if (_selectedExamId == null || _subjectNameController.text.isEmpty) return;
    await Supabase.instance.client.from('subjects').insert({
      'exam_id': _selectedExamId,
      'name': _subjectNameController.text,
    });
    _subjectNameController.clear();
    _fetchSubjects(_selectedExamId!);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject Added!')));
  }

  Future<void> _addTopic() async {
    if (_selectedSubjectId == null || _topicNameController.text.isEmpty) return;
    await Supabase.instance.client.from('topics').insert({
      'subject_id': _selectedSubjectId,
      'name': _topicNameController.text,
    });
    _topicNameController.clear();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Topic Added!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Syllabus', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Select Exam', style: TextStyle(color: Colors.cyanAccent, fontSize: 18)),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF16213E),
              style: const TextStyle(color: Colors.white),
              value: _selectedExamId,
              items: _exams.map((e) => DropdownMenuItem<String>(value: e['id'], child: Text(e['name']))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedExamId = val;
                  _selectedSubjectId = null;
                });
                if (val != null) _fetchSubjects(val);
              },
            ),
            const SizedBox(height: 20),
            
            const Text('2. Add New Subject', style: TextStyle(color: Colors.cyanAccent, fontSize: 18)),
            TextField(
              controller: _subjectNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Subject Name (e.g., History)', labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 10),
            GlowButton(text: 'Add Subject', onPressed: _addSubject, glowColor: Colors.blueAccent),
            const SizedBox(height: 40),

            const Text('3. Select Subject & Add Topic', style: TextStyle(color: Colors.cyanAccent, fontSize: 18)),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF16213E),
              style: const TextStyle(color: Colors.white),
              value: _selectedSubjectId,
              items: _subjects.map((s) => DropdownMenuItem<String>(value: s['id'], child: Text(s['name']))).toList(),
              onChanged: (val) => setState(() => _selectedSubjectId = val),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _topicNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Topic Name (e.g., Ancient India)', labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 10),
            GlowButton(text: 'Add Topic', onPressed: _addTopic, glowColor: Colors.greenAccent),
          ],
        ),
      ),
    );
  }
}
