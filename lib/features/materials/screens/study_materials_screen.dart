import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass_container.dart';

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen> {
  bool _isLoading = true;
  List<dynamic> _materials = [];

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get user's exam id
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('selected_exam_id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null || profile['selected_exam_id'] == null) {
        setState(() => _isLoading = false);
        return;
      }

      final examId = profile['selected_exam_id'];

      // Fetch study materials for this exam
      final response = await Supabase.instance.client
          .from('study_materials')
          .select()
          .eq('exam_id', examId)
          .order('created_at', ascending: false);

      setState(() {
        _materials = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading materials: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Study Materials', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
              ? const Center(child: CircularProgressIndicator())
              : _materials.isEmpty
                  ? const Center(child: Text('No study materials found.', style: TextStyle(color: Colors.white54, fontSize: 18)))
                  : RefreshIndicator(
                      onRefresh: _fetchMaterials,
                      color: Colors.cyanAccent,
                      backgroundColor: const Color(0xFF16213E),
                      child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _materials.length,
                      itemBuilder: (context, index) {
                        final material = _materials[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purpleAccent.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.picture_as_pdf, color: Colors.purpleAccent),
                              ),
                              title: Text(material['title'] ?? 'Untitled', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(material['description'] ?? 'No description', style: const TextStyle(color: Colors.white70)),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                              onTap: () {
                                context.push('/pdf-viewer', extra: {
                                  'url': material['file_url'],
                                  'title': material['title'],
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ),
    );
  }
}

