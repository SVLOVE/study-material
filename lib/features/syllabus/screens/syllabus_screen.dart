import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/glass_container.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  bool _isLoading = true;
  List<dynamic> _subjects = [];
  Map<String, List<dynamic>> _topics = {};

  @override
  void initState() {
    super.initState();
    _fetchSyllabus();
  }

  Future<void> _fetchSyllabus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get user's exam id
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('selected_exam_id')
          .eq('id', user.id)
          .single();
      
      final examId = profile['selected_exam_id'];
      if (examId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch subjects
      final subjectsResponse = await Supabase.instance.client
          .from('subjects')
          .select()
          .eq('exam_id', examId)
          .order('order_index', ascending: true);

      // Fetch topics for these subjects
      final subjectIds = subjectsResponse.map((s) => s['id']).toList();
      Map<String, List<dynamic>> topicMap = {};

      if (subjectIds.isNotEmpty) {
        final topicsResponse = await Supabase.instance.client
            .from('topics')
            .select()
            .inFilter('subject_id', subjectIds)
            .order('order_index', ascending: true);

        for (var topic in topicsResponse) {
          final sId = topic['subject_id'];
          if (!topicMap.containsKey(sId)) {
            topicMap[sId] = [];
          }
          topicMap[sId]!.add(topic);
        }
      }

      if (mounted) {
        setState(() {
          _subjects = subjectsResponse;
          _topics = topicMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching syllabus');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Study Plan (Syllabus)', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
              : _subjects.isEmpty
                  ? const Center(
                      child: Text(
                        'Syllabus not available for this exam yet.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        final subjectTopics = _topics[subject['id']] ?? [];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassContainer(
                            padding: EdgeInsets.zero,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                collapsedIconColor: Colors.white,
                                iconColor: Colors.cyanAccent,
                                title: Text(
                                  subject['name'],
                                  style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: subject['description'] != null
                                    ? Text(subject['description'], style: const TextStyle(color: Colors.white70, fontSize: 13))
                                    : null,
                                children: subjectTopics.map((topic) {
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                    leading: const Icon(Icons.check_circle_outline, color: Colors.purpleAccent),
                                    title: Text(topic['name'], style: const TextStyle(color: Colors.white)),
                                    subtitle: topic['weightage_percentage'] != null
                                        ? Text('Weightage: ' + topic['weightage_percentage'].toString() + '%', style: const TextStyle(color: Colors.white54, fontSize: 12))
                                        : null,
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
                                    onTap: () {
                                      // TODO: Go to Topic Details/Practice
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
