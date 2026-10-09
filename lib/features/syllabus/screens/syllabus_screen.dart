import '../../../core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  bool _isLoading = true;
  List<dynamic> _allSubjects = [];
  Map<String, List<dynamic>> _allTopics = {};
  
  // For Search Feature
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSyllabus();
  }

  Future<void> _fetchSyllabus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('selected_exam_id')
          .eq('id', user.id)
          .single();
      
      final examId = profile['selected_exam_id'];
      if (examId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final subjectsResponse = await Supabase.instance.client
          .from('subjects')
          .select()
          .eq('exam_id', examId)
          .order('order_index', ascending: true);

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
          _allSubjects = subjectsResponse;
          _allTopics = topicMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching syllabus');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getFilteredSubjects() {
    if (_searchQuery.isEmpty) return _allSubjects;
    
    return _allSubjects.where((subject) {
      final subjectName = subject['name'].toString().toLowerCase();
      // Check if subject matches
      if (subjectName.contains(_searchQuery.toLowerCase())) return true;
      
      // Check if any topic inside the subject matches
      final subjectTopics = _allTopics[subject['id']] ?? [];
      final hasMatchingTopic = subjectTopics.any((topic) => 
          topic['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
          
      return hasMatchingTopic;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = _getFilteredSubjects();

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
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Colors.cyanAccent),
                      hintText: 'Search subjects or topics...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              
              // Syllabus List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                    : _allSubjects.isEmpty
                        ? const Center(
                            child: Text(
                              'Syllabus not available for this exam yet.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : filteredSubjects.isEmpty 
                            ? const Center(
                                child: Text('No matching subjects or topics found.', style: TextStyle(color: Colors.white70)),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredSubjects.length,
                                itemBuilder: (context, index) {
                                  final subject = filteredSubjects[index];
                                  final subjectTopics = _allTopics[subject['id']] ?? [];
                                  
                                  // Filter topics inside the subject if user is searching
                                  final filteredTopics = _searchQuery.isEmpty 
                                      ? subjectTopics 
                                      : subjectTopics.where((t) => t['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) || subject['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: GlassContainer(
                                      padding: EdgeInsets.zero,
                                      child: Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                          collapsedIconColor: Colors.white,
                                          iconColor: Colors.cyanAccent,
                                          initiallyExpanded: _searchQuery.isNotEmpty, // Auto-expand if searching
                                          title: Text(
                                            subject['name'],
                                            style: const TextStyle(
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          children: filteredTopics.map((topic) {
                                            return ListTile(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                              leading: const Icon(Icons.check_circle_outline, color: Colors.purpleAccent),
                                              title: Text(topic['name'], style: const TextStyle(color: Colors.white)),
                                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
                                              onTap: () {},
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
