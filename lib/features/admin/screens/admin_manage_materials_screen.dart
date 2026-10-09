import '../../../core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminManageMaterialsScreen extends StatefulWidget {
  const AdminManageMaterialsScreen({super.key});

  @override
  State<AdminManageMaterialsScreen> createState() => _AdminManageMaterialsScreenState();
}

class _AdminManageMaterialsScreenState extends State<AdminManageMaterialsScreen> {
  bool _isLoading = true;
  List<dynamic> _materials = [];

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    try {
      final response = await Supabase.instance.client
          .from('study_materials')
          .select('*, exams(name)')
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

  Future<void> _deleteMaterial(dynamic material) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Delete Material?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete ""? This action cannot be undone.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // 1. Delete from storage bucket
      final fileUrl = material['file_url'] as String;
      final fileName = fileUrl.split('/').last;
      
      await Supabase.instance.client.storage
          .from('materials')
          .remove([fileName]);

      // 2. Delete from database
      await Supabase.instance.client
          .from('study_materials')
          .delete()
          .eq('id', material['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material deleted successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      }
      
      setState(() {
        _materials.removeWhere((item) => item['id'] == material['id']);
      });
      _fetchMaterials();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Manage Materials', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  ? const Center(child: Text('No materials found.', style: TextStyle(color: Colors.white54, fontSize: 18)))
                  : RefreshIndicator(
                      onRefresh: _fetchMaterials,
                      color: Colors.cyanAccent,
                      backgroundColor: const Color(0xFF16213E),
                      child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _materials.length,
                      itemBuilder: (context, index) {
                        final material = _materials[index];
                        final examName = material['exams']?['name'] ?? 'Unknown Exam';
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              leading: const Icon(Icons.picture_as_pdf, color: Colors.purpleAccent, size: 32),
                              title: Text(material['title'] ?? 'Untitled', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(examName, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(material['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteMaterial(material),
                              ),
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


